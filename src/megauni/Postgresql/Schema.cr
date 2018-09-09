
module MEGAUNI
  struct Postgresql
    struct Schema

      struct Name
        def self.valid!(x : String)
          x[/^[a-z\_0-9]{2,25}$/]?.not_nil!
        end

        getter name : String
        def initialize(raw_name : String)
          @name = self.class.valid!(raw_name)
        end # === def
      end # === struct Name

      getter database          : Database
      getter name              : String
      getter owner             : String
      getter access_privileges : Array(String) = [] of String
      getter description       : String

      def initialize(@database, raw : String)
        raw_name, @owner, raw_access_privileges, @description = raw.split('|')
        @name = Name.new(raw_name).name
        raw_access_privileges.split.each { |x|
          access_privileges.push x
        }
      end # def

      def create_definer
        role_name = "#{name}_definer"
        if !role?(role_name)
          psql_command(%<
            CREATE ROLE #{role_name}
              NOSUPERUSER NOCREATEDB NOCREATEROLE NOBYPASSRLS NOINHERIT NOLOGIN NOREPLICATION;
            COMMIT;
                       >)
        end
        psql_command(%<
            ALTER ROLE #{role_name} WITH
              NOSUPERUSER NOCREATEDB NOCREATEROLE NOBYPASSRLS NOINHERIT NOLOGIN NOREPLICATION;
            GRANT CREATE, USAGE
              ON SCHEMA #{schema.name} TO #{role_name};
            COMMIT;
                     >)
      end # === def

    end # === struct Schema
  end # === struct Postgresql
end # === module MEGAUNI

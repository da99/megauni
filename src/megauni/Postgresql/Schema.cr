
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

    end # === struct Schema
  end # === struct Postgresql
end # === module MEGAUNI

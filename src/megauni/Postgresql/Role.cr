
module MEGAUNI
  struct Postgresql
    struct Role

      struct Name

        def self.valid!(x : String)
          x[/^[a-z0-9\_\-]{1,25}$/]?.not_nil!
        end

        getter name : String
        def initialize(raw : String)
          @name = Name.valid!(raw)
        end # === def

      end # === struct Name

      getter cluster    : Postgresql
      getter name       : String
      getter attributes : Array(String) = [] of String
      getter member_of  : Array(String) = [] of String

      def initialize(@cluster, raw_line : String)
        pieces = raw_line.chomp.split('|')
        @name = pieces.shift

        pieces.shift.split(/, /).each { |l|
          next if !l || l.empty?
          @attributes.push l
        }

        pieces.shift.chomp.split(/\{|\}|,\ ?/).each { |l|
          next if !l || l.empty?
          @member_of.push l
        }
      end # === def

      def super_user?
        name == cluster.super_user_name
      end

      def grant_to(r : Role)
        cluster.template1.psql_command("GRANT #{name} TO #{r.name}; COMMIT")
      end

      def grant_to(raw : String)
        grant_to(cluster.role(raw))
      end # === def

      def alter_with(*syms : Symbol)
        cluster.template1.psql_command("ALTER ROLE #{name} WITH #{syms.join ", "}; COMMIT")
      end # === def

    end # === struct Role
  end # === struct Postgresql
end # === module MEGAUNI

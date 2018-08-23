
module MEGAUNI
  module PostgreSQL
    struct Database

      getter name : String
      getter owner : String
      getter encoding : String
      getter collate : String
      getter ctype : String
      getter access_privileges : Array(String) = [] of String

      def initialize(raw_line : String)
        pieces = raw_line.chomp.split('|')
        @name, @owner, @encoding, @collate, @ctype, raw_access_privileges = pieces
        raw_access_privileges.split('\n').each { |x|
          access_privileges << x unless !x || x.empty?
        }
      end # def

      def tables
        tables = Deque(PostgreSQL::Table).new
        sep = "~!~"
        raw = PostgreSQL.psql_tuples("--dbname=#{name}", "--record-separator=#{sep}", "-c", "\\dt *.*").to_s.split(sep)

        DA.each_non_empty_string(raw) { |line|
          tables.push Table.new(line)
        }
        tables
      end

      def table?(schema : String, name : String)
        tables.find { |x| x.schema == schema && x.name == name }
      end # === def

      def schemas
        sep = "~!~"
        schemas = Deque(PostgreSQL::Schema).new
        raw = PostgreSQL.psql_tuples("--dbname=#{name}", "--record-separator=#{sep}", "-c", "\\dnS+").to_s.split(sep)
        DA.each_non_empty_string(raw) { |line|
          schemas.push Schema.new(line)
        }
        schemas
      end

      def schema?(name : String)
        schemas.find { |x| x.name == name }
      end # def

      def user_defined_types
        sep = "~!~"
        types = Deque(PostgreSQL::User_Defined_Type).new
        DA.each_non_empty_string( PostgreSQL.psql_tuples("--dbname=#{name}", "--record-separator=#{sep}", "-c", "\\dT+ *.*").to_s.split(sep) ) { |line|
          types.push User_Defined_Type.new(line)
        }
        types
      end # === def

      def user_defined_type?(name : String)
        user_defined_types.find { |x| x.name == name }
      end # === def

      def psql_command(cmd : String)
        DA.orange! "=== Running: psql command on database {{#{name}}}: BOLD{{#{cmd.split.join(' ')[0..25]}...}}"
        PostgreSQL.psql("--dbname=#{name}", "-c", cmd)
      end # === def

      def psql_file(path : String)
        if !File.exists?(path)
          raise Exception.new("File does not exist: #{path}")
        end
        DA.orange! "=== Running: psql file on database {{#{name}}}: BOLD{{#{path}}}"
        PostgreSQL.psql("--dbname=#{name}", "--file=#{path}")
      end # === def

    end # === struct Database
  end # === module PostgreSQL
end # === module MEGAUNI


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
        raw = PostgreSQL.psql_tuples("--dbname=#{name} -c \\dt+")

        DA.each_non_empty_line(raw) { |raw_line|
          line = raw_line.chomp
          next if line.empty?
          tables.push Table.new(line)
        }
        tables
      end

      def schemas(options : String = "")
        sep = "~!~"
        schemas = Deque(PostgreSQL::Schema).new
        raw = PostgreSQL.psql_tuples("#{options} --dbname=#{name} --record-separator=#{sep} -c \\dnS+").to_s.split(sep)
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
        DA.each_non_empty_string( psql_tuples("--dbname=#{name} --record-separator=#{sep} -c \\dT+").to_s.split(sep) ) { |line|
          types.push User_Defined_Type.new(line)
        }
        types
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

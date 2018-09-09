
module MEGAUNI
  struct Postgresql
    struct Database

      struct Name
        def self.valid!(x : String)
          x[/^[a-z0-9\_]{1,25}$/]?.not_nil!
        end # === def

        getter name : String
        def initialize(raw : String)
          @name = self.class.valid!(raw)
        end # === def
      end # === struct Name

      getter cluster : Postgresql
      getter name : String
      getter owner : String
      getter encoding : String
      getter collate : String
      getter ctype : String
      getter access_privileges : Array(String) = [] of String

      def initialize(@cluster, raw_line : String)
        pieces = raw_line.chomp.split('|')
        raw_name, @owner, @encoding, @collate, @ctype, raw_access_privileges = pieces
        @name = Name.new(raw_name).name
        raw_access_privileges.split('\n').each { |x|
          access_privileges << x unless !x || x.empty?
        }
      end # def

      def tables
        tables = Deque(Postgresql::Table).new
        sep = "~!~"
        raw = cluster.psql_tuples("--dbname=#{name}", "--record-separator=#{sep}", "-c", "\\dt *.*").to_s.split(sep)

        DA.each_non_empty_string(raw) { |line|
          tables.push Table.new(self, line)
        }
        tables
      end

      def table?(x : String)
        tn = Table::Name.new(x)
        tables.find { |x| x.schema == tn.schema && x.name == tn.name }
      end # === def

      def schemas
        sep = "~!~"
        schemas = Deque(Postgresql::Schema).new
        raw = cluster.psql_tuples("--dbname=#{name}", "--record-separator=#{sep}", "-c", "\\dnS+").to_s.split(sep)
        DA.each_non_empty_string(raw) { |line|
          schemas.push Schema.new(self, line)
        }
        schemas
      end

      def roles
        sep = "!!!"
        roles = Deque(Postgresql::Role).new
        raw = cluster.psql_tuples("--dbname=#{name}", "--record-separator=#{sep}",  "-c", "\\du").to_s.split(sep)
        DA.each_non_empty_string(raw) { |line|
          roles.push Role.new(line)
        }
        roles
      end

      def role(name : String)
        r = role?(name)
        if r
          return r
        else
          raise Exception.new("Role not found: #{name.inspect}")
        end
      end # === def

      def role?(name : String)
        roles.find { |r| r.name == name }
      end

      def create_schema?(name : String)
        psql_command(%< CREATE SCHEMA IF NOT EXISTS #{Schema::Name.new(name).name} AUTHORIZATION db_owner; COMMIT; >)
        schema(name)
      end # === def

      def schema?(name : String)
        schemas.find { |x| x.name == name }
      end # def

      def schema(name : String)
        s = schema?(name)
        if s
          return s
        else
          raise Exception.new("Schema not found in #{name}: #{name.inspect}")
        end
      end # === def

      def user_defined_types
        sep = "~!~"
        types = Deque(Postgresql::User_Defined_Type).new
        DA.each_non_empty_string(cluster.psql_tuples("--dbname=#{name}", "--record-separator=#{sep}", "-c", "\\dT+ *.*").to_s.split(sep) ) { |line|
          types.push User_Defined_Type.new(self, line)
        }
        types
      end # === def

      def user_defined_type?(name : String)
        user_defined_types.find { |x| x.name == name }
      end # === def

      def psql_command(cmd : String)
        DA.orange! "=== Running: psql command on database {{#{name}}}: BOLD{{#{cmd.split.join(' ')[0..25]}...}}"
        cluster.psql("--dbname=#{name}", "-c", cmd)
      end # === def

      def sql_file_path(c, file_name : String)
        File.join "src/megauni", c.name.split("::").last.not_nil!, "/postgresql/", "#{file_name.sub(/\.sql$/, "")}.sql"
      end

      def psql_file(*args)
        psql_file sql_file_path(*args)
      end # === def

      def psql_file(path : String)
        if !File.exists?(path)
          raise Exception.new("File does not exist: #{path}")
        end
        DA.orange! "=== Running: psql file on database {{#{name}}}: BOLD{{#{path}}}"
        cluster.psql("--dbname=#{name}", "--file=#{path}")
      end # === def

      def create_table?(schema_table : String, *args)
        file = sql_file_path(*args)
        if !table?(schema_table)
          psql_file(file)
        end
        table?(schema_table).not_nil!
      end # === def

    end # === struct Database
  end # === struct Postgresql
end # === module MEGAUNI

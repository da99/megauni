
require "db"
require "pg"

module MEGAUNI
  PQ::ConnInfo::SOCKET_SEARCH.push("/tmp/.s.PGSQL.311")

  module PostgreSQL

    struct Connection

      getter port : Int32
      getter user : String

      def initialize(@port, @user)
      end # === def

    end # === struct Connection

    struct Database

      getter connection : Connection
      getter name : String
      getter schema : String

      def initialize(@connection, @name, @schema = "public")
      end # === def

      def schemas
        psql("SELECT nspname FROM pg_catalog.pg_namespace;")
      end # === def

      def roles
        psql("SELECT rolname FROM pg_roles;")
      end # === def

      def databases
        psql("SELECT datname FROM pg_catalog.pg_database;")
      end # === def

      def types
        psql(%[
        SELECT
        pg_catalog.format_type(t.oid, NULL) AS "name"
        FROM pg_catalog.pg_type t
        LEFT JOIN pg_catalog.pg_namespace n ON n.oid = t.typnamespace
        WHERE (t.typrelid = 0 OR (SELECT c.relkind = 'c' FROM pg_catalog.pg_class c WHERE c.oid = t.typrelid))
        AND NOT EXISTS(SELECT 1 FROM pg_catalog.pg_type el WHERE el.oid = t.typelem AND el.typarray = t.oid)
        AND n.nspname <> 'pg_catalog'
        AND n.nspname <> 'information_schema'
        AND pg_catalog.pg_type_is_visible(t.oid)
        AND n.nspname = 'base'
        ORDER BY "name";
             ]);
      end # === def

      def tables
        psql(%[
        SELECT table_name
        FROM information_schema.tables
        WHERE table_catalog = '#{name}'
        AND table_schema = '#{schema}'
        AND table_type = 'BASE TABLE'
        ORDER BY table_name;
             ])
      end # === def

      def psql(sql_file : String)
        if sql_file["migrate/"]?
            DA.orange! "=== {{Running}} BOLD{{#{sql_file}}} in BOLD{{#{name}}}"
        end

        args = "-u #{connection.user}
        psql
          --port=#{connection.port}
          --quiet
          --dbname=#{name}
          --tuples-only
          --no-align
          --set ON_ERROR_STOP=on
          --set AUTOCOMMIT=off
        ".split

        if sql_file[/^[\/a-zA-Z0-9\_\-\.]+$/]? File.file?(sql_file)
          args.push "-f"
        else
          args.push "-c"
        end

        args.push sql_file

        # DA.orange! "{{sudo}} BOLD{{#{args.join ' '}}}"
        DA.output!("sudo", args)
      end # def

      def run
        db = DB.open("postgres:///megauni_db?max_pool_size=25&max_idle_pool_size=5")
        yield db

      rescue e : DB::ConnectionRefused
        DA.red! "!!! Ensure db user BOLD{{#{ENV["USER"]}}} and db BOLD{{#{name}}} exists."
        exit 1

      ensure
        db.close if db
      end

    end # === struct Database

    struct Database_Cluster

      getter connection : Connection
      getter database   : Database
      getter template1  : Database

      def initialize(port : Int32, user : String, database : String, schema : String)
        @connection = Connection.new(port, user)
        @database   = Database.new(@connection, database, schema)
        @template1  = Database.new(@connection, "template1")
      end # === def

      def migrate(dir : String)
        Dir.glob(File.join dir, "/*.sql").sort.each { |f|
          file_name = File.basename(f, ".sql")
          file_name.split(/^\d+[\.\-]/).map(&.strip).reject(&.empty?).map { |f| f.split('.') }.each { |pieces|
            type = pieces.shift
            name = pieces.join('.')
            case type

            when "template1"
              template1.psql(f)

            when "function"
              database.psql(f)

            when "role"
              old = template1.roles
              if old.includes?(name)
                DA.orange! "=== role {{already exists}}: BOLD{{#{name}}}"
              else
                template1.psql(f)
              end

            when "database"
              old = template1.databases
              if old.includes?(name)
                DA.orange! "=== database {{already exists}}: BOLD{{#{name}}}"
              else
                template1.psql(f)
              end

            when "schema"
              old = database.schemas
              if old.includes?(name)
                DA.orange! "=== schema {{already exists}}: BOLD{{#{name}}}"
              else
                database.psql(f)
              end

            when "enum"
              old = database.types
              if old.includes?(name)
                DA.orange! "=== type {{already exists}}: BOLD{{#{name}}}"
              else
                database.psql(f)
              end

            when "table"
              old = database.tables
              if old.includes?(name)
                DA.orange! "=== table {{already exists}}: BOLD{{#{name}}}"
              else
                database.psql(f)
              end

            when "grant"
              database.psql(f)

            when "alter_database"
              template1.psql(f)

            when "alter_role"
              template1.psql(f)

            else
              DA.orange! "Unknown type: #{type.inspect} (name: #{name.inspect}, file: #{f})"
              Process.exit 1

            end # case type
          } # each file_name
        } # each .sql file
      end # === def

    end # === struct

  end # === module PG
end # === module MEGAUNI

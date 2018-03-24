


module MEGAUNI
  module SQL
    PG_DUMP = "src/megauni/SQL/pg_dump.sql"

    extend self

    def db_name
      "megauni_db"
    end

    def setup
      begin
        DB.open "postgres:///megauni_db?max_pool_size=25&max_idle_pool_size=5" do |db|
          db.query("select NOW();") do |rs|
            rs.each {
              puts rs.read(Time).inspect
            }
          end
        end
      rescue e : DB::ConnectionRefused
        DA_Dev.red! "!!! Ensure db user BOLD{{#{ENV["USER"]}}} and db BOLD{{#{MEGAUNI::SQL.db_name}}} exists."
        exit 1
      end

      migrate
    end

    def files(glob : String)
      Dir.glob(glob).sort_by { |x|
        File.basename(x).split("-").first.to_i
      }
    end

    def migrate
      Dir.cd THIS_DIR
      if !File.exists?(PG_DUMP)
        STDERR.puts "!!! File not found: #{PG_DUMP}"
        exit 1
      end

      Dir.mkdir_p "tmp/out"
      tmp_dump = "tmp/out/pg_dump.sql"
      File.write(tmp_dump, dump)

      system("diff", "-U3 #{tmp_dump} #{PG_DUMP}".split)
      DA_Process.success! $?

      DA_Dev.green! "=== PG database {{up-to-date}}. ==="
    end # === def migrate

    def migrate_force
      Dir.cd THIS_DIR
      [
        files("src/megauni/Model/Common/db/*.sql"),
        files("src/megauni/Model/Member/db/*.sql"),
        files("src/megauni/Model/Screen_Name/db/*.sql"),
        files("src/megauni/Model/Member_Block/db/*.sql"),
        files("src/megauni/Model/Folder/db/*.sql"),
        files("src/megauni/Model/Label/db/*.sql"),
        files("src/megauni/Model/Message/db/*.sql"),
        files("src/megauni/Model/Mail/db/*.sql"),
        files("src/megauni/Model/Readable/db/*.sql"),
        files("src/megauni/Model/Writeable/db/*.sql")
      ].each { |files|
        files.each { |x|
          DA_Dev.orange! "=== {{Running SQL}}: BOLD{{#{x}}}"
          system("psql", "-v ON_ERROR_STOP=1 #{MEGAUNI::SQL.db_name} -f #{x}".split)
          DA_Process.success! $?
          DA_Dev.green! "=== {{#{x}}} ==="
        }
      }
      migrate_dump
    end # === def migrate_force

    def migrate_dump
      if !ENV["IS_DEV"]?
        STDERR.puts "!!! migrate dump: can only be run on a dev machine."
        exit 1
      end
      Dir.cd THIS_DIR
      File.write(PG_DUMP, dump)
      DA_Dev.green! "=== {{Wrote}}: BOLD{{PG_DUMP}}"
    end # === def migrate_dump

    def dump
      "#{dump_roles}\n#{dump_schema}"
    end

    def dump_roles
      sql = "SELECT * FROM pg_catalog.pg_roles WHERE rolname = 'production_user' OR rolname = 'web_app' ORDER BY rolname;"
      proc = DA_Process.new("psql", [MEGAUNI::SQL.db_name, "-c", sql])
      proc.success!
      proc.output.to_s.lines.map { |l| l.gsub(/\s*[0-9]+\s*$/, "") }.join('\n')
    end

    def dump_schema
      proc = DA_Process.new("pg_dump", "--schema-only #{MEGAUNI::SQL.db_name}".split)
      proc.success!

      proc.output.to_s
    end # === def migrate_dump

    def reset!
      if !MEGAUNI.dev?
        STDERR.puts "!!! reset! can only be run in dev. env."
        exit 1
      end

      DA_Dev.orange! "=== Logging into database server as: BOLD{{postgres}}"
      system("sudo", [
        "-u", "postgres", "psql", "postgres",
        "-c", "DROP DATABASE #{db_name};",
        "-c", "CREATE DATABASE #{db_name} WITH OWNER = production_user ;"
      ])
    end

  end # === module SQL
end # === module MEGAUNI

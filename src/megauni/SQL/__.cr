


module MEGAUNI
  module SQL

    class Query_Error < Error
    end

    PG_DUMP = "src/megauni/SQL/pg_dump.sql"

    extend self

    def db_name
      "megauni_db"
    end

    def run
      db = DB.open("postgres:///megauni_db?max_pool_size=25&max_idle_pool_size=5")
      yield db
    rescue e : DB::ConnectionRefused
      DA_Dev.red! "!!! Ensure db user BOLD{{#{ENV["USER"]}}} and db BOLD{{#{MEGAUNI::SQL.db_name}}} exists."
      exit 1
    ensure
      db.close if db
    end

    def up! : Bool
      name = false
      run { |db|
        name = db.query_one("SELECT 'a' AS name;", as: {String})
      }
      name.is_a?(String)
    end

    def files(glob : String)
      Dir.glob(glob).sort_by { |x|
        File.basename(x).split("-").first.to_i
      }
    end

    def migrate
      Dir.cd MEGAUNI.app_dir
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
      Dir.cd MEGAUNI.app_dir
      [
        files("src/megauni/Model/Common/db/*.sql"),
        files("src/megauni/Model/Member/db/*.sql"),
        files("src/megauni/Model/Screen_Name/db/*.sql"),
        files("src/megauni/Model/Member_Block/db/*.sql"),
        files("src/megauni/Model/Message_Folder/db/*.sql"),
        files("src/megauni/Model/Label/db/*.sql"),
        files("src/megauni/Model/Message/db/*.sql"),
        files("src/megauni/Model/Message_Receive_Command/db/*.sql"),
        files("src/megauni/Model/Mail/db/*.sql"),
        files("src/megauni/Model/Readable/db/*.sql"),
        files("src/megauni/Model/Writeable/db/*.sql")
      ].flatten.sort_by { |x| File.basename(x.split('-').first.not_nil!).to_i }.each { |x|
        DA_Dev.orange! "=== {{Running SQL}}: BOLD{{#{x}}}"
        system("psql", "-v ON_ERROR_STOP=1 #{MEGAUNI::SQL.db_name} -f #{x}".split)
        DA_Process.success! $?
        DA_Dev.green! "=== {{#{x}}} ==="
      }
      migrate_dump
    end # === def migrate_force

    def migrate_dump
      if !ENV["IS_DEVELOPMENT"]?
        STDERR.puts "!!! migrate dump: can only be run on a dev machine."
        exit 1
      end
      Dir.cd MEGAUNI.app_dir
      File.write(PG_DUMP, dump)
      DA_Dev.green! "=== {{Wrote}}: BOLD{{PG_DUMP}}"
    end # === def migrate_dump

    def dump
      "#{dump_roles}\n#{dump_schema}"
    end

    def dump_roles
      sql = "SELECT * FROM pg_catalog.pg_roles WHERE rolname = '#{MEGAUNI.production_user}' OR rolname = '#{MEGAUNI.web_app_user}' ORDER BY rolname;"
      proc = DA_Process.new("psql", [MEGAUNI::SQL.db_name, "-c", sql])
      proc.success!
      proc.output.to_s.lines.map { |l| l.gsub(/\s*[0-9]+\s*$/, "") }.join('\n')
    end

    def dump_schema
      proc = DA_Process.new("pg_dump", "--schema-only #{MEGAUNI::SQL.db_name}".split)
      proc.success!

      proc.output.to_s
    end # === def migrate_dump

    def reset_tables!
      if !DA.development?
        STDERR.puts "!!! reset_tables! can only be run in dev. env."
        exit 1
      end

      run { |db|
        db.query("SELECT table_name FROM megauni_tables;") { |rs|
          rs.each {
            table_name = rs.read(String)
            sql = %[DELETE FROM #{table_name};]
            # DA_Dev.orange! "=== {{SQL}}: BOLD{{#{sql}}}"
            db.exec sql
          }
        }
      }
    end # === def reset_tables!

    def database_owner
      if MEGAUNI.development?
        MEGAUNI.who_am_i
      else
        MEGAUNI.web_app_user
      end
    end

    def reset!
      MEGAUNI.development!

      DA_Dev.orange! "=== Logging into database server as: BOLD{{postgres}}"
      system("sudo", [
        "-u", "postgres", "psql", "postgres",
        "-c", "DROP DATABASE #{db_name};",
        "-c", "CREATE DATABASE #{db_name} WITH OWNER = #{database_owner} ;"
      ])
    end

  end # === module SQL
end # === module MEGAUNI


require "my_js"
require "my_css"

module MEGAUNI
  module Dev
    PG_DUMP = "src/megauni/SQL/pg_dump.sql"

    class Error < Exception
    end

    extend self

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
        DA_Dev.red! "!!! Ensure db user BOLD{{#{ENV["USER"]}}} and db BOLD{{#{MEGAUNI.sql_db_name}}} exists."
        exit 1
      end

      migrate
    end

    def sql_files(glob : String)
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
        sql_files("src/megauni/Model/User/db/*.sql"),
        sql_files("src/megauni/Model/Screen_Name/db/*.sql")
      ].each { |files|
        files.each { |x|
          DA_Dev.orange! "=== {{Running SQL}}: BOLD{{#{x}}}"
          system("psql", "-v ON_ERROR_STOP=1 #{MEGAUNI.sql_db_name} -f #{x}".split)
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
      proc = DA_Process.new("psql", [MEGAUNI.sql_db_name, "-c", sql])
      proc.success!
      proc.output.to_s.lines.map { |l| l.gsub(/\s*[0-9]+\s*$/, "") }.join('\n')
    end

    def dump_schema
      proc = DA_Process.new("pg_dump", "--schema-only #{MEGAUNI.sql_db_name}".split)
      proc.success!

      proc.output.to_s
    end # === def migrate_dump

    def hex_colors_file
      file = "src/megauni/Route/MUE/__vars.sass"
      colors = {} of String => String
      File.read(file).lines.each { |l|
        pieces = l.split(':').map(&.strip)
        hex = pieces.last?.try { |x| x.split('/').first? }
        next if !hex
        if hex[/\A\#[A-Za-z0-9]+\Z/]?
            name = pieces.first
            colors[name] = hex
        end
      }
      new_file = "tmp/out/hex_colors.html"
      Dir.mkdir_p(File.dirname(new_file))
      html = IO::Memory.new
      html << <<-EOF
      <html>
        <head>
          <style>
          body { font-family: sans-serif; font-size: smaller;  }
          div.color { padding-top: 10px; float: left; width: 150px; height: 150px }
          div.hex {
            background-color: #fff;
          }
          div.name {
            background-color: #fff;
            font-weight: bolder;
          }
          </style>
        </head>
        <body>
      EOF
      colors.each { |name, hex|
        html << <<-EOF
          <div class="color" style="background-color: #{hex};">
          <div class="hex">#{hex}</div>
          <div class="name">#{name}</div>
          </div>
        EOF
      }
      html << "</body></html>"
      File.write(new_file, html.to_s)
      DA_Dev.green! "=== {{Wrote}}: BOLD{{#{File.expand_path new_file}}}"
    end # === def hex_colors_file

    def upgrade
      DA_Dev.orange! "=== {{Pulling}} BOLD{{#{DA_Process.new("git remote get-url origin").success!.output.to_s.strip}}}"
      DA_Process.success!("git", "pull".split)

      DA_Dev.orange! "=== {{yarn upgrade}}"
      DA_Process.success!("yarn", "upgrade".split)

      DA_Dev.orange! "=== {{Upgrading}}: crystal shards"
      DA_Dev.deps
      DA_Dev.green! "=== {{Done}}: BOLD{{upgrading}} ==="
    end

    def tell_human_file_size(file : String)
      size = File.stat(file).size
      if size < 50
        DA_Dev.orange! "=== BOLD{{Wrote}}: #{file} -- {{#{human_file_size size}}}"
      else
        DA_Dev.green! "=== {{Wrote}}: #{file} (#{human_file_size size})"
      end
    end

    def human_file_size(i)
      if i < 1024
        "#{i} bytes"
      else
        "#{(i.to_f/1024.0).round(2)} Kb"
      end
    end

    def compile_all
      sass_files.each { |f| compile f }
      jspp_files.each { |f| compile f }
    end

    def jspp_files
      files = [] of String
      %w[Route].each { |dir|
        Dir.glob("./src/megauni/#{dir}/*/*.jspp").each { |jspp|
          files.push jspp
        }
      }
      files
    end

    def sass_files
      files = [] of String
      %w[Route].each { |dir|
        Dir.glob("./src/megauni/#{dir}/*/*.sass").each { |sass|
          next if File.basename(sass)[/\A__/]?
          files.push sass
        }
      }
      files
    end

    def compile(file)
      ext = File.extname(file)
      route_file = MEGAUNI.route_file(file)
      case ext

      when ".jspp"
        libs     = Dir.glob(".js_packages/da_standard/src/*.jspp")
        jspp     = My_JS::File.new(libs, file)
        new_file = "Public/public/#{route_file}.js"
        output = jspp.compile(new_file)
        if output.success?
          tell_human_file_size(new_file)
        else
          STDERR.puts output.error
          exit output.stat.exit_code
        end

      when ".sass"
        is_partial  = File.basename(file)[/\A__/]?
        if is_partial
          sass_files.each { |f| compile f }
          return
        end

        sassc    = My_CSS::File.new(file)
        new_file = "Public/public/#{route_file}.css"
        output   = sassc.compile(new_file)
        if output.success?
          tell_human_file_size(new_file)
        else
          STDERR.puts output.error
          exit output.stat.exit_code
        end

      else
        raise Error.new("Unknown file type to compile: #{file.inspect} (#{ext})")
      end
    end # === def compile

  end # === module Dev
end # === module MEGAUNI

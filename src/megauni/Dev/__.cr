
require "my_js"
require "my_css"

module MEGAUNI
  module Dev
    class Error < Exception
    end

    extend self

    def hex_colors_file
      file = "src/megauni/Desktop/MUE/__vars.sass"
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
      %w[Desktop Mobile].each { |dir|
        Dir.glob("./src/megauni/#{dir}/*/*.jspp").each { |jspp|
          files.push jspp
        }
      }
      files
    end

    def sass_files
      files = [] of String
      %w[Desktop Mobile].each { |dir|
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

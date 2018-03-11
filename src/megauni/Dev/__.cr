
require "my_js"
require "my_css"

module MEGAUNI
  module Dev
    class Error < Exception
    end

    extend self

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

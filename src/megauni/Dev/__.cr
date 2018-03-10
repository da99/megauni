
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

    def compile(file)
      ext = File.extname(file)
      case ext
      # when ".jspp"
      #   My_JS.
      when ".sass"
        output     = My_CSS::File.new(file).compile!
        route_name = File.basename(File.dirname(file))
        dir        = "Public/public/#{route_name}"
        name       = File.basename(file, ".sass")
        new_file   = File.join(dir, "#{name}.css")
        Dir.mkdir_p(dir)
        File.write(new_file, output)
        DA_Dev.green! "=== {{Wrote}}: BOLD{{#{new_file}}} (size: #{output.size})"
      else
        raise Error.new("Unknown file type to compile: #{file.inspect}")
      end
    end # === def compile

  end # === module Dev
end # === module MEGAUNI

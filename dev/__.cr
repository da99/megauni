
require "da_dev"

args = ARGV.dup
full_cmd = args.join(' ')
THIS_DIR = File.expand_path("#{__DIR__}/..")
cmd = args.shift?

require "./*"

if cmd == "compile"
  if File.expand_path(Dir.current) != THIS_DIR
    DA_Dev.red! "!!! {{Invalid current directory}}: BOLD{{#{Dir.current}}}"
    exit 1
  end
end

case
when full_cmd == "compile all"
  Dir.glob("./src/megauni/*/*.jspp").each { |jspp|
    JSPP_File.new(jspp).compile!
  }

  Dir.glob("./src/megauni/*/*.scss").each { |scss|
    SCSS_File.new(scss).compile!
  }

when cmd == "compile" && args.size == 1 && args.first[/.jspp$/]?
  jspp = JSPP_File.new(args.shift)
  jspp.compile!

when cmd == "compile" && args.size == 1 && args.first[/.scss$/]?
  scss = SCSS_File.new(args.shift)
  scss.compile!

else
  DA_Dev.red! "!!! {{Invalid options}}: BOLD{{#{ARGV.map(&.inspect).join " "}}}"
end

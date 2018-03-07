
require "da_dev"

args = ARGV.dup
THIS_DIR = File.expand_path("#{__DIR__}/..")
cmd = args.shift?

case
when cmd == "compile" && args.size == 1 && args.first[/.jspp$/]?
  if File.expand_path(Dir.current) != THIS_DIR
    DA_Dev.red! "!!! {{Invalid current directory}}: BOLD{{#{Dir.current}}}"
    exit 1
  end

  jspp       = args.shift
  route_name = File.basename(File.dirname(jspp))
  js         = "Public/public/#{route_name}/script.js"

  Dir.mkdir_p(File.dirname(js))
  my_jspp = "#{THIS_DIR}/../my_jspp/bin/my_jspp"
  Process.exec(my_jspp, "__ #{jspp} -o #{js}".split)
else
  DA_Dev.red! "!!! {{Invalid options}}: BOLD{{#{ARGV.map(&.inspect).join " "}}}"
end

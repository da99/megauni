
require "inspect_bang"
require "da_dev"
require "../src/megauni"
require "../src/megauni/Dev/*"

full_cmd = ARGV.join(' ')
args     = ARGV.dup
cmd      = args.shift
THIS_DIR = File.expand_path(File.join(__DIR__, ".."))
APP_NAME = File.basename(THIS_DIR)

if cmd == "compile"
  if File.expand_path(Dir.current) != THIS_DIR
    DA_Dev.red! "!!! {{Invalid current directory}}: BOLD{{#{Dir.current}}}"
    exit 1
  end
end

{% if env("IS_DEV") %}
  ENV["HTTP_SERVER_SESSION_SECRET"]="a key FOR development ONLY $(date)$(date)"
{% end %}

case

when full_cmd == "this_dir"
  puts THIS_DIR

when {"-h", "help", "--help"}.includes?(full_cmd)
  # === {{CMD}} help|-h|--help
  DA_Dev::Documentation.print_help([__FILE__])

when cmd == "server" && args.first? == "start" && args.size == 2
  # === {{CMD}} server start port
  args.shift
  port = begin
           i = args.shift
           begin
             i.to_i32
           rescue e
             DA_Dev.red! "!!! {{Invalid port}}: BOLD{{#{i.inspect}}}"
             exit 1
           end
         end
  MEGAUNI::Server.new(port).listen

when full_cmd == "server stop"
  # === {{CMD}} server stop # Graceful shutdown of all servers.
  MEGAUNI::Server.stop_all

when full_cmd == "server is-running"
  # === {{CMD}} server is-running
  count = MEGAUNI::Server.running_servers
  exit 0 if count.size > 0
  exit 1

when cmd == "server" && args.first? == "check" && args.size == 2
  # === {{CMD}} server check port
  args.shift
  MEGAUNI::Server.check(args.shift.not_nil!.to_i32)

when cmd == "server" && args.first? == "check" && args.size == 3
  # === {{CMD}} server check port /address
  args.shift
  MEGAUNI::Server.check(args.shift.not_nil!.to_i32, args.shift.not_nil!)

when full_cmd == "compile all"
  Dir.glob("./src/megauni/*/*.jspp").each { |jspp|
    MEGAUNI::Dev::JSPP_File.new(jspp).compile!
  }

  Dir.glob("./src/megauni/*/*.scss").each { |scss|
    MEGAUNI::Dev::SCSS_File.new(scss).compile!
  }

when cmd == "compile" && args.first? == "shard.yml"
  :ignore

when cmd == "compile" && args.size == 1 && args.first[/.jspp$/]?
  jspp = MEGAUNI::Dev::JSPP_File.new(args.shift)
  jspp.compile!

when cmd == "compile" && args.size == 1 && args.first[/.scss$/]?
  scss = MEGAUNI::Dev::SCSS_File.new(args.shift)
  scss.compile!

when full_cmd == "upgrade"
  MEGAUNI::Dev.upgrade


else
  DA_Dev.red! "!!! {{Invalid arguments}}: BOLD{{#{ARGV.map(&.inspect).join ' '}}}"
  exit 1

end # === case

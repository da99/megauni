
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


case

when full_cmd == "this_dir"
  puts THIS_DIR

when {"-h", "help", "--help"}.includes?(full_cmd)
  # === {{CMD}} help|-h|--help
  DA_Dev::Documentation.print_help([__FILE__])

when full_cmd == "server start"
  # === {{CMD}} server start
  Signal::INT.trap do
    STDERR.puts "=== INT signal received. Exiting gracefully and with 0..."
    exit 0 # run at_exit handlers to close DB and other resources.
  end

  MEGAUNI::Server.new.listen

when full_cmd == "server stop"
  # === {{CMD}} server stop
  MEGAUNI::Server.stop_all

when full_cmd == "server is-running"
  # === {{CMD}} server is-running
  count = MEGAUNI::Server.running_servers
  exit 0 if count.size > 0
  exit 1

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
  DA_Dev.orange! "=== {{Pulling}} BOLD{{#{DA_Process.new("git remote get-url origin").success!.output.to_s.strip}}}"
  DA_Process.success!("git", "pull".split)

  DA_Dev.orange! "=== {{yarn upgrade}}"
  DA_Process.success!("yarn", "upgrade".split)

  DA_Dev.orange! "=== {{Upgrading}}: crystal shards"
  DA_Dev.deps
  DA_Dev.green! "=== {{Done}}: BOLD{{upgrading}} ==="

else
  system(File.join(THIS_DIR, "bin/__megauni.sh"), ARGV)
  stat = $?
  exit stat.exit_code if !stat.exit_code.zero?

end # === case

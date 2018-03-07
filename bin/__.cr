
require "inspect_bang"
require "da_dev"
require "../src/megauni"

full_cmd = ARGV.join(' ')
args     = ARGV.dup
cmd      = args.shift
THIS_DIR = File.expand_path(File.join(__DIR__, ".."))
APP_NAME = File.basename(THIS_DIR)

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

else
  system(File.join(THIS_DIR, "bin/__megauni.sh"), ARGV)
  stat = $?
  exit stat.exit_code if !stat.exit_code.zero?

end # === case

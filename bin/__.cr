
require "inspect_bang"
require "da_dev"

full_cmd = ARGV.join(' ')
args = ARGV.dup
cmd = args.shift
THIS_DIR = File.expand_path(File.join(__DIR__, ".."))
APP_NAME = File.basename(THIS_DIR)

case

when full_cmd == "this_dir"
  puts THIS_DIR

when {"-h", "help", "--help"}.includes?(full_cmd)
  # === {{CMD}} help|-h|--help
  divider = "# #{"=" * 3}"
  contents = File.read(__FILE__)
  contents.each_line { |l|
    next if !(l[divider]? && l["{{"]?)
    pieces = l.split(/#{divider}/)
    next if pieces.size < 2
    pieces.shift
    l = pieces.join(divider)

    l = l.gsub("{{CMD}}", "{{#{APP_NAME}}}").split.join(' ')
    DA_Dev.bold! l
  }

else
  system(File.join(THIS_DIR, "bin/__megauni.sh"), ARGV)
  stat = $?
  exit stat.exit_code if !stat.exit_code.zero?

end # === case

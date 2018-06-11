
require "inspect_bang"
require "da"
require "da_dev"
require "../src/megauni"
# require "../src/megauni/Dev/*"
# require "../src/megauni/SQL/*"

full_cmd = ARGV.join(' ')
args     = ARGV.dup
cmd      = args.shift


{% if env("IS_DEVELOPMENT") %}
  ENV["HTTP_SERVER_SESSION_SECRET"]="a key FOR development ONLY $(date)$(date)"
{% end %}

case

when {"-h", "help", "--help"}.includes?(full_cmd)
  # === {{CMD}} help|-h|--help
  DA_Dev::Documentation.print_help([__FILE__])

when full_cmd == "service run"
  # === {{CMD}} service run
  MEGAUNI.service_run

# when cmd == "server" && args.first? == "check" && args.size == 2
#   # === {{CMD}} server check port
#   args.shift
#   MEGAUNI::Server.check(args.shift.not_nil!.to_i32)

# when cmd == "server" && args.first? == "check" && args.size == 3
#   # === {{CMD}} server check port /address
#   args.shift
#   MEGAUNI::Server.check(args.shift.not_nil!.to_i32, args.shift.not_nil!)

# when full_cmd == "compile all"
#   # === {{CMD}} compile all
#   MEGAUNI::Dev.compile_all



# when cmd == "compile" && args.first? == "shard.yml"
#   :ignore

# when cmd == "compile" && args.size == 1 && args.first[/.(jspp|sass|styl)$/]?
#   MEGAUNI::Dev.compile(args.shift)

# when full_cmd == "migrate reset tables"
#   # === {{CMD}} migrate reset tables
#   exit 1 if !DA.is_development?
#   MEGAUNI::SQL.reset_tables!

# when full_cmd == "migrate"
#   # === {{CMD}} migrate
#   MEGAUNI::SQL.migrate

# when full_cmd == "migrate dump"
#   # === {{CMD}} migrate dump
#   MEGAUNI::SQL.migrate_dump

# when full_cmd == "migrate force"
#   # === {{CMD}} migrate force
#   MEGAUNI.development!
#   MEGAUNI::SQL.migrate_force

# when full_cmd == "migrate reset"
#   # === {{CMD}} migrate reset
#   MEGAUNI.development!
#   MEGAUNI::SQL.reset!

# when full_cmd == "hex colors"
#   # === {{CMD}} hex colors
#   # ===   Generate an html file of the color palette.
#   MEGAUNI::Dev.hex_colors_file

# when full_cmd == "upgrade"
#   MEGAUNI::Dev.upgrade


else
  DA_Dev.red! "!!! {{Invalid arguments}}: BOLD{{#{ARGV.map(&.inspect).join ' '}}}"
  exit 1

end # === case


require "inspect_bang"
require "da"
require "da_dev"
require "../src/megauni"
# require "../src/megauni/Dev/*"
# require "../src/megauni/SQL/*"

full_cmd = ARGV.join(' ')
args     = ARGV.dup
cmd      = args.shift

case

when {"-h", "help", "--help"}.includes?(full_cmd)
  # === {{CMD}} help|-h|--help
  DA::CLI.print_doc

when full_cmd == "migrate up"
  Dir.cd DA.app_dir
  DA.orange! "=== {{migrating}} up..."

  # current = %w[role database enum function table].reduce({} of String => Array(String)) { |acc, t|
  #   acc[t] = case
  #            when t == "function"
  #              [] of String
  #            else
  #              Megauni_PG.psql("template1", "sql/#{t}.sql").split.map(&.strip).reject(&.empty?)
  #            end
  #   acc
  # }
  # cluster = MEGAUNI::PostgreSQL::Database_Cluster.new(311, "pg-megauni", "megauni_db", "base")
  # cluster.migrate("migrate/megauni_db")
  MEGAUNI::PostgreSQL.migrate_up

when full_cmd == "postgresql start dev"
  # === {{CMD}} postgresql start dev
  Process.exec("sudo", "chpst -u pg-megauni:pg-megauni bin/megauni postgresql start".split);

when full_cmd == "postgresql start"
  # === {{CMD}} postgresql start
  MEGAUNI::PostgreSQL.start


when full_cmd[/http start \d+/]?
  # === {{CMD}} http start PORT
  MEGAUNI.http_start(ARGV.last.not_nil!.to_i)

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
#   exit 1 if !DA.development?
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

when full_cmd == "psql" && DA.development?
  # === {{CMD}} psql # Only when run on a development machine.
  MEGAUNI::PostgreSQL.exec_psql

when full_cmd[/^as [a-zA-Z\_\-0-9]+ psql( .+)?/]?
  # === {{CMD}} psql USER cmd ...
  Dir.cd DA.app_dir
  args     = ARGV[3..-1]
  username = ARGV[1]
  histfile = "/tmp/#{username}.psql.histfile"

  args = "-u #{username} #{MEGAUNI::PostgreSQL.prefix}/bin/psql --set=HISTFILE=#{histfile} --port=#{MEGAUNI::PostgreSQL.port}".split.concat(args)

  DA.orange! "=== in #{Dir.current}: {{sudo}} BOLD{{#{args.join ' '}}}"
  Process.exec("sudo", args)

else
  DA_Dev.red! "!!! {{Invalid arguments}}: BOLD{{#{ARGV.map(&.inspect).join ' '}}}"
  exit 1

end # === case

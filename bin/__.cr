
require "inspect_bang"
require "da"
require "da_dev"
require "../src/megauni"

full_cmd = ARGV.join(' ')
args     = ARGV.dup
cmd      = args.shift

case

when full_cmd[/^(-h|help|--help)( .+)?/]?
  # === {{CMD}} help|-h|--help
  DA.print_help

when full_cmd == "postgresql start dev"
  # === {{CMD}} postgresql start dev
  Process.exec("sudo", "chpst -u pg-megauni:pg-megauni bin/megauni postgresql start".split);

when full_cmd == "postgresql start"
  # === {{CMD}} postgresql start
  MEGAUNI.postgresql.start

when full_cmd == "postgresql migrate up"
  # == {{CMD}} postgresql migrate up
  Dir.cd DA.app_dir
  DA.orange! "=== {{migrating}} up..."
  MEGAUNI.postgresql.migrate_up

when full_cmd == "postgresql reset cluster"
  # === {{CMD}} postgresql reset cluster
  # Runs only on a development machine.
  # Drops the database and all non-super_user roles.
  MEGAUNI.postgresql.reset!

when full_cmd[/http start \d+/]?
  # === {{CMD}} http start PORT
  MEGAUNI.http_start(ARGV.last.not_nil!.to_i)

when full_cmd == "hex colors"
  # === {{CMD}} hex colors
  #   Generate an html file of the color palette.
  MEGAUNI::Dev.hex_colors_file

when full_cmd[/^psql( [a-z0-9\_]{1,15})?$/]? && DA.development?
  # === {{CMD}} psql
  # === {{CMD}} psql name
  # Only when run on a development machine.
  MEGAUNI.postgresql.exec_psql(ARGV[1]? || MEGAUNI.postgresql.database_name)

when full_cmd[/^as [a-zA-Z\_\-0-9]+ psql( .+)?/]?
  # === {{CMD}} psql USER cmd ...
  Dir.cd DA.app_dir
  args     = ARGV[3..-1]
  username = ARGV[1]
  histfile = "/tmp/#{username}.psql.histfile"

  args = %<
    -u #{username}
    #{MEGAUNI.postgresql.prefix}/bin/psql
    --set=HISTFILE=#{histfile}
    --port=#{MEGAUNI.postgresql.port}
  >.split.concat(args)

  DA.orange! "=== in #{Dir.current}: {{sudo}} BOLD{{#{args.join ' '}}}"
  Process.exec("sudo", args)

else
  DA_Dev.red! "!!! {{Invalid arguments}}: BOLD{{#{ARGV.map(&.inspect).join ' '}}}"
  exit 1

end # === case

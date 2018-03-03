
require "da_dev"

args = ARGV.dup

cmd = args.shift?

case cmd
when "file-change"
  DA_Dev.orange! "=== not done: file-change: #{ARGV}"
else
  DA_Dev.red! "!!! {{Invalid options}}: BOLD{{#{ARGV.map(&.inspect).join " "}}}"
end

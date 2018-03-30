
require "inspect_bang"
require "da_spec"
require "da_dev"

extend DA_SPEC

if !ARGV.empty?
  DA_SPEC.pattern ARGV.join(" ")
  DA_Dev.orange! "=== {{Pattern}}: BOLD{{#{ARGV.join ' '}}}"
end

def strip(raw : String)
  raw.strip.split("\n").map(&.strip).join("\n")
end # === def strip

def create_members(count : Int32)
  fin = [] of MEGAUNI::Screen_Name
  MEGAUNI::SQL.reset_tables!
  count.times { |i|
    fin << MEGAUNI::Member.create("sn_#{i}", DEFAULT_PASSWORD,  DEFAULT_PASSWORD)
  }
  fin
end # === def create_members

require "../src/megauni"
require "./css/*"
require "./sql/*"


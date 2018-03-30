
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

module DA_SPEC
  class Describe

    def it(name : String)
      x = It.new(self, name)
      if DA_SPEC.matches?(x)
        begin
          with x yield
        rescue ex : PQ::PQError
          puts_header
          x.print_fail "(", ex.class.to_s, ") ", ex.message.colorize.mode(:bold)
          ex.fields.each { |err|
            DA_Dev.red! err.inspect
            DA_Dev.red! "==============================="
          }
          exit 1
        rescue ex
          puts_header
          x.print_fail "(", ex.class.to_s, ") ", ex.message.colorize.mode(:bold)
          count = 0
          ex.backtrace.each { |line|
            puts line
            count += 1
            break if count > 15
          }
          exit 1
        end
      end
    end # === def it

  end # === class Describe
end # === module DA_SPEC

require "./css/*"
require "./sql/*"


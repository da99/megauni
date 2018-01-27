
require "inspect_bang"
require "da_spec"
require "../src/megauni"

extend DA_SPEC

def strip(raw : String)
  raw.strip.split("\n").map(&.strip).join("\n")
end # === def strip

require "./css/*"

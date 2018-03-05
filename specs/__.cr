
require "inspect_bang"
require "da_spec"

extend DA_SPEC

def strip(raw : String)
  raw.strip.split("\n").map(&.strip).join("\n")
end # === def strip

require "../src/megauni"
require "./css/*"


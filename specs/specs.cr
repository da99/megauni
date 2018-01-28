
require "inspect_bang"
require "da_spec"

extend DA_SPEC

if !ENV["RUN_SPECS"]?
  DA_SPEC.skip_all!
end

def strip(raw : String)
  raw.strip.split("\n").map(&.strip).join("\n")
end # === def strip

require "./css/*"

Process.exit(0) if ENV["RUN_SPECS"]?

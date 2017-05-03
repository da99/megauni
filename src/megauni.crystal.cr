require "./megauni.crystal/version"

require "kemal"
require "kemal-session"

get "/" do
  "hello"
end

Kemal.run

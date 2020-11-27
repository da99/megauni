
require "da_spec"
require "http/client"

extend DA_SPEC

def relative_hrefs(path)
  match = request_body!(path).match(/href="(\/[^\"]+)"/)
  case match
  when Nil
    [] of String
  else
    match.to_a.compact[1..-1]
  end
end # def

def request!(path)
  HTTP::Client.get("https://www.megauni.com#{path}")
end

def request_body!(path)
    request!(path).body.to_s
end

def public!(path)
  File.read("./Public#{path}")
end # def

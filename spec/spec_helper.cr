
require "da_spec"
extend DA_SPEC

require "http/client"

def request(path)
    HTTP::Client.get "http://localhost:4567#{path}"
end

def request_body(path)
    request(path).body.to_s[0..200]
end

def public(path)
  File.read("./Public#{path}")[0..200]
end # def



require "http"
require "./router"

server = HTTP::Server.new(3000) do |ctx|
  MU::Router.fulfill(ctx)
end

server.listen




require "http"
require "./router"

server = HTTP::Server.new(3000) do |ctx|
  MU_ROUTER.fulfill(ctx)
end

server.listen



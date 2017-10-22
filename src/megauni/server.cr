
require "http"
require "./router"
require "kemal-session"

Kemal::Session.config do |config|
  config.cookie_name = "session_id"
  config.secret = "#{ENV["HTTP_SERVER_SESSION_SECRET"]}"
  config.gc_interval = 2.minutes # 2 minutes
end

server = HTTP::Server.new(3000) do |ctx|
  MU_ROUTER.fulfill(ctx)
end

server.listen



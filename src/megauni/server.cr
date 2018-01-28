
require "kemal"
require "kemal-session"

require "html_builder"
require "./router"

Kemal::Session.config do |config|
  config.cookie_name = "session_id"
  config.secret = "#{ENV["HTTP_SERVER_SESSION_SECRET"]}"
  config.gc_interval = 2.minutes # 2 minutes
end

PORT = 3000
server = HTTP::Server.new(PORT) do |ctx|
  MEGAUNI::Router.fulfill(ctx)
end

puts "=== Starting server on port #{PORT}"
server.listen



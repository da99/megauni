

# Kemal::Session.config do |config|
#   config.cookie_name = "session_id"
#   config.secret = "#{ENV["HTTP_SERVER_SESSION_SECRET"]}"
#   config.gc_interval = 2.minutes # 2 minutes
# end

module MEGAUNI

  class Server

    getter server : HTTP::Server
    getter port : Int32

    MODELS = Set{Root}

    def initialize(@port = 3000)
      @server = HTTP::Server.new(port) do |ctx|
        Route.route!(ctx)
      end
    end # === def self.start

    def listen
      puts "=== Starting server on port #{port}"
      @server.listen
    end # === def listen

  end # === module Server

end # === module MEGAUNI




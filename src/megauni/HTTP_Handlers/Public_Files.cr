
module MEGAUNI

  struct Public_Files

    PUBLIC_DIR = File.expand_path("#{THIS_DIR}/Public")
    @@file_handler = HTTP::StaticFileHandler.new(PUBLIC_DIR, false, true)

    def self.route!(route)
      return false unless route.get?
      request = route.request

      case

      when route.path["/public"]?
        # request.path = request.path.sub("/megauni/files", "")
        @@file_handler.call(route.ctx)
        route

      when route.path == "/hello/world/"
        route.html! "<p>Hello, World: #{ request.method }</p>"

      when route.path == "/hello/the/entire/world"
        route.html! "<p>Hello, The Entire World: #{ request.method }</p>"

      # when route.path == "/session-write"
      #     route.ctx.session.string("number", Random::Secure.hex)
      #     route.html! %[
      #       <p>Your BRAND NEW session number: #{route.ctx.session.string("number")}</p>
      #     ]

      # when route.path == "/session-read"
      #     route.html! %[
      #       <p>Your session number: #{route.ctx.session.string("number")}</p>
      #     ]

      else
        return false

      end # === case

      true
    end # === def self.route!

  end # === struct Public

end # === module MEGAUNI

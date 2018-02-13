
module MEGAUNI

  struct Public

    PUBLIC_DIR = "#{File.expand_path "#{__DIR__}/../../../.."}/Public"
    @@file_handler = HTTP::StaticFileHandler.new(PUBLIC_DIR, false, true)

    def self.route!(route)
      return false unless route.get?
      request = route.request

      case

      when route.path["/megauni/files"]?
        request.path = request.path.sub("/megauni/files", "")
        @@file_handler.call(route.ctx)
        route

      when route.path == "/hello/world/"
      if_defined(MEGAUNI) do
        puts "Kemal has been defined."
      end
        route.html! "<p>Hello, World: #{ request.method }</p>"

      when route.path == "/hello/the/entire/world"
        route.html! "<p>Hello, The Entire World: #{ request.method }</p>"


      when route.path == "/session-write"
        if_defined(Kemal::Session) do
          route.ctx.session.string("number", Random::Secure.hex)
          route.html! %[
            <p>Your BRAND NEW session number: #{route.ctx.session.string("number")}</p>
          ]
        end

      when route.path == "/session-read"
        if_defined(Kemal::Session) do
          route.html! %[
            <p>Your session number: #{route.ctx.session.string("number")}</p>
          ]
        end

      else
        return false

      end # === case

      true
    end # === def self.route!

  end # === struct Public

end # === module MEGAUNI
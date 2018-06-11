
module MEGAUNI
  class Surfer_Hearts

    include HTTP::Handler

    def initialize
    end # === def initialize

    def call(ctx)
      host = ctx.request.host
      path = ctx.request.path

      if host == "www.surferhearts.com"
        new_address = File.join("http://www.megauni.com/surferhearts", path)
        ctx.response.headers["Location"] = new_address
        ctx.response.status_code = 301
        return ctx
      end

      if path.index("/surferhearts") == 0
        path = ctx.request.path

        case
        when path == "/"
          path = "/index.html"

        when path == "/surferhearts" || path == "/surferhearts/"
          path = "/surferhearts/index.html"

        when path[-1] == '/'
          path = "#{path.rstrip('/')}.html"

        end # case

        ctx.request.path = path
      end

      return call_next(ctx)
    end # === def call

  end # === class Surfer_Hearts
end # === module MEGAUNI

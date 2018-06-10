
module MEGAUNI
  class Surfer_Hearts

    include HTTP::Handler

    def initialize
    end # === def initialize

    def call(ctx)
      host = ctx.request.host
      if host != "www.surferhearts.com"
        return call_next(ctx)
      end

      old_path = ctx.request.path

      case
      when old_path == "/"
        old_path = "/index.html"

      when old_path[-1] == '/'
        old_path = "#{old_path.rstrip('/')}.html"

      end # case

      ctx.request.path = File.join("/surferhearts", old_path)

      return call_next(ctx)
    end # === def call

  end # === class Surfer_Hearts
end # === module MEGAUNI


module MEGAUNI
  class Surfer_Hearts

    include HTTP::Handler

    @public_file_handler : HTTP::Handler
    @dir : String

    def initialize
      @dir = if DA.development?
              "/apps/surferhearts/Public"
            else
              DA_Deploy::App.new("surferhearts").public_dir
            end
      @public_file_handler = DA_Server::Public_Files.new(@dir)
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

      case
      when path == "/surferhearts"
        path = "/index"
      when path.index("/surferhearts") == 0
        path = path.sub("/surferhearts", "")
      end

      if path == "/rss"
        path = "/rss.xml"
        return DA_Server.redirect_to(302, "/rss.xml", ctx)
      end

      if !File.file?(File.join(@dir, path))
        path = "#{path}.html"
      end

      ctx.request.path = path
      return @public_file_handler.call(ctx)

      return call_next(ctx)
    end # === def call

  end # === class Surfer_Hearts
end # === module MEGAUNI

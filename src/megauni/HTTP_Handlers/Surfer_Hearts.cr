
module MEGAUNI
  class Surfer_Hearts

    include HTTP::Handler

    @public_file_handler : HTTP::Handler

    def initialize
      dir = if DA.is_development?
              "/apps/surferhearts/Public"
            else
              DA_Deploy::App.new("surferhearts").public_dir
            end
      @public_file_handler = HTTP::StaticFileHandler.new(dir)
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
        path = path.sub("/surferhearts", "")

        case
        when path == "/"
          path = "/index.html"

        when path[-1] == '/'
          path = "#{path.rstrip('/')}.html"

        end # case

        ctx.request.path = path
        return @public_file_handler.call(ctx)
      end

      return call_next(ctx)
    end # === def call

  end # === class Surfer_Hearts
end # === module MEGAUNI

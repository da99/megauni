
module MEGAUNI
  class Megauni_Archive

    include HTTP::Handler

    def initialize
    end # === def initialize

    def call(ctx)
      path = ctx.request.path
      pieces = path.strip('/').split('/')

      name = case
             when pieces.size == 1 && pieces.last == "salud"
               pieces.last
             when (pieces.size == 2 && pieces.first == "uni")
               pieces.last
             end

      if !name
        return call_next(ctx)
      end

      ctx.response.headers["Location"] = "/@#{name}"
      ctx.response.status_code         = 302
      ctx
    end # === def call

  end # === class Megauni_Archive
end # === module MEGAUNI

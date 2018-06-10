
module MEGAUNI
  class Index_File

    include HTTP::Handler

    def initialize
    end # === def initialize

    def call(ctx)
      old_path = ctx.request.path
      if old_path == "/"
        ctx.request.path = "/index.html"
      end
      return call_next(ctx)
    end # === def call

  end # === class Index_File
end # === module MEGAUNI

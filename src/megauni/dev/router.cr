
struct MU_DEV_ROUTER

  @@file_handler = HTTP::StaticFileHandler.new("Public", false, true)

  getter :ctx
  def initialize(@ctx : HTTP::Server::Context)
  end # === def initialize

  def get_homepage
    ctx.request.path = "/root/main.html"
    @@file_handler.call(ctx)
  end # === def get_root

  def get_file(folder : String, filename : String)
    ctx.request.path = ctx.request.path.sub("/megauni/files", "")
    @@file_handler.call(ctx)
  end

end # === struct MU_DEV_ROUTER

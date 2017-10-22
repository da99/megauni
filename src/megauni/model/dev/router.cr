
struct MU_DEV_ROUTER

  @@file_handler = HTTP::StaticFileHandler.new("Public", false, true)

  getter :ctx
  def initialize(@ctx : HTTP::Server::Context)
  end # === def initialize

  macro write_html
    ctx.response.content_type = "text/html; charset=utf-8"
    ctx.response << (
      MU_HTML.to_html {
        {{yield}}
      }
    )
  end

  def get_write_session
    ctx.session.string("number", SecureRandom.hex)
    write_html {
      p { "Your BRAND NEW session number: #{ctx.session.string("number")}" }
    }
  end # === def get_write_session

  def get_read_session
    write_html {
      p { "Your session number: #{ctx.session.string("number")}" }
    }
  end # === def get_write_session

  def get_homepage
    ctx.request.path = "/root/main.html"
    @@file_handler.call(ctx)
  end # === def get_root

  def get_file(folder : String, filename : String)
    ctx.request.path = ctx.request.path.sub("/megauni/files", "")
    @@file_handler.call(ctx)
  end

end # === struct MU_DEV_ROUTER


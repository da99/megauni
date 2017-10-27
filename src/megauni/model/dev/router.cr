
struct MU_DEV_ROUTER

  include DA_ROUTER

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

  {% if env("DEVELOPMENT") %}
    get "/" do
      ctx.request.path = "/root/main.html"
      @@file_handler.call(ctx)
    end # === def get_root

    get "/megauni/files/:folder/:filename" do |folder, filename|
      ctx.request.path = ctx.request.path.sub("/megauni/files", "")
      @@file_handler.call(ctx)
    end

    get "/write" do
      ctx.session.string("number", SecureRandom.hex)
      write_html {
        p { "Your BRAND NEW session number: #{ctx.session.string("number")}" }
      }
    end # === def get_write_session

    get "/read" do
      write_html {
        p { "Your session number: #{ctx.session.string("number")}" }
      }
    end # === def get_write_session

  {% end %}

end # === struct MU_DEV_ROUTER


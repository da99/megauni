
require "da_router"
require "./html"
require "./root/router"

{% if env("DEVELOPMENT") %}
  require "./dev/router"
{% end %}

class MU_ROUTER

  include DA_ROUTER

  getter ctx : HTTP::Server::Context
  def initialize(@ctx)
  end # === def initialize

  macro write_html
    ctx.response.content_type = "text/html; charset=utf-8"
    ctx.response << (
      MU_HTML.to_html {
        {{yield}}
      }
    )
  end

  def get_hello
    write_html { p { "Hello, World: #{ ctx.request.method }" } }
  end # === def get_hello

  def get_hello_more
    write_html { p { "Hello, The Entire World: #{ ctx.request.method }" } }
  end # === def get_hello_more

  def self.fulfill(ctx)
    route(ctx) do
      {% if env("DEVELOPMENT") %}
        get("/", MU_DEV_ROUTER, :homepage)
        get("/megauni/files/:folder/:filename", MU_DEV_ROUTER, :file)
        get("/write", MU_DEV_ROUTER, :write_session)
        get("/read", MU_DEV_ROUTER, :read_session)
      {% end %}

      get("/hello/world", MU_ROUTER, :hello)
      get("/hello/the/entire/world", MU_ROUTER, :hello_more)

      ctx.response.status_code = 404
      ctx.response << "missing: #{ ctx.request.method } #{ctx.request.path}"
    end
  end

end # === class MU_ROUTEr


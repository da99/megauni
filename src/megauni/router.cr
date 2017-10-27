
require "da_router"
require "./html"
require "./model/root/router"

{% if env("DEVELOPMENT") %}
  require "./model/dev/router"
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

  get "/hello/world" do
    write_html { p { "Hello, World: #{ ctx.request.method }" } }
  end # === def get_hello

  get("/hello/the/entire/world") do
    write_html { p { "Hello, The Entire World: #{ ctx.request.method }" } }
  end # === def get_hello_more

  def self.fulfill(ctx)
    DA_ROUTER.route!(ctx)

    ctx.response.status_code = 404
    ctx.response << "missing: #{ ctx.request.method } #{ctx.request.path}"
  end

end # === class MU_ROUTEr


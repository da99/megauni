
require "da_router"
require "./html"
require "./model/root/router"

{% if env("IS_DEV") %}
  require "./model/dev/router"
{% end %}

class MU_ROUTER

  include DA_ROUTER

  getter ctx : HTTP::Server::Context
  def initialize(@ctx)
  end # === def initialize

  macro html(raw)
    ctx.response.content_type = "text/html; charset=utf-8"
    ctx.response << (
      MU_HTML.to_html(
        {{raw}}
      )
    )
  end

  get "/hello/world" do
    html "<p>Hello, World: #{ ctx.request.method }</p>"
  end # === def get_hello

  get("/hello/the/entire/world") do
    html "<p>Hello, The Entire World: #{ ctx.request.method }</p>"
  end # === def get_hello_more

  def self.fulfill(ctx)
    DA_ROUTER.route!(ctx)

    ctx.response.status_code = 404
    ctx.response << "missing: #{ ctx.request.method } #{ctx.request.path}"
  end

end # === class MU_ROUTEr


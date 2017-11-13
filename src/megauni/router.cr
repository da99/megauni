
require "da_router"

module MU_ROUTER

  include DA_ROUTER
  macro included
    include DA_ROUTER
  end # === macro included

  getter ctx : HTTP::Server::Context
  def initialize(@ctx)
  end # === def initialize

  def html(model : String, action : String, *args)
    ctx.response.content_type = "text/html; charset=utf-8"
    ctx.response << (
      MU_HTML.to_html( model, action, *args )
    )
  end # === macro html

  def html(doc : DA_HTML::DOC, model : String, action : String)
    ctx.response.content_type = "text/html; charset=utf-8"
    ctx.response << (
      MU_HTML.new(doc, model, action).to_html
    )
  end # === def html

  def raw_html(raw : String)
    ctx.response.content_type = "text/html; charset=utf-8"
    ctx.response << (
      MU_HTML.to_html(raw)
    )
  end # === macro html

end # === class MU_ROUTER

require "./model/root/router"

{% if env("IS_DEV") %}
  require "./model/dev/router"
{% end %}

module MU_ROUTER
  def self.fulfill(ctx)
    DA_ROUTER.route!(ctx)
    ctx.response.status_code = 404
    ctx.response << "missing: #{ ctx.request.method } #{ctx.request.path}"
  end
end # === module MU_ROUTER


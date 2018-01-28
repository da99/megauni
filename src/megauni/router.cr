
require "da_router"

module MEGAUNI

  module Router

    include DA_ROUTER

    macro included
      include DA_ROUTER
    end # === macro included

    getter ctx : HTTP::Server::Context
    def initialize(@ctx)
    end # === def initialize

    # def html(doc : DA_HTML::Doc, model : String, action : String)
    #   ctx.response.content_type = "text/html; charset=utf-8"
    #   html = MEGAUNI::HTML.new(doc, model, action).to_html
    #   ctx.response << (
    #     html
    #   )
    # end # === def html

    def raw_html(raw : String)
      ctx.response.content_type = "text/html; charset=utf-8"
      ctx.response << (
        # MEGAUNI::HTML.to_html(raw)
        raw
      )
    end # === macro html

  end # === module ROUTER

end # === class MU_ROUTER

require "./model/root_for_public/router"

{% if env("IS_DEV") %}
  require "./model/dev/router"
{% end %}

module MEGAUNI
  module Router

    def self.fulfill(ctx)
      DA_ROUTER.route!(ctx)
      ctx.response.status_code = 404
      ctx.response << "missing: #{ ctx.request.method } #{ctx.request.path}"
    end

  end # === module Router
end # === module MU_ROUTER


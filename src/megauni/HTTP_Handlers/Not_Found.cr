
module MEGAUNI

  class Not_Found

    include HTTP::Handler

    # =============================================================================
    # Instance:
    # =============================================================================

    def initialize
    end # === def initialize

    def call(ctx)
      ctx.response.status_code = 404
      ctx.response << "Not found: #{ ctx.request.method } #{ctx.request.path}"
      {% if env("IS_DEVELOPMENT") %}
        DA.red! "!!! \{{Not found}}: BOLD\{{#{ctx.request.method}}} #{ctx.request.path}"
      {% end %}

      ctx
    end # === def run

  end # === struct Not_Found

end # === module MEGAUNI

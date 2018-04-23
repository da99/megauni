
module MEGAUNI

  struct Not_Found

    # =============================================================================
    # Struct:
    # =============================================================================

    def self.route!(route)
      new(route).run
    end

    # =============================================================================
    # Instance:
    # =============================================================================

    getter route : Route
    getter route_name  = "Not_Found"
    def initialize(@route)
    end # === def initialize

    def run
      ctx = route.ctx
      ctx.response.status_code = 404
      ctx.response << "Not found: #{ ctx.request.method } #{ctx.request.path}"
      {% if env("IS_DEVELOPMENT") %}
        DA_Dev.red! "!!! \{{Not found}}: BOLD\{{#{ctx.request.method}}} #{ctx.request.path}"
      {% end %}

      route
    end # === def run

  end # === struct Not_Found

end # === module MEGAUNI

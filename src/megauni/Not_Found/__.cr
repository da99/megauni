
module MEGAUNI

  struct Not_Found

    def self.route!(route)
      ctx = route.ctx
      ctx.response.status_code = 404
      ctx.response << "Not found: #{ ctx.request.method } #{ctx.request.path}"
      {% if env("IS_DEV") %}
        DA_Dev.red! "!!! \{{Not found}}: BOLD\{{#{ctx.request.method}}} #{ctx.request.path}"
      {% end %}

      route
    end

  end # === struct Not_Found

end # === module MEGAUNI

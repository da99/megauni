
require "../../../mu_html"
struct MU_ROOT_ROUTER

  include MU_ROUTER

  getter :ctx
  def initialize(@ctx : HTTP::Server::Context)
  end # === def initialize

  MAIN_DOC = MU_HTML.parse("root", "main")

  get("/") do
    html(*MAIN_DOC)
  end

end # === module MU_ROOT_ROUTER

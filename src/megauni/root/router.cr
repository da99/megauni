
struct MU_ROOT_ROUTER

  getter :ctx
  def initialize(@ctx : HTTP::Server::Context)
  end # === def initialize

end # === module MU_ROOT_ROUTER

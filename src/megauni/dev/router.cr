
struct MU_DEV_ROUTER

  getter :ctx
  def initialize(@ctx : HTTP::Server::Context)
  end # === def initialize

  def get_homepage
    get_file("root", "main.html")
  end # === def get_root

  def get_file(folder : String, filename : String)
    data = File.read("Public/#{folder}/#{filename}")
    ctx.response.content_type = mime_type(filename)
    ctx.response.content_length = data.bytesize
    ctx.response << data
  end

  def mime_type(filename : String)
    ext = File.extname(filename)
    case ext
    when ".html"
      "text/html"
    when ".css"
      "text/css"
    when ".js"
      "application/javascript"
    else
      "text/plain"
    end
  end # === def mime_type

end # === struct MU_DEV_ROUTER

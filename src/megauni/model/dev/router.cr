
module MEGAUNI

  struct DEV_ROUTER

    include Router

    @@file_handler = HTTP::StaticFileHandler.new("Public", false, true)

    get "/hello/world" do
      raw_html "<p>Hello, World: #{ ctx.request.method }</p>"
    end # === def get_hello

    get("/hello/the/entire/world") do
      raw_html "<p>Hello, The Entire World: #{ ctx.request.method }</p>"
    end # === def get_hello_more


    get "/megauni/files/:folder/:filename" do |folder, filename|
      ctx.request.path = ctx.request.path.sub("/megauni/files", "")
      @@file_handler.call(ctx)
    end

    get "/session-write" do
      ctx.session.string("number", Random::Secure.hex)
      raw_html %[
      <p>Your BRAND NEW session number: #{ctx.session.string("number")}</p>
      ]
    end # === def get_write_session

    get "/session-read" do
      raw_html %[
      <p>Your session number: #{ctx.session.string("number")}</p>
      ]
    end # === def get_write_session

  end # === struct MU_DEV_ROUTER

end # === module MEGAUNI



module MEGAUNI

  struct Root_For_Public

    include Router

    getter :ctx
    def initialize(@ctx : HTTP::Server::Context)
    end # === def initialize

    # MAIN_DOC = MEGAUNI::HTML.parse("root", "main")

    get("/") do
      # html(*MAIN_DOC)
      raw_html(::HTML.build do
        a(href: "http://crystal-lang.org") do
          text "crystal is awesome"
        end
      end)
    end # === get

  end # === module Root_For_Public

end # === module MEGAUNI


module MEGAUNI

  struct Root_For_Public

    getter ctx : HTTP::Server::Context
    def initialize(@ctx)
    end # === def initialize

    def root
      # html(*MAIN_DOC)
      DA_HTML.to_html do
        a(href: "http://crystal-lang.org") do
          text "crystal is awesome"
        end
      end
    end # === get

  end # === module Root_For_Public

end # === module MEGAUNI

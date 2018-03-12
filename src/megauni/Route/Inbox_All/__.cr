
require "./*"

module MEGAUNI
  struct Inbox_All

    # =============================================================================
    # Struct:
    # =============================================================================

    def self.route!(route)
      if route.get?("/inbox")
        new(route).all
        return true
      end

      false
    end # def self.route

    # =============================================================================
    # Instance:
    # =============================================================================


    getter route : Route
    getter route_name = "Inbox_All"

    def initialize(@route)
    end # === def initialize

    def all
      route.html!(
        ::MEGAUNI::HTML.to_html do
          doctype!
          html {
            head_defaults!
            default_stylesheets!
            link("MUE/desktop.css")
            link("#{route_name}/desktop.css")
            head {
              title { "/inbox #{MEGAUNI.site_name}" }
            } # === head
            body {
              markup_nav
            } # === body
          } # === html
        end # === HTML
      ) # === route.html!
    end # === def all

  end # === class Inbox_All
end # === module MEGAUNI

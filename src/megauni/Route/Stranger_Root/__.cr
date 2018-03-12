
require "./*"

module MEGAUNI

  class Stranger_Root

    # =============================================================================
    # Class:
    # =============================================================================

    def self.route!(route)
      if route.get?("/")
        new(route).root
        return true
      end

      false
    end # def self.route

    # =============================================================================
    # Instance:
    # =============================================================================

    getter route : Route
    getter route_name = "Stranger_Root"

    def initialize(@route)
    end # === def initialize

    def root
      route.html!(
        ::MEGAUNI::HTML.to_html do
          doctype!
          html {

            head {
              head_defaults!
              default_stylesheets!
              link("MUE/desktop.css")
              link("#{route_name}/desktop.css")
              title { "#{MEGAUNI.site_name}: Home" }
              meta("Description", "Sign-In or Create an Account if you don't have one.")
            }

            body {
              markup_nav

              markup_log_in
              markup_create_a_new_account
            } # body

            script!
          } # === html
        end
      ) # === route.html!
    end # === def root

  end # === class Root

end # === module MEGAUNI

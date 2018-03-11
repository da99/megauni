
require "./*"

module MEGAUNI

  class Desktop_Stranger_Root

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
    getter route_name = "Desktop/Stranger_Root"

    def initialize(@route)
    end # === def initialize

    def root
      route.html!(
        ::MEGAUNI::HTML.to_html do
          doctype!
          html {

            head {
              head_defaults!
              stylesheet!
              title { "#{MEGAUNI.site_name}: Home" }
              meta("Description", "Sign-In or Create an Account if you don't have one.")
            }

            body {

              header("#site") {
                h1 { MEGAUNI.site_name }
              }

              markup_footer

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

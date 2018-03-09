
module MEGAUNI

  class Stranger_Root

    # =============================================================================
    # Class:
    # =============================================================================

    def self.route!(route)
      path = route.ctx.request.path
      case

      when path == "/"
        new(route).root

      when path == "/hello/world"
        route.text! "#{route.ctx.request.path} Hello world!"

      else
        return false

      end # === case

      true
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
          html {
            head {
              utf8!
              script!
              stylesheet!
              title { "Home" }
            }
            body {
              a(href: "http://crystal-lang.org") { "crystal is awesome" }
            }
          }
        end
      )
    end # === def root

  end # === class Root

end # === module MEGAUNI

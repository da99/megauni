
module MEGAUNI

  class Stranger_Root

    def self.route!(route)
      path = route.ctx.request.path
      case

      when path == "/"
        route.html!(
          DA_HTML.to_html do
            a(href: "http://crystal-lang.org") { "crystal is awesome" }
          end
        )

      when path == "/hello/world"
        route.text! "#{route.ctx.request.path} Hello world!"

      else
        return false

      end # === case

      true
    end # def self.route

  end # === class Root

end # === module MEGAUNI

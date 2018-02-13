
module MEGAUNI

  class Root

    def self.route!(route)
      path = route.ctx.request.path
      case

      when path == "/"
        route.text! "#{route.ctx.request.path} from ROOT"

      when path == "/hello/world"
        route.text! "#{route.ctx.request.path} Hello world!"

      else
        return false

      end # === case

      true
    end # def self.route

  end # === class Root

end # === module MEGAUNI

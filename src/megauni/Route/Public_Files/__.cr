
module MEGAUNI

  class Public_Files
    include HTTP::Handler

    def initialize
      dir = File.join(File.dirname(Process.executable_path.not_nil!), "../Public")
      @file_handler = HTTP::StaticFileHandler.new(dir, false, true)
    end # === def initialize

    def self.route!(route)
      return false unless route.get?
      request = route.request

      case

      when route.path["/public"]?
        # request.path = request.path.sub("/megauni/files", "")
        @@file_handler.call(route.ctx)
        route

      else
        return false

      end # === case

    end # === def self.route!

  end # === struct Public

end # === module MEGAUNI

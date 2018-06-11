
require "da_deploy"
require "da_server"
require "./megauni/HTTP_Handlers/Megauni_Archive"
require "./megauni/HTTP_Handlers/Surfer_Hearts"
require "./megauni/HTTP_Handlers/Index_File"
require "./megauni/HTTP_Handlers/Not_Found"

module MEGAUNI

  class Error < Exception
  end

  # SECRET      = "#{ENV["HTTP_SERVER_SESSION_SECRET"]}"
  COOKIE_NAME = "mu_session"

  MIN_SCREEN_NAME = 3
  MAX_SCREEN_NAME = 10
  MIN_PASS_PHRASE = 8
  MAX_PASS_PHRASE = 100

  # =============================================================================
  # Module:
  # =============================================================================

  def self.app_dir
    File.dirname(File.dirname(Process.executable_path.not_nil!))
  end # === def self.app_dir

  def self.site_name
    "megaUNI.com"
  end

  def self.route_name(file : String)
    return File.basename(File.dirname(file))
  end

  def self.route_file(file : String)
    route_name = self.route_name(file)
    name = File.basename(file, File.extname(file))
    "Route/#{route_name}/#{name}"
  end

  def self.service_run
    host = DA.is_development? ? "localhost" : "0.0.0.0"
    port = DA.is_development? ? 4567 : 340
    user = DA.is_development? ? `whoami`.strip : "www-deployer"
    public_dir = File.join(File.dirname(Process.executable_path.not_nil!), "../Public")

    DA.orange! "=== Using public dir: #{public_dir}"
    DA_Server.new(host, port, user, [
      Index_File.new,
      Surfer_Hearts.new,
      HTTP::StaticFileHandler.new(
        public_dir,
        fallthrough: false,
        directory_listing: false
      ),
      Not_Found.new
    ]).listen
  end # === def self.service_run

end # === module MEGAUNI


# require "./megauni/SQL/__"

# require "./megauni/Model/Member/__"
# require "./megauni/Model/Screen_Name/__"
# require "./megauni/Model/Message_Folder/__"
# require "./megauni/Model/Message_Receive_Command/__"
require "./megauni/HTML"
require "./megauni/CSS"

# require "./megauni/Route"
# require "./megauni/Server"

# require "./megauni/Route/Stranger_Root/__"
# require "./megauni/Route/Inbox_All/__"




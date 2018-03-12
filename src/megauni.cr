
module MEGAUNI

  class Error < Exception
  end

  SECRET      = "#{ENV["HTTP_SERVER_SESSION_SECRET"]}"
  COOKIE_NAME = "mu_session"

  MIN_SCREEN_NAME = 3
  MAX_SCREEN_NAME = 10
  MIN_PASS_PHRASE = 8
  MAX_PASS_PHRASE = 100

  # =============================================================================
  # Module:
  # =============================================================================
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

end # === module MEGAUNI

require "./megauni/Screen_Name"
require "./megauni/HTML"
require "./megauni/CSS"

require "./megauni/Route"
require "./megauni/Server"

{% if env("IS_DEV") %}
  require "./megauni/Public_Files/__"
{% end %}
require "./megauni/Route/Stranger_Root/__"
require "./megauni/Not_Found/__"



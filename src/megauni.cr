
module MEGAUNI

  THIS_DIR = File.expand_path("#{__DIR__}/..")
  class Error < Exception
  end

  class Query_Error < Error
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

  def self.dev?
    ENV["IS_DEV"]?
  end

  def self.route_name(file : String)
    return File.basename(File.dirname(file))
  end

  def self.route_file(file : String)
    route_name = self.route_name(file)
    name = File.basename(file, File.extname(file))
    "Route/#{route_name}/#{name}"
  end

  def self.production_user!
    if `whoami`.chomp != "production_user"
      DA_Dev.red! "!!! Run as BOLD{{production_user}}"
      exit 1
    end
  end # === def self.production_user

end # === module MEGAUNI

lib LibC
  fun setuid(uid_t : Int)
  fun getuid : Int
end

module MEGAUNI

  def self.uid(username : String)
    proc = DA_Process.new("id", ["-u", username])
    if proc.success?
      proc.output.to_s.strip.to_i
    else
      DA_Dev.red! proc.error.to_s
      exit proc.stat.exit_code
    end
  end # === def uid

end # === module MEGAUNI

require "./megauni/SQL/__"

require "./megauni/Model/Member/__"
require "./megauni/Model/Screen_Name/__"
require "./megauni/HTML"
require "./megauni/CSS"

require "./megauni/Route"
require "./megauni/Server"

{% if env("IS_DEV") %}
  require "./megauni/Route/Public_Files/__"
{% end %}
require "./megauni/Route/Stranger_Root/__"
require "./megauni/Route/Inbox_All/__"
require "./megauni/Route/Not_Found/__"



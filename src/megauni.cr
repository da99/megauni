
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
    pieces = file.split('/')
    if pieces.size < 3
      raise Error.new("Not enough pieces for a route name: #{file.inspect}")
    end
    "#{pieces[-3]}/#{pieces[-2]}"
  end

  def self.route_file(file : String)
    pieces = file.split('/')
    if pieces.size < 3
      raise Error.new("Not enough pieces for a route file: #{file.inspect}")
    end
    "#{pieces[-3]}/#{pieces[-2]}/#{File.basename(pieces[-1], File.extname(pieces[-1]))}"
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
require "./megauni/Desktop/Stranger_Root/__"
require "./megauni/Not_Found/__"




module MEGAUNI

  SECRET      = "#{ENV["HTTP_SERVER_SESSION_SECRET"]}"
  COOKIE_NAME = "mu_session"

  MIN_SCREEN_NAME = 3
  MAX_SCREEN_NAME = 10
  MIN_PASS_PHRASE = 8
  MAX_PASS_PHRASE = 100

end # === module MEGAUNI

require "./megauni/Screen_Name"
require "./megauni/HTML"
require "./megauni/CSS"


require "http/server"
require "./megauni/Route"
require "./megauni/Server"

{% if env("IS_DEV") %}
  require "./megauni/Public_Files/__"
{% end %}
require "./megauni/Stranger_Root/__"
require "./megauni/Not_Found/__"
# require "./route/root_for_public/router"



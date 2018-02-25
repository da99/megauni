
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
  require "./megauni/model/Public/Public"
{% end %}
require "./megauni/model/Root/Root"
require "./megauni/model/Not_Found/Not_Found"
# require "./model/root_for_public/router"



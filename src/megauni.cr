
module MEGAUNI

  MIN_SCREEN_NAME = 3
  MAX_SCREEN_NAME = 10
  MIN_PASS_PHRASE = 8
  MAX_PASS_PHRASE = 100

end # === module MEGAUNI

require "./megauni/screen_name"
require "./megauni/css"

{% if env("INCLUDE_SPECS") %}
  require "../specs/specs"
{% end %}

{% if env("INCLUDE_SERVER") %}
  require "./megauni/server"
{% end %}

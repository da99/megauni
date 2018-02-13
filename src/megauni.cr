
module MEGAUNI

  MIN_SCREEN_NAME = 3
  MAX_SCREEN_NAME = 10
  MIN_PASS_PHRASE = 8
  MAX_PASS_PHRASE = 100

  macro model_and_action(file)
    %pieces = {{file}}.split("/")
    { %pieces[-2], %pieces.last.sub(/\.[^\.]+\.cr$/, "") }
  end # === macro model_and_action

  macro model_and_action
    MU_COMMON.model_and_action(__FILE__)
  end # === macro model_and_action

end # === module MEGAUNI

require "./megauni/Screen_Name"
require "./megauni/HTML"
require "./megauni/CSS"

{% if env("IS_DEV") %}
  require "inspect_bang"
{% end %}
macro if_defined(path, &blok)
  {% if path.resolve? %}
    {{blok.body}}
  {% else %}
    puts "Not defined: {{path.id}} "
  {% end %}
end # === macro if_defined

{% if env("RUN_SPECS") %}
  require "../specs/specs"
{% end %}

{% if env("RUN_SERVER") %}
  require "http/server"

  require "./megauni/Route"
  require "./megauni/Server"

  {% if env("IS_DEV") %}
    require "./megauni/model/Public/Public"
  {% end %}
  require "./megauni/model/Root/Root"
  require "./megauni/model/Not_Found/Not_Found"
  # require "./model/root_for_public/router"

  # require "kemal"
  # require "kemal-session"
  MEGAUNI::Server.new.listen
{% end %}





{% if env("ASSET_COMPILE") %}

  require "./megauni/html"
  {% for name in `find #{__DIR__}/megauni -mindepth 2 -maxdepth 2 -type f -name *.html.cr`.split %}
    require ".{{name.gsub(/#{__DIR__}|\.cr$/, "").id}}"
  {% end %}

  require "./megauni/style"
  {% for name in `find #{__DIR__}/megauni -mindepth 2 -maxdepth 2 -type f -name *.css.cr`.split %}
    require ".{{name.gsub(/#{__DIR__}|\.cr$/, "").id}}"
  {% end %}

{% end %}


{% if env("PRODUCTION") %}
  require "./megauni/server"
{% end %}

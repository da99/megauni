

{% if env("ASSET_COMPILE") %}

  require "./megauni/html"
  require "./megauni/style"

  {% for name in `find #{__DIR__}/megauni/model -mindepth 2 -maxdepth 2 -type f -name *.cr`.split %}
    {% if name =~ /\.(html|css)\.cr$/ %}
      require ".{{name.gsub(/#{__DIR__}|\.cr$/, "").id}}"
    {% end %}
  {% end %}

{% end %}


{% if env("PRODUCTION") %}
  require "./megauni/server"
{% end %}


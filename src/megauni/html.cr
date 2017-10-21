
require "da_html"

class MU_HTML

  include DA_HTML

  def self.write(file : String)
    page = new
    with page yield
    new_html_file = "Public" + file.sub(__DIR__, "").sub(/\.cr$/, "")
    Dir.mkdir_p(File.dirname(new_html_file))
    File.write(new_html_file, page.to_html)

    puts "=== wrote: #{new_html_file}"
  end # === def self.write

end # === struct MU_HTML

{% if env("HTML_COMPILE") %}
  {% for name in `find #{__DIR__}/ -mindepth 2 -maxdepth 2 -type f -name *.html.cr`.split %}
    require "./{{name.gsub(/#{__DIR__}|\.cr$/, "").id}}"
  {% end %}
{% end %}



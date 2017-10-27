
require "da_html"
require "./common"
require "secure_random"

class MU_HTML

  include DA_HTML

  macro script!
    io.write_tag("script") do
      %pair = MU_COMMON.model_and_action(__FILE__)
      io.write_attr "type", "application/javascript"
      io.write_attr "src", "/megauni/files/#{%pair.first}/#{%pair.last}.js"
      io.write_content { }
    end
  end # === macro script

  macro stylesheet!
    %pair = MU_COMMON.model_and_action(__FILE__)
    io.write_closed_tag(
      "link",
      {"href",  "/megauni/files/#{%pair.first}/#{%pair.last}.css" },
      {"rel",   "stylesheet" },
      {"title", "Default"}
    )
  end # === def stylesheet

  macro header(&blok)
    io.write_tag("header") {
      io.write_content { {{blok.body}} }
    }
  end # === macro header

  {% for x in %w(h1 h2 h3) %}
    macro {{x.id}}(content)
      io.write_tag("{{x.id}}") {
        io.write_content { \{{content}} }
      }
    end # === macro {{x.id}}
  {% end %}

  {% for tag in %w(nav fieldset label sub legend section button) %}
    macro {{tag.id}}(*ic, **attrs, &blok)
      io.write_tag("{{tag.id}}") {
        \{% if !ic.empty? %}
          io.write_attr_id_class \{{*ic}}
        \{% end %}

        \{% for k,v in attrs %}
          io.write_attr \{{k}}, section_\{{k}}(\{{v}})
        \{% end %}

        io.write_content {
          \{{blok.body}}
        }
      }
    end # === macro {{tag.id}}
  {% end %}

  def self.write(file : String)
    pair = MU_COMMON.model_and_action(file)

    page   = new
    with page yield
    new_html_file = "Public/#{pair.first}/#{pair.last}.html"

    Dir.mkdir_p(File.dirname(new_html_file))
    File.write(new_html_file, page.to_html)

    puts "=== wrote: #{new_html_file}"
  end # === def self.write

  def logo_name
    "megaUNI"
  end

  def pass_phrase_input(prefix : String = "")
    io.write_closed_tag(
      "input",
      {"name", "#{prefix == "" ? "" : "#{prefix}_"}pass_phrase"},
      {"type", "password"},
      {"minlength", MEGAUNI::MIN_PASS_PHRASE.to_s},
      {"maxlength", MEGAUNI::MAX_PASS_PHRASE.to_s},
      {"value", ""},
      {"required"}
    )
  end # === def screen_name_input

  def screen_name_input
    io.write_closed_tag(
      "input",
      {"name", "screen_name"},
      {"type", "text"},
      {"minlength", MEGAUNI::MIN_SCREEN_NAME.to_s},
      {"maxlength", MEGAUNI::MAX_SCREEN_NAME.to_s},
      {"value", ""},
      {"required"}
    )
  end # === def screen_name_input

end # === struct MU_HTML



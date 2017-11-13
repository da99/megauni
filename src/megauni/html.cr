
require "../megauni"
require "da_html"
require "./common"
require "secure_random"

class MU_HTML

  {% begin %}
    PUBLIC_DIR = "{{ system("pwd").strip.id }}/Public"
  {% end %}

  include DA_HTML::Printer

  class Parser
    include DA_HTML::Parser

    def allow(name : String, x : XML::Node)
      case name
      when "doctype", "html"
        allow_document_tag(x)
      when "script"
        allow_html_tag(x)
      when "head", "title", "stylesheet", "utf8"
        allow_head_tag(x)
      when "body", "p", "div", "h1", "h2", "h3"
        allow_body_tag(x)
      when "fieldset", "label", "button"
        in_tree! x, "form"
        allow_body_tag(x)
      when "nav", "sub", "legend", "section"
        allow_body_tag(x)
      end # === case name
    end # === def allow
  end # === class Parser

  def to_html(i : DA_HTML::Instruction)
    %[<meta charset="UTF-8">]
    case
    when i.open_tag?("script")
      io.open_tag "script"
      io.write_attr "type", "application/javascript"
      io.write_attr "src", "/megauni/files/#{data["model!"]}/#{data["action!"]}.js"

    when i.open_tag?("stylesheet")
      io.write_closed_tag(
        "link",
        {"href",  "/megauni/files/#{data["model!"]}/#{data["action!"]}.css" },
        {"rel",   "stylesheet" },
        {"title", "Default"}
      )

    when i.open_tag?("screen_name_input")
      io.write_closed_tag(
        "input",
        {"name", "screen_name"},
        {"type", "text"},
        {"minlength", MEGAUNI::MIN_SCREEN_NAME.to_s},
        {"maxlength", MEGAUNI::MAX_SCREEN_NAME.to_s},
        {"value", ""},
        {"required"}
      )

    when i.open_tag?("pass_phrase_input")
      prefix = if doc.current.attr?
                 attr = doc.grab_current
                 attr.attr_content
               else
                 ""
               end
      io.write_closed_tag(
        "input",
        {"name", "#{prefix == "" ? "" : "#{prefix}_"}pass_phrase"},
        {"type", "password"},
        {"minlength", MEGAUNI::MIN_PASS_PHRASE.to_s},
        {"maxlength", MEGAUNI::MAX_PASS_PHRASE.to_s},
        {"value", ""},
        {"required"}
      )
    when i.close_tag?("stylesheet"), i.close_tag?("pass_phrase_input")
      :do_nothing

    else
      super

    end
  end # === def to_html

  property data = {} of String => String | Int32

  def self.to_html(html : String, data : Hash(String, String | Int32) = {} of String => String | Int32)
    page = new(html, PUBLIC_DIR)
    page.data = {"site_name" => "megaUNI"}.merge(data)
    page.to_html
  end # === def self.to_html

  def self.write_from_frile(file : String, *args)
    model, action = MU_COMMON.model_and_action(file)
    html = File.read(file)
    write(mode, action, html, *args)
  end # === def self.write

  def self.write(model : String, action : String, html : String, raw_data = {} of String => String | Int32)

    data = {
      "model!" => model,
      "action!" => action
    }.merge(raw_data)

    new_html_file = "Public/#{model}/#{action}.html"
    new_html = to_html(html, data)

    Dir.mkdir_p(File.dirname(new_html_file))
    File.write(new_html_file, new_to_html)

    puts "=== wrote: #{new_html_file}"
  end # === def self.write
end # === struct MU_HTML


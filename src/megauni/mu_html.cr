
require "../megauni"
require "da_html"
# require "secure_random"

class MU_HTML

  PATTERN_VAR       = /\{\{[A-Z0-9\_]+\}\}/
  PATTERN_VAR_SPLIT = /(#{PATTERN_VAR})/
  PATTERN_IS_VAR    = /^#{PATTERN_VAR}$/

  include DA_HTML::Printer

  def self.default_data
    {
      "SITE_NAME" => "megaUNI"
    } of String => String | Int32
  end # === def self.default_data

  def self.parse(model, action)
    { MU_HTML::Parser.new(File.read("src/megauni/model/#{model}/#{action}/markup.html")).parse, model, action}
  end # === macro parse

  # macro file_read!(model, action)
  #   begin
  #     {{ system("cat src/megauni/model/#{model}/#{action}/markup.html").strip.stringify }}
  #   end
  # end # === macro read!

  PUBLIC_DIR = "#{File.expand_path "#{__DIR__}/../.."}/Public"

  class Parser
    include DA_HTML::Parser

    def allow(name : String, x : XML::Node)
      case name
      when "doctype!", "html"
        allow_document_tag(x)
      when "script"
        allow_html_tag(x)
      when "head", "title", "stylesheet", "utf8"
        allow_head_tag(x)
      when "body", "p", "div", "h1", "h2", "h3"
        allow_body_tag(x)
      when "pass_phrase_input"
        in_tree! x, "form"
        allow_body_tag(x, confirm: //)
      when "fieldset", "label", "screen_name_input"
        in_tree! x, "form"
        allow_body_tag(x)
      when "span", "button"
        in_tree! x, "form"
        allow_body_tag(x, class: DA_HTML::SEGMENT_ATTR_CLASS)
      when "header", "nav", "sub", "legend", "section", "form"
        allow_body_tag(x)
      when "text!"
        raw = x.content
        return raw if !(raw.index("{{") && raw.index("}}"))
        raw.split(PATTERN_VAR_SPLIT).each { |str|
          if str =~ PATTERN_IS_VAR
            doc.instruct "VAR!", str.strip("{}")
          else
            doc.instruct "text", str
          end
        }
        :done

      when "span"
        allow_body_tag(x, class: DA_HTML::SEGMENT_ATTR_CLASS)
      end # === case name
    end # === def allow
  end # === class Parser

  def to_html(i : DA_HTML::Instruction)
    case
    when i.open_tag?("head")
      super
      io.raw! %[<meta charset="UTF-8">]

    when i.open_tag?("script")
      io.open_attrs "script" do
        io.write_attr "type", "application/javascript"
        io.write_attr "src", "/megauni/files/#{data["model!"]}/#{data["action!"]}.js"
      end

    when i.is?("VAR!")
      key = i.last
      if data[key]?
        io.write_text data[key].to_s
      else
        io.write_text "{{#{key}}}"
      end

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
                 attr.attr_name
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

  def self.to_html(
    html : String,
    data : Hash(String, String | Int32) = {} of String => String | Int32
  )
    page = MU_HTML.new(html, PUBLIC_DIR)
    page.data = {"site_name" => "megaUNI"}.merge(data)
    page.to_html
  end # === def self.to_html

  def self.to_html(model : String, action : String, data : Hash(String, String | Int32) = {} of String => String | Int32)
    file = "src/megauni/model/#{model}/#{action}/index.html"
    html = File.read(file)
    page = MU_HTML.new(html, PUBLIC_DIR)
    page.data = {"site_name" => "megaUNI"}.merge(data)
    page.to_html
  end # === def self.to_html

  def self.write_from_file(file : String, *args)
    model, action = MU_COMMON.model_and_action(file)
    html = File.read(file)
    write(mode, action, html, *args)
  end # === def self.write

  def self.write(model : String, action : String, html : String, raw_data = {} of String => String | Int32)
    data = {
      "model!" => model,
      "action!" => action
    }.merge!(raw_data)

    new_html_file = "Public/#{model}/#{action}.html"
    new_html = to_html(html, data)

    Dir.mkdir_p(File.dirname(new_html_file))
    File.write(new_html_file, new_to_html)

    puts "=== wrote: #{new_html_file}"
  end # === def self.write

  module INIT
    def initialize(doc, model, action)
      @doc = doc.dup
      @file_dir = PUBLIC_DIR
      @data     = self.class.default_data
      @data["model!"] = model
      @data["action!"] = action
    end # === def initialize
  end # === module INIT

  include INIT

end # === struct MU_HTML



require "da_html"

module MEGAUNI
  class HTML

    include DA_HTML::Base

    # =============================================================================
    # Class
    # =============================================================================

    def self.default_data
      {
        "SITE_NAME" => "megaUNI"
      } of String => String | Int32
    end # === def self.default_data

    def self.to_html
      page = new
      with page yield
      page.to_html
    end # === def self.to_html

    # =============================================================================
    # Instance
    # =============================================================================

    macro utf8!
      raw! %[<meta charset="UTF-8">]
    end

    macro script!
      raw! %[
      <script
        type="application/javascript"
        src="/public/#{route_name}/script.js"
      ></script>
      ]
    end

    macro stylesheet!
      raw! %[
      <link
        href="/public/basic_one/reset.css"
        rel="stylesheet"
        title="Default"
      >
      <link
        href="/public/#{route_name}/style.css"
        rel="stylesheet"
        title="Default"
      >
      ]
    end

    {% for x in %w[h1 h2 h3].map(&.id) %}
      def {{x}}(*args, **names)
        tag("{{x}}", *args, **names) do
          text? {
            with self yield
          }
        end
      end
    {% end %}

    def form(*args, **names)
      tag("form", *args, **names) {
        text? { with self yield }
      }
    end # === def form

    def fieldset
      tag("fieldset") {
        with self yield self
      }
    end

    def label
      tag("label") {
        text? { with self yield self }
      }
    end

    def meta(**args)
      inspect! args
      tag("meta") #, **args)
    end

    def header
      tag("header") {
        with self yield self
      }
    end

    def section
      tag("section") {
        with self yield self
      }
    end

    def button(*args)
      tag("button", *args) {
        with self yield
      }
    end # === def button

    def screen_name_input
      tag(
        "input",
        :required,
        name:      "screen_name",
        type:      "text",
        minlength: MEGAUNI::MIN_SCREEN_NAME.to_s,
        maxlength: MEGAUNI::MAX_SCREEN_NAME.to_s,
        value:     ""
      )
    end

    def input_text(name : String, value : String)
      tag("input", name: name, type: "text", value: "")
    end # === def input

    def input_password(name : String)
      tag("input", name: name, type: "password", value: "")
    end # === def input

    def template(**names)
      tag("template", **names) {
        with self yield self
      }
    end # === def template

    def span(*args, **names)
      tag("span", *args, **names) {
        text? { with self yield self }
      }
    end # === def span

    def nav
      tag("nav") {
        with self yield self
      }
    end # === def nav

    def button(*args, **names)
      tag("button", *args, **names) {
        text? { with self yield self }
      }
    end # === def button

    def div(*args, **names)
      tag("div", *args, **names) {
        text? { with self yield self }
      }
    end # === def div

    def pass_phrase_input(prefix : String? = nil)
      tag(
        "input",
        :required,
        name:      "#{prefix == "" ? "" : "#{prefix}_"}pass_phrase",
        type:      "password",
        minlength: MEGAUNI::MIN_PASS_PHRASE.to_s,
        maxlength: MEGAUNI::MAX_PASS_PHRASE.to_s,
        value:     ""
      )
    end # === def to_html

    def script(src : String)
      tag("script", type: "text/javascript", src: src) {
        with self yield self
      }
    end # === def script

  end # === class HTML

end # === module MEGAUNI


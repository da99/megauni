
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

    def utf8!
      raw! %[<meta charset="UTF-8">]
    end

    macro head_defaults!
      utf8!
      link_shortcut_icon
    end

    macro script!
      raw! %[
      <script
        type="application/javascript"
        src="/public/Route/#{route_name}/script.js"
      ></script>
      ]
    end

    macro default_stylesheets!
      link("/public/basic_one/reset.css")
      link("/public/styles/fonts.css")
      link("/public/styles/otfpoc.css")
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

    def fieldset(*args)
      tag("fieldset", *args) {
        with self yield self
      }
    end

    def label
      tag("label") {
        text? { with self yield self }
      }
    end

    def meta(name : String, content : String)
      tag("meta", name: name, content: content) #, **args)
    end

    def meta_no_cache
      tag(
        "meta",
        "http-equiv": "Cache-Control",
        content: "no-cache, max-age=0, must-revalidate, no-store, max-stale=0, post-check=0, pre-check=0"
      )
    end

    def link_shortcut_icon
      tag("link", rel: "shortcut icon", href: "/favicon.ico")
    end

    def link(css : String)
      href = case
             when css[0]? == '/'
               css
             else
               "/public/Route/#{css}"
             end
      tag(
        "link",
        href: href || css,
        media: "all",
        rel: "stylesheet",
        title: "Default",
        type: "text/css"
      )
    end

    {% for x in %w[ul li header footer nav section button].map(&.id) %}
      def {{x}}(*args)
        tag("{{x}}", *args) {
          with self yield self
        }
      end
    {% end %}

    def input_text(name : String, value : String)
      tag("input", name: name, type: "text", value: "")
    end # === def input

    def input_screen_name
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

    def input_password(name : String)
      tag(
        "input",
        name: name,
        type: "password",
        value: ""
      )
    end # === def input

    def input_pass_phrase(prefix : String? = nil)
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

    def script(src : String)
      tag("script", type: "text/javascript", src: src) {
        with self yield self
      }
    end # === def script

  end # === class HTML

end # === module MEGAUNI



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

    def h1
      raw! "<h1>"
      text? {
        with self yield
      }
      raw! "</h1>"
    end

    def form
      raw! "<form>"
      text? { with self yield }
      raw! "</form>"
    end # === def form

    def button
      raw! "<button>"
      text? { with self yield }
      raw! "</button>"
    end # === def button

    def screen_name_input
      raw! "<input"
      attr! :name, "screen_name"
      attr! :type, "text"
      attr! :minlength, MEGAUNI::MIN_SCREEN_NAME.to_s
      attr! :maxlength, MEGAUNI::MAX_SCREEN_NAME.to_s
      attr! :value, ""
      attr! :required
      raw '>'
    end

    def pass_phrase_input(prefix : String? = nil)
      raw! "<input"
      attr! :name, "#{prefix == "" ? "" : "#{prefix}_"}pass_phrase"
      attr! :type, "password"
      attr! :minlength, MEGAUNI::MIN_PASS_PHRASE.to_s
      attr! :maxlength, MEGAUNI::MAX_PASS_PHRASE.to_s
      attr! :value, ""
      attr! :required
      raw '>'
    end # === def to_html

  end # === class HTML

end # === module MEGAUNI


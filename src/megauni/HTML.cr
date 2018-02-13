
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

    # =============================================================================
    # Instance
    # =============================================================================

    def head
      raw! %[<meta charset="UTF-8">]
      with self yield self
    end

    def script
      raw! "script"
      attr! :type, "application/javascript"
      attr! :src, "/megauni/files/#{data["model!"]}/#{data["action!"]}.js"
    end

    def stylesheet
      raw! "link"
      attr! :href,  "/megauni/files/model/action.css"
      attr! :rel,   "stylesheet"
      attr! :title, "Default"
    end

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


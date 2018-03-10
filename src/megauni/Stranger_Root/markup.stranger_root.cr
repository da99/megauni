
module MEGAUNI
  class Stranger_Root

    def markup_stranger_root
      ::MEGAUNI::HTML.to_html do
        doctype!
        html {
          head {
            utf8!
            script!
            stylesheet!
            title { "#{MEGAUNI.site_name}: Home" }
            meta("Description", "Sign-In or Create an Account if you don't have one.")
          }
          body {
            header {
              h1 { MEGAUNI.site_name }
            }

            markup_log_in
            markup_create_a_new_account
            markup_footer

          } # body
          script("/applets/Browser/Megauni.js") { }
        } # === html
      end
    end # === def self.page

  end # === class Stranger_Root
end # === module MEGAUNI

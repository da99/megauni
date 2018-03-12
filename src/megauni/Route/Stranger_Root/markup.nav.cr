
module MEGAUNI
  class Stranger_Root

    macro markup_nav
      nav {

        h1(".site_name") {
          span(".main") { "mega" }
          span(".sub") { "UNI" }
          span { ".com" }
        }

        ul {
          li { a(href: "/inbox") { "/inbox" } }
          li { a(href: "/high") { "/high" } }
          li { a(href: "/news") { "/news" } }
          li { a(href: "/unknown") { "/unknown" } }
          li { a(href: "/@username") { "@username" } }
          li { a(href: "/@username/1") { "@username/1" } }
          li { a(href: "/@username/@member") { "@username/@member" } }
        }

        footer {
          p {
            "(c) 2012-#{Time.now.year} megauni.com. Some rights reserved."
          }
          p { "All other copyrights belong to their respective owners, who have no association to this site:" }
          p(".important") {
            span { "Logo font: " }
            a(href: "http://openfontlibrary.org/en/font/otfpoc") { "Aghja" }
          }
          p(".important") {
            span {
              text! "Palettes: "
              a(href: "http://www.colourlovers.com/palette/154398/bedouin") { "bedouin" }
            } # === span
          } # === div
        } # disclaimer
      } # nav
    end # === macro markup_header

  end # === class Stranger_Root
end # === module MEGAUNI

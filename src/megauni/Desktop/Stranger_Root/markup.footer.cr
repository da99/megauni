
module MEGAUNI
  class Desktop_Stranger_Root

    macro markup_header
      header {
        h1(".site_name") {
          span(".main") { "mega" }
          span(".sub") { "UNI" }
        }
        p {
          a(href: "/home") { "/home" }
        }
        p {
          a(href: "/@da99") { "/@da99" }
        }
        p {
          a(href: "/!4567") { "/!4567" }
        }
        p {
          a(href: "/nowhere") { "/nowhere" }
        }

        div(".disclaimer") {
          p {
            "(c) 2012-#{Time.now.year} megauni.com. Some rights reserved."
          }
          p { "All other copyrights belong to their respective owners, who have no association to this site:" }
          p {
            span { "Logo font: " }
            a(href: "http://openfontlibrary.org/en/font/otfpoc") { "Aghja" }
          }
          p {
            span {
              text! "Palettes: "
              a(href: "http://www.colourlovers.com/palette/154398/bedouin") { "bedouin" }
              text! " by: "
              a(href: "http://www.colourlovers.com/lover/dvdcpd") { "dvdcpd" }
            } # === span
          } # === div
        }
      } # div#intro
    end # === macro markup_header

  end # === class Desktop_Stranger_Root
end # === module MEGAUNI


module MEGAUNI
  struct Inbox_All

    macro markup_other
      section("#other") {
        h2 { "Other Messages" }

        div(".list") {
          "Expiring Soon,Work,School,ADs,Acquaintences,Friends,Family,Unsorted".split(',').each { |x|
            div(".folder") {
              div(".name") { "#{x}:" }
              div(".size") { a(href: "/@me/message/10" ) { "10" } }
            } # === div
          }
        } # === div.list

      } # === section
    end # === macro markup_other

  end # === struct Inbox_All
end # === module MEGAUNI

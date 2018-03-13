
module MEGAUNI
  struct Inbox_All

    macro markup_high
      section("#high") {
        h2 { "High Priority" }
        ul {
          li  { a(href: "/@me/message/1" ) { "1" } }
        } # === ul
      } # === section
    end # === macro markup_high

  end # === struct Inbox_All
end # === module MEGAUNI

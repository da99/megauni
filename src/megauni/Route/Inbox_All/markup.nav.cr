
module MEGAUNI
  struct Inbox_All

    macro markup_nav
      nav {
        h1 {
          span { "/inbox" }
        }

        ul {
          li { a(href: "/news" ) { "/news" } }
          4.times { |i|
            li {
              a(href: "@me-#{i+1}" ) { "@me-#{i+1}" }
              span { " - " }
              a(href: "/inbox/@me-#{i+1}" ) { "/inbox" }
              span { " - " }
              a(href: "/news/@me-#{i+1}" ) { "/news" }
            }
          }
          li {
            a(href: "/" ) {
              raw!("/ &nbsp;")
            }
          }
        } # === ul

      } # === nav
    end # === macro markup_nav

  end # === class Inbox_All
end # === module MEGAUNI


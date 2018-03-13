
module MEGAUNI
  struct Inbox_All

    macro markup_recent_senders
      section("#recent_senders") {
        h2 { "Recent Senders" }

        ul {
          50.times do |i|
            li {
              a(href: "/inbox/from/@screen_name_#{i}") { "@screen_name_#{i}" }
            }
          end # === 50.times
        } # === ul

      } # === section
    end # === macro markup_other

  end # === struct Inbox_All
end # === module MEGAUNI

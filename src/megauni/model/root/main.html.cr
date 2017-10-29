
MU_HTML.write(__FILE__) {
  doctype!
  html {
    head {
      title "#{logo_name}: Home"
      stylesheet!
    }
    body {

      header {
        h1 logo_name
      }

      section {
        h2 "Log-In"
        form {
          fieldset {
            label { "Screen Name" }
            screen_name_input
          }

          fieldset {
            label {
              span { "Pass Phrase" }
              span("sub") { "(spaces allowed)" }
            }
            pass_phrase_input
          }

          nav {
            button("submit") { "Log-In" }
          }
        } # === form
      } # === section

      section {
        h2 "Create A New Account"
        form {
          fieldset {
            label { "Screen Name" }
            screen_name_input
          }

          fieldset {
            label {
              span { "Pass Phrase" }
              span("sub") { "(spaces allowed)" }
            }
            pass_phrase_input
          }

          fieldset {
            label { "Confirm Pass Phrase" }
            pass_phrase_input("confirm")
          }

          nav {
            button("submit") { "Create" }
          }
        } # === form
      } # === section

    } # === body
    script!
  }
}

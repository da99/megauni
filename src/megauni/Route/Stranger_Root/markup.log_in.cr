
module MEGAUNI
  class Stranger_Root

    macro markup_log_in
      section {
        h2 { "Log-In" }
        form {
          fieldset {
            label { "Screen Name:" }
            input_screen_name
          }

          fieldset {
            label {
              span { "Pass Phrase:" }
            }
            input_pass_phrase("pswd")
          }

          div(".submit") {
            button(".submit") { "Log-In" }
          }

        } # === form
      } # === section
    end # === def log_in_markup

  end # === class Stranger_Root
end # === module MEGAUNI


module MEGAUNI
  class Stranger_Root

    macro markup_create_a_new_account
      section {
        h2 { "Create A New Account" }
        form(action: "/log-in", method: "post") {
          fieldset {
            label { "Screen Name:" }
            input_screen_name
          }

          fieldset(".pswd") {
            label {
              span { "Pass Phrase:" }
              span(".sub") { " (for better security, use spaces and words)" }
            }
            input_pass_phrase("pswd")
          }

          fieldset(".confirm_pass_phrase") {
            label { "Confirm Pass Phrase:" }
            input_pass_phrase("confirm")
          }

          div(".submit") {
            button(".submit") { "Create Account" }
          }

        } # === form
      } # === section
    end # === macro markup_create_a_new_account

  end # === class Stranger_Root
end # === module MEGAUNI


module MEGAUNI
  class Desktop_Stranger_Root

    macro markup_create_a_new_account
      section {
        h2 { "Create A New Account" }
        form(action: "/log-in", method: "post") {
          fieldset {
            label { "Screen Name" }
            screen_name_input
            input_text("screen_name", "")
          }

          fieldset(".pswd") {
            label {
              span { "Pass Phrase" }
              span(".sub") { " (for better security, use spaces and words)" }
              span { ":" }
            }
            pass_phrase_input
            input_password("pswd")
          }

          fieldset(".confirm_pass_phrase") {
            label { "Confirm Pass Phrase:" }
            pass_phrase_input("confirm")
            input_password("confirm_pass_word")
          }

          nav {
            button(".submit") { "Create Account" }
          }

          template(data_do: "template logged-in?") {
            div(".success_msg") { "You account has been created. Loading..." }
          }

          template(data_do: "template error-/user") {
            div(".error_msg") { "\{{msg}}" }
          }
        } # === form
      } # === section
    end # === macro markup_create_a_new_account

  end # === class Desktop_Stranger_Root
end # === module MEGAUNI

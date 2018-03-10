
module MEGAUNI
  class Stranger_Root

    macro markup_log_in
      section {
        h2 { "Log-In" }
        form {
          fieldset {
            label { "Screen Name" }
            screen_name_input
          }

          fieldset {
            label {
              span { "Pass Phrase" }
              span(".sub") { "(spaces allowed)" }
            }
            pass_phrase_input
          }

          nav {
            button(".submit") { "Log-In" }
          }

          template(data_do: "template logged-in?") {
            div(".success_msg") { "You are now logged in. Loading..." }
          }

          template(data_do: "template FORM.error_msg") {
            div(".error_msg") { "\{{msg}}" }
          }
        } # === form
      } # === section
    end # === def log_in_markup

  end # === class Stranger_Root
end # === module MEGAUNI

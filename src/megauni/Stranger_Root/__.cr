
module MEGAUNI

  class Stranger_Root

    # =============================================================================
    # Class:
    # =============================================================================

    def self.route!(route)
      path = route.ctx.request.path
      case

      when path == "/"
        new(route).root

      when path == "/hello/world"
        route.text! "#{route.ctx.request.path} Hello world!"

      else
        return false

      end # === case

      true
    end # def self.route

    # =============================================================================
    # Instance:
    # =============================================================================

    getter route : Route
    getter route_name = "Stranger_Root"

    def initialize(@route)
    end # === def initialize

    def root
      route.html!(
        ::MEGAUNI::HTML.to_html do
          doctype!
          html {
            head {
              utf8!
              script!
              stylesheet!
              title { "#{MEGAUNI.site_name}: Home" }
              meta(name: "Description", content: "Sign-In or Create an Account if you don't have one.")
            }
            body {
              header {
                h1 { MEGAUNI.site_name }
              }
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
                      span(class: "sub") { "(spaces allowed)" }
                    }
                    pass_phrase_input
                  }

                  nav {
                    button(class: "submit") { "Log-In" }
                  }
                } # === form
              } # === section

              section {
                h2 { "Create A New Account" }
                form {
                  fieldset {
                    label { "Screen Name" }
                    screen_name_input
                  }

                  fieldset {
                    label {
                      span { "Pass Phrase" }
                      span(class: "sub") { "(spaces allowed)" }
                    }
                    pass_phrase_input
                  }

                  fieldset {
                    label { "Confirm Pass Phrase" }
                    pass_phrase_input("confirm")
                  }

                  nav {
                    button(class: "submit") { "Create" }
                  }
                } # === form
              } # === section

              div("#log_in", class: "block form") {
                h3 { "Log-In" }
                div(class: "content") {
                  form(action: "/log-in", method: "post") {
                    div(class: "fields") {
                      div(class: "field screen_name") {
                        label { "Screen name:" }
                        input_text("screen_name", "")
                      }
                      div(class: "field passphrase") {
                        label { "Pass phrase:" }
                        input_password("pswd")
                      }
                      template(data_do: "template logged-in?") {
                        div(class: "success_msg") { "You are now logged in. Loading..." }
                      }

                      template(data_do: "template FORM.error_msg") {
                        div(class: "error_msg") { "{{msg}}" }
                      }

                      div(class: "field buttons", data_do: "hide FORM.submit") {
                        button(class: "submit", data_do: "on_click send_msg FORM.submit") {
                          "Log-In"
                        }
                      }
                      div(class: "loading", data_do: "hide; show_if FORM.submit;    hide     FORM.is_response") {
                        "Loading..."
                      }
                      div(class: "errors", data_do: "hide; show_if FORM.error_msg; print_if FORM.error_msg") {
                      }
                    } # === div
                  } # === form
                } # <!-- div.content -->
              } # <!-- div.block.form -->

              div(class: "block form") {
                h3 { "Create a New Account" }
                div(class: "content") {
                  form(
                    "#create_account",
                    action: "/user",
                    method: "POST",
                    data_do: "on_send hide_button, on_respond_ok reset, wait_a_few, reload"
                  ) {
                    div(class: "fields") {
                      div(class: "field screen_name") {
                        label { "Screen name:" }
                        input_text("screen_name", "")
                      }

                      div(class: "field pswd") {
                        label {
                          span(class: "main") { "Pass phrase" }
                          span(class: "sub") { " (for better security, use spaces and words)" }
                          span(class: "main") { ":" }
                        }
                        input_password("pswd")
                      }

                      div(class: "field confirm_pass_phrase") {
                        label {
                          span(class: "main") { "Re-type the pass phrase:" }
                        }
                        input_password("confirm_pass_word")
                      }

                      template(data_do: "template logged-in?") {
                        div(class: "success_msg") { "You account has been created. Loading..." }
                      }

                      template(data_do: "template error-/user") {
                        div(class: "error_msg") { "{{msg}}" }
                      }

                      div(class: "buttons") {
                        button(class: "submit") { "Create Account" }
                      }
                    }
                  }
                }
              } # === div

              div("#intro", class: "block") {
                h1(class: "site") {
                  span(class: "main") { "mega" }
                  span(class: "sub") { "UNI" }
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

                div(class: "disclaimer") {
                  p {
                    text! "(c) 2012-"
                    span(id: "copyright_year_today") { "2016" }
                    text! "megauni.com. Some rights reserved."
                  }
                  p { "All other copyrights belong to their respective owners, who have no association to this site:" }
                  p {
                    span { "Logo font: " }
                    a(href: "http://openfontlibrary.org/en/font/otfpoc") { "Aghja" }
                  }
                  p {
                    span {
                      text! "Palettes: "
                      a(href: "http://www.colourlovers.com/lover/dvdcpd") { "dvdcpd" }
                      a(href: "http://www.colourlovers.com/palette/154398/bedouin") { "shari_foru" }
                    } # === span
                  } # === div
                }
              } # div#intro

            } # body
            script("/applets/Browser/Megauni.js") { }
          } # === html
        end
      ) # === route.html!
    end # === def root

  end # === class Root

end # === module MEGAUNI

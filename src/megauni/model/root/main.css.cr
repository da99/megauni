
MU_STYLE.write(__FILE__) {

  s("header") {
    padding em(1), em(2)
    background_color hex("black")
    color hex("white")
    font_weight bold
    margin 0, 0, em(1), 0
  }

  s("header h1") {
    font_weight bold
  }

  s("section") {
    padding em(1)
    color hex("black")
    background_color grey
    font_weight bold
    margin em(1)
    float left
  }

  s("h2") {
    font_weight bold
    font_size em(1)
    padding 0, 0, em(0.5), 0
  }

  s("section form fieldset") {
    padding em(0.5), 0
  }

  s("section form label") {
    display block
  }

  s("section form nav") {
    text_align right
    padding em(0.5), 0, 0, 0
  }

} # MU_STYLE.write

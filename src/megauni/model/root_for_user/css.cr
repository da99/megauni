
module MEGAUNI

  class Root_For_User

    @screen_name : String

    def initialize(@screen_name)
    end # === def initialize

    def to_css(raw : String)
      CSS.to_css(screen_name, raw)
    end # === def to_css

  end # === class Root_For_User

end # === module MEGAUNI

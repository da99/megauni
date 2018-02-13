
require "da_css"

module MEGAUNI

  class CSS
    # =============================================================================
    # Instance
    # =============================================================================

    # =============================================================================
    # Class
    # =============================================================================

  def self.write(file : String)
    pair = MU_COMMON.model_and_action(file)

    sheet = new
    with sheet yield
    new_css = "Public/#{pair.first}/#{pair.last}.css"

    Dir.mkdir_p(File.dirname(new_css))
    File.write(new_css, sheet.to_css)

    puts "=== wrote: #{new_css}"
  end # === def self.write

    def reset!
      io.raw! File.read("#{__DIR__}/../../node_modules/HTML5-Reset/assets/css/reset.css")
      io.raw! File.read("#{__DIR__}/../../node_modules/HTML5-Reset/assets/css/style.css")
    end

    def grey
      hex("#F3F3F3")
    end

    def self.to_css(screen_name , b)
      MEGAUNI::Screen_Name.valid!(screen_name)
      io = IO::Memory.new
      DA_CSS::Parser.parse(b).each_with_index { |blok, blok_i|
        io << '\n' if blok_i != 0
        last = blok.selectors.last
        blok.selectors.each_with_index { |s, i|
          io << ',' << ' ' if i != 0
          io << screen_name << ' '
          s.to_s(io)
        }
        io << ' ' << DA_CSS::OPEN_BRACKET << '\n'
        blok.propertys.join('\n', io)
        io << '\n' << DA_CSS::CLOSE_BRACKET
      }
      io.to_s
    end # === def self.to_css

  end # === module CSS

end # === module MU_CSS


require "da_style"

class MU_STYLE

  include DA_STYLE

  create_property "font-weight"
  create_property "background"
  create_property "color"
  create_property "margin"
  create_property "padding"
  create_keyword "bold"

  def initialize
    io.raw! File.read("#{__DIR__}/../../node_modules/HTML5-Reset/assets/css/reset.css")
    io.raw! File.read("#{__DIR__}/../../node_modules/HTML5-Reset/assets/css/style.css")
  end

  def self.to_css
    sheet = new
    with sheet yield
    sheet.to_css
  end # === def self.to_css

  def self.write(file : String)
    pair = MU_COMMON.model_and_action(file)

    sheet = new
    with sheet yield
    new_css = "Public/#{pair.first}/#{pair.last}.css"

    Dir.mkdir_p(File.dirname(new_css))
    File.write(new_css, sheet.to_css)

    puts "=== wrote: #{new_css}"
  end # === def self.write

end # === class MU_STYLE

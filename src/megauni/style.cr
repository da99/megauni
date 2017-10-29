
require "da_style"
require "./common"

class MU_STYLE

  include DA_STYLE

  def grey
    hex("#F3F3F3")
  end

  {% for name in %w(display text-align font-weight font-size background-color color margin padding float) %}
    def {{name.gsub(/-/,"_").id}}(*args)
      io.write_property({{name}}, *args)
    end
  {% end %}

  create_keyword "bold"
  create_keyword "left"
  create_keyword "right"
  create_keyword "block"

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

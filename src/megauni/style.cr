
require "da_style"

class MU_STYLE

  include DA_STYLE

  create_property "font-weight"
  create_keyword "bold"

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

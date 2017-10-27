
require "da_html"
require "./common"
require "secure_random"

class MU_HTML

  include DA_HTML

  macro script!
    io.write_tag("script") do
      %pair = MU_COMMON.model_and_action(__FILE__)
      io.write_attr "type", "application/javascript"
      io.write_attr "src", "/megauni/files/#{%pair.first}/#{%pair.last}.js"
      io.write_content { }
    end
  end # === macro script

  macro stylesheet!
    %pair = MU_COMMON.model_and_action(__FILE__)
    io.write_closed_tag(
      "link",
      {"href",  "/megauni/files/#{%pair.first}/#{%pair.last}.css" },
      {"rel",   "stylesheet" },
      {"title", "Default"}
    )
  end # === def stylesheet

  def self.write(file : String)
    pair = MU_COMMON.model_and_action(file)

    page   = new
    with page yield
    new_html_file = "Public/#{pair.first}/#{pair.last}.html"

    Dir.mkdir_p(File.dirname(new_html_file))
    File.write(new_html_file, page.to_html)

    puts "=== wrote: #{new_html_file}"
  end # === def self.write

end # === struct MU_HTML



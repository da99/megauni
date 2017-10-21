
require "da_html"

class MU_HTML

  include DA_HTML

  macro stylesheet
    %pieces = __FILE__.split("/")
    io.write_closed_tag(
      "link",
      {"href",  "/megauni/files/#{%pieces[-2]}/#{%pieces.last.sub(".html.cr", ".css")}" },
      {"rel",   "stylesheet" },
      {"title", "Default"}
    )
  end # === def stylesheet

  def self.write(file : String)
    pieces = file.split("/")
    folder = pieces[-2]
    action = pieces.last.sub(/.html.cr$/, "")

    page   = new
    with page yield
    new_html_file = "Public/#{folder}/#{action}.html"

    Dir.mkdir_p(File.dirname(new_html_file))
    File.write(new_html_file, page.to_html)

    puts "=== wrote: #{new_html_file}"
  end # === def self.write

end # === struct MU_HTML



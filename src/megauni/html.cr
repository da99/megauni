
require "da_html"

class MU_HTML

  include DA_HTML

  def self.folder_action(file : String)
    pieces = file.split("/")
    folder = pieces[-2]
    action = pieces.last.sub(/.html.cr$/, "")
    { folder, action }
  end # === def self.folder_action

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
    pair = folder_action(file)

    page   = new
    with page yield
    new_html_file = "Public/#{pair.first}/#{pair.last}.html"

    Dir.mkdir_p(File.dirname(new_html_file))
    File.write(new_html_file, page.to_html)

    puts "=== wrote: #{new_html_file}"
  end # === def self.write

end # === struct MU_HTML




require "da_html"

class MU_HTML

  include DA_HTML

  def self.write(file : String)
    page = new
    with page yield
    new_html_file = "Public" + file.sub(__DIR__, "").sub(/\.cr$/, "")
    Dir.mkdir_p(File.dirname(new_html_file))
    File.write(new_html_file, page.to_html)

    puts "=== wrote: #{new_html_file}"
  end # === def self.write

end # === struct MU_HTML



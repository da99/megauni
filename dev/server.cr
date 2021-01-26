
require "kemal"

public_folder "dist/Public"
serve_static({"gzip" => true, "dir_listing" => true})

get "/" do |env|
  File.read "dist/Public/apps/homepage/index.html"
end

Kemal.run

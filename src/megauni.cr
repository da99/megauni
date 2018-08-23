
require "da_deploy"
require "da_server"
require "./megauni/HTTP_Handlers/Megauni_Archive"
require "./megauni/HTTP_Handlers/Surfer_Hearts"
require "./megauni/HTTP_Handlers/Index_File"
require "./megauni/HTTP_Handlers/Not_Found"
require "./megauni/Screen_Name/__"
require "./megauni/Member/__"
require "./megauni/PostgreSQL/PostgreSQL"
require "./megauni/Base/Base"

module DA
  def each_non_empty_line(raw)
    raw.each_line { |raw_line|
      line = raw_line.chomp
      next if line.empty?
      yield line
    }
  end # === def

  def each_non_empty_string(arr : Array(String))
    arr.each { |raw_string|
      s = raw_string.chomp
      next if s.empty?
      yield s
    }
  end # === def

  def capture_output(cmd : String, args : Array(String)) : IO::Memory
    io_out = IO::Memory.new
    DA.success!(
      Process.run(
        cmd, args, 
        input: Process::Redirect::Inherit,
        output: io_out,
        error: Process::Redirect::Inherit
      )
    )
    io_out.rewind
    io_out
  end # === def
end # === module DA

module MEGAUNI

  class Error < Exception
  end

  # SECRET      = "#{ENV["HTTP_SERVER_SESSION_SECRET"]}"
  COOKIE_NAME = "mu_session"

  MIN_SCREEN_NAME = 3
  MAX_SCREEN_NAME = 10
  MIN_PASS_PHRASE = 8
  MAX_PASS_PHRASE = 100

  # =============================================================================
  # Module:
  # =============================================================================

  def self.app_dir
    File.dirname(File.dirname(Process.executable_path.not_nil!))
  end # === def self.app_dir

  def self.site_name
    "megaUNI.com"
  end

  def self.route_name(file : String)
    return File.basename(File.dirname(file))
  end

  def self.route_file(file : String)
    route_name = self.route_name(file)
    name = File.basename(file, File.extname(file))
    "Route/#{route_name}/#{name}"
  end

  def self.http_start(port : Int32 = 4567)
    host = DA.development? ? "localhost" : "0.0.0.0"
    user = DA.development? ? `whoami`.strip : "www-deployer"
    public_dir = File.join(File.dirname(Process.executable_path.not_nil!), "../Public")

    DA.orange! "=== Using public dir: #{public_dir}"
    s = DA_Server.new(host, port, user, [
      DA_Server::No_Slash_Tail.new,
      DA_Server::Public_Files.new(public_dir),
      Not_Found.new
    ])
    s.listen
  end # === def self.service_run

end # === module MEGAUNI


# require "./megauni/SQL/__"

# require "./megauni/Member/__"
# require "./megauni/Message_Folder/__"
# require "./megauni/Message_Receive_Command/__"
require "./megauni/HTML"
# require "./megauni/CSS"

# require "./megauni/Route"
# require "./megauni/Server"

# require "./megauni/Route/Stranger_Root/__"
# require "./megauni/Route/Inbox_All/__"




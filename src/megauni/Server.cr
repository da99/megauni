
module MEGAUNI

  class Server

    PORTS_DIR = File.expand_path("#{__DIR__}/../../tmp/out/megauni.ports")

    getter server : HTTP::Server
    getter port : Int32

    MODELS = Set{Root}

    def initialize(@port = 3000)
      @server = HTTP::Server.new(port) do |ctx|
        Route.route!(ctx)
      end
    end # === def self.start

    def self.running_servers(port : Int32)
      servers = running_servers
      servers.select { |pair|
        pair.first == port
      }
    end

    def self.running_servers
      Dir.mkdir_p(PORTS_DIR)
      count = [] of Tuple(Int32, Int32)
      Dir.glob("#{PORTS_DIR}/*").each { |file|
        port = File.basename(file).to_i
        raw = File.read(file).strip
        next unless raw[/\A[0-9]+\Z/]?
        pid = raw.to_i
        if Process.exists?(pid)
          count.push({port, pid})
        end
      }
      count
    end

    def port_file
      File.join(PORTS_DIR, port.to_s)
    end

    def close
      @server.close
      File.delete(port_file)
      STDERR.puts
      STDERR.puts DA_Dev::Colorize.green("=== {{Closed}} server on port BOLD{{#{port}}}, pid BOLD{{#{Process.pid}}} ===")
    end

    def listen
      Dir.mkdir_p(PORTS_DIR)
      current = Server.running_servers(port)
      if current.size > 0
        current.each { |pair|
          DA_Dev.red! "!!! {{Server already running}}: port BOLD{{#{pair.first}}}, pid BOLD{{#{pair.last}}}"
        }
        exit 1
      end

      File.write(port_file, Process.pid.to_s) unless File.exists?(port_file)

      Signal::INT.trap {
        Signal::INT.reset
        close
        exit 0
      }

      Signal::TERM.trap {
        Signal::TERM.reset
        close
        exit 0
      }

      DA_Dev.orange! "=== {{Starting}} server on port BOLD{{#{port}}}, pid BOLD{{#{Process.pid}}}"
      @server.listen
    end # === def listen

  end # === module Server

end # === module MEGAUNI




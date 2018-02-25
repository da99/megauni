
require "./megauni"

Signal::INT.trap do
  STDERR.puts "=== INT signal received. Exiting gracefully and with 0..."
  exit 0 # run at_exit handlers to close DB and other resources.
end

MEGAUNI::Server.new.listen


module MEGAUNI
  module Dev
    class SCSS_File

      # =============================================================================
      # Class:
      # =============================================================================

      # =============================================================================
      # Instance:
      # =============================================================================

      getter file  : String
      getter css   : String
      getter route : String
      getter name  : String

      def initialize(@file : String)
        @route = File.basename(File.dirname(@file))
        @name  = File.basename(@file, ".scss")
        @css   = "./Public/public/#{@route}/#{@name}.css"
      end # === def initialize

      def compile!
        DA_Dev.orange! "=== {{Compiling}}: BOLD{{#{file}}} -> #{css}"
        args = [file, css]
        DA_Process.success!("sassc", args)
      end

    end # === class SCSS_File
  end # === module Dev
end # === module MEGAUNI

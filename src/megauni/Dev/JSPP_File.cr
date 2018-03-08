
module MEGAUNI
  module Dev
    class JSPP_File

      # =============================================================================
      # Class:
      # =============================================================================

      def self.lib_files
        lib_files  = Dir.glob(".js_packages/da_standard/src/*.jspp")
      end

      def self.my_jspp
        my_jspp = File.expand_path("#{THIS_DIR}/../my_jspp/bin/my_jspp")
      end

      # =============================================================================
      # Instance:
      # =============================================================================

      getter file  : String
      getter route : String
      getter js    : String
      getter name  : String

      def initialize(@file)
        @route = File.basename(File.dirname(@file))
        @name  = File.basename(@file, ".jspp")
        @js    = "Public/public/#{@route}/#{@name}.js"
      end # === def initialize

      def compile!
        Dir.mkdir_p(File.dirname(js))
        args = ["__"]
        args.concat(self.class.lib_files)
        args.concat([file, "-o", js])

        stat = DA_Process.success!(
          self.class.my_jspp,
          args
        )
      end

    end # === class JSPP_File
  end # === module Dev
end # === module MEGAUNI

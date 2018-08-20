
module MEGAUNI
  module PostgreSQL
    struct Schema

      getter name : String
      getter owner : String
      getter access_privileges : Array(String) = [] of String
      getter description : String

      def initialize(raw : String)
        @name, @owner, raw_access_privileges, @description = raw.split('|')
        raw_access_privileges.split.each { |x|
          access_privileges.push x
        }
      end # def

    end # === struct Schema
  end # === module PostgreSQL
end # === module MEGAUNI

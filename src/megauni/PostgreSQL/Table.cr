
module MEGAUNI
  module PostgreSQL
    struct Table

      getter schema      : String
      getter name        : String
      getter type        : String
      getter owner       : String

      def initialize(raw_line : String)
        @schema, @name, @type, @owner = raw_line.split('|')
      end # def

    end # === struct Table
  end # === module PostgreSQL
end # === module MEGAUNI


module MEGAUNI
  module PostgreSQL
    struct Role

      getter name : String
      getter attributes : Array(String) = [] of String
      getter member_of : Array(String) = [] of String

      def initialize(raw_line : String)
        pieces = raw_line.chomp.split('|')
        @name = pieces.shift

        pieces.shift.split(/, /).each { |l|
          next if !l || l.empty?
          @attributes.push l
        }

        pieces.shift.chomp.split(/\{|\}|,\ ?/).each { |l|
          next if !l || l.empty?
          @member_of.push l
        }
      end # === def

    end # === struct Role
  end # === module PostgreSQL
end # === module MEGAUNI


module MEGAUNI

  module Screen_Name
    class Invalid < Exception
    end

    # =============================================================================
    # Class
    # =============================================================================

    def self.valid?(raw : String)
      return false if raw.size > 15
      raw.each_char { |c|
        case c
        when 'a'..'z', '_', '.', '-', '0'..'9'
          true
        else
          return false
        end
      }
      true
    end # === def self.valid?

    def self.valid!(raw : String)
      if valid?(raw)
        true
      else
        raise Invalid.new(raw.inspect)
      end
    end # === def self.valid!

  end # === module Screen_Name

end # === module Megauni

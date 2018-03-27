
module MEGAUNI

  struct Screen_Name
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

    def self.find_by_screen_name(raw : String)
      owner_id = screen_name = nil
      MEGAUNI::SQL.run { |db|
        owner_id, screen_name = db.query_one(
          %[
            SELECT owner_id, screen_name
            FROM screen_name
            WHERE screen_name = screen_name_canonical($1)
            LIMIT 1;
          ], raw, as: {Int64, String}
        )
      }
      if owner_id.is_a?(Int64) && screen_name.is_a?(String)
        return Screen_Name.new(owner_id, screen_name)
      end
      raise Query_Error.new("Screen name not found: #{raw.inspect}")
    end # === def self.find_by_screen_name

    getter member_id : Int64
    getter screen_name : String
    def initialize(@member_id, @screen_name)
    end # === def initialize

  end # === module Screen_Name

end # === module Megauni

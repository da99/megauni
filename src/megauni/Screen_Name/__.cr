
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
      owner_id = screen_name = screen_name_id = nil
      MEGAUNI::SQL.run { |db|
        owner_id, screen_name, screen_name_id = db.query_one(
          %[
            SELECT owner_id, screen_name, id AS screen_name_id
            FROM screen_name
            WHERE screen_name = screen_name.canonical($1)
            LIMIT 1;
          ], raw, as: {Int64, String, Int64}
        )
      }
      if owner_id.is_a?(Int64) && screen_name.is_a?(String) && screen_name_id.is_a?(Int64)
        return Screen_Name.new(owner_id, screen_name, screen_name_id)
      end
      raise Query_Error.new("Screen name not found: #{raw.inspect}")
    end # === def self.find_by_screen_name

    def self.migrate_head
      database = MEGAUNI.postgresql.database
      schema = database.create_schema?("screen_name")

      database.psql_file(self, "function.clean_new")
      database.psql_file(self, "function.canonical")

      database.create_table?("screen_name.tbl", self, "tbl.sql")
    end # === def

    # =============================================================================
    # Instance:
    # =============================================================================

    getter member_id      : Int64
    getter screen_name    : String
    getter screen_name_id : Int64

    def initialize(@member_id, @screen_name, @screen_name_id)
    end # === def initialize

  end # === module Screen_Name

end # === module Megauni

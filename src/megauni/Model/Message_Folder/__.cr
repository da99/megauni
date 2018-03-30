
module MEGAUNI
  struct Message_Folder

    # =============================================================================
    # Struct
    # =============================================================================

    def self.create(owner : Screen_Name, raw_name : String)
      folder = nil
      SQL.run { |db|
        sql = <<-SQL
          SELECT f.id, f.name, f.display_name
          FROM message_folder_insert($1, $2) f;
        SQL
        id, name, display_name = db.query_one(
          sql, owner.screen_name_id, raw_name,
          as: {Int64, String, String}
        )
        folder = new(id, owner.screen_name_id, name, display_name)
      }

      return folder if folder
      raise Query_Error.new("message folder: failed to create")
    end # === def self.create

    # =============================================================================
    # Instance
    # =============================================================================

    getter id           : Int64
    getter owner_id     : Int64
    getter name         : String
    getter display_name : String
    def initialize(@id, @owner_id, @name, @display_name)
    end # === def initialize

  end # === struct Message_Folder
end # === module MEGAUNI

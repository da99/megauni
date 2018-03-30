
module MEGAUNI
  struct Message_Receive_Command

    # =============================================================================
    # Struct
    # =============================================================================

    def self.create(owner : Screen_Name, sender : Screen_Name, message_folder_source : String, message_folder_destination : String)
      command = nil
      SQL.run { |db|
        sql = <<-SQL
          SELECT id, folder_id_source, folder_id_dest
          FROM message_receive_command_insert($1, $2, $3, $4);
        SQL
        id, message_folder_source_id, message_folder_destination_id = db.query_one(
          sql, owner.screen_name_id, sender.screen_name, message_folder_source, message_folder_destination,
          as: {Int64, Int64, Int64}
        )
        command = new(id, owner.screen_name_id, sender.screen_name_id, message_folder_source_id, message_folder_destination_id)
      }

      if command
        return command
      else
        raise Query_Error.new("message receive command: failed to create")
      end
    end

    # =============================================================================
    # Instance
    # =============================================================================

    getter id               : Int64
    getter owner_id         : Int64
    getter sender_id        : Int64
    getter folder_id_source : Int64
    getter folder_id_dest   : Int64

    def initialize(@id, @owner_id, @sender_id, @folder_id_source, @folder_id_dest)
    end # === def initialize

  end # === struct Message_Receive_Command
end # === module MEGAUNI

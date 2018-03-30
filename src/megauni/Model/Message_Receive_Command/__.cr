
module MEGAUNI
  struct Message_Receive_Command

    # =============================================================================
    # Struct
    # =============================================================================

    def self.create(owner : Screen_Name, sender : Screen_Name, message_type : String, folder : String)
      command = nil
      SQL.run { |db|
        sql = <<-SQL
          SELECT id, message_type_id, message_folder_id
          FROM message_receive_command_insert($1, $2, $3, $4);
        SQL
        id, message_type_id, message_folder_id = db.query_one(
          sql, owner.screen_name_id, sender.screen_name_id, message_type, folder,
          as: {Int64, Int32, Int64}
        )
        command = new(id, owner.screen_name_id, sender.screen_name_id, message_type_id, message_folder_id)
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

    getter id              : Int64
    getter owner_id        : Int64
    getter sender_id       : Int64
    getter message_type_id : Int32
    getter message_folder_id : Int64

    def initialize(@id, @owner_id, @sender_id, @message_type_id, @message_folder_id)
    end # === def initialize

  end # === struct Message_Receive_Command
end # === module MEGAUNI

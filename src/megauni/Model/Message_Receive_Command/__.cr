
module MEGAUNI
  struct Message_Receive_Command

    getter owner           : Screen_Name
    getter sender          : Screen_Name
    getter message_type_id : Int32
    getter folder_id       : Int64

    def initialize(@owner : Screen_Name, @sender : Screen_Name, @message_type_id, @folder_id)
    end # === def initialize

    def save
      SQL.run { |db|
        sql = <<-SQL
          INSERT INTO message_receive_command (owner_id, sender_id, message_type_id, folder_id)
          VALUES ($1, $2, $3, $4);
        SQL
        db.exec(sql, owner.screen_name_id, sender.screen_name_id, message_type_id, folder_id)
      }
    end

  end # === struct Message_Receive_Command
end # === module MEGAUNI


require "crypto/bcrypt/password"

module MEGAUNI
  class Member

    class Error < Exception
    end # === class Error
    class Invalid < Exception
    end # === class Invalid

    def self.crypt_cost
      10
    end # === def crypt_cost

    def self.create(raw_user_name : String, raw_pass_word : String, confirm_pass_word : String)
      if raw_pass_word != confirm_pass_word
        raise Invalid.new("member: confirm pass word does not match")
      end
      pass_word = Crypto::Bcrypt::Password.create(raw_pass_word, cost: crypt_cost)

      new_member_id      = 0.to_i64
      new_screen_name    = "not set"
      new_screen_name_id = 0.to_i64

      MEGAUNI::SQL.run { |db|
        new_member_id, new_screen_name_id, new_screen_name = db.query_one(
          %[
            SELECT m.id, m.screen_name_id, m.screen_name
            FROM member_insert($1, $2) AS m;
          ],
          raw_user_name, pass_word,
          as: {Int64, Int64, String}
        )
      }
      if new_member_id == 0.to_i64
        raise Query_Error.new("member: could not be saved")
      end
      Screen_Name.new(new_member_id, new_screen_name, new_screen_name_id)
    end # === def self.create

  end # === class Member
end # === module MEGAUNI
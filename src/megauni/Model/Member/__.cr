
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

      new_member_id   = 0.to_i64
      new_screen_name = "not set"

      MEGAUNI::SQL.run { |db|
        db.query(
          %[SELECT new_member_id, new_screen_name FROM member_insert($1, $2);],
          raw_user_name, pass_word
        ) { |rs|
          rs.each {
            new_member_id = rs.read(Int64)
            new_screen_name = rs.read(String)
          }
        }
      }
      new(new_member_id, new_screen_name)
    end # === def self.create

    getter member_id : Int64
    getter screen_name : String
    def initialize(@member_id, @screen_name)
    end # === def initialize

  end # === class Member
end # === module MEGAUNI

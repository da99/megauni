
describe "Member.create" do

  it "inserts a member" do
    member_count_sql = "SELECT count(member.id) AS member_count FROM member;"
    MEGAUNI::SQL.reset_tables!
    MEGAUNI::SQL.run { |db|
      member_count = db.scalar(member_count_sql)
      assert member_count == 0

      member = MEGAUNI::Member.create("da00", "this is a BAD password", "this is a BAD password")

      assert db.scalar(member_count_sql) == 1
      assert member.member_id > 0
      assert member.screen_name == "DA00"
    }
  end # === it "inserts a member"

end # === desc "member_insert()"

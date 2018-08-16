

describe "FUNCTION insert_member(...)" do

  it "inserts a screen_name" do
    name = random_name
    member_count_sql = "SELECT count(sn.id) AS count FROM screen_name($1::VARCHAR) AS sn ;"
    specs = SPECS.new

    specs.cluster.database.run { |db|
      member_count = db.scalar(member_count_sql, name)
      assert member_count == 0

      db.transaction { |tx|
        tx.connection.exec "SELECT * FROM insert_member($1::varchar, $2::varchar);", name, ("a1"*30)
        assert tx.connection.scalar(member_count_sql, name.upcase) == 1
      } # db.transaction
    }
  end # === it "inserts a member"

  it "sets a member id for the screen name" do
    name = random_name.upcase
    specs = SPECS.new
    specs.cluster.database.run { |db|
      db.transaction { |tx|
        tx.connection.exec "SELECT * FROM insert_member($1::varchar, $2::varchar);", name, ("a1"*30)
        owner_id = tx.connection.query_one("SELECT owner_id FROM screen_name($1::VARCHAR) ;", name, as: {Int64})
        assert(owner_id > 0)
      } # db.transaction
    }
  end # === it

end # === desc "member_insert()"


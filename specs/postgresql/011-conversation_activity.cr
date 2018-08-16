
describe "sending mail" do

  it "raises exception if person is not authorized to send mail" do
    name_1 = random_name("mailer")
    name_2 = random_name("mailer")
    specs = SPECS.new
    specs.cluster.database.run { |db|
      db.transaction { |tx|
        id_1 = tx.connection.query_one("SELECT id FROM insert_member($1::varchar, $2::varchar);", name_1, ("a1"*30), as: {Int64})
        id_2 = tx.connection.query_one("SELECT * FROM insert_member($1::varchar, $2::varchar);", name_2, ("a1"*30), as: {Int64})
        conv_id = tx.connection.query_one(
          "SELECT * FROM insert_conversation($1::BIGINT, $2::VARCHAR, $3::TEXT);",
          id_1, "conversation 1", "body",
          as: {Int64}
        )
        e = assert_raises(PQ::PQError) {
          tx.connection.query_one(
            "SELECT * FROM insert_conversation_permit($1::conversation_permit_type, $2::BIGINT, $3::BIGINT, $4::BIGINT);",
            "read_and_reply", conv_id, id_1, id_2,
            as: {Int64}
          )
        }
        assert e.message == "denied: not allowed to send conversation"
      } # tx
    } # run
  end # === it

end # === desc "sending mail"


describe "Message_Receive_Command.create" do
  it "creates a command" do
    names = create_members(2)
    sn_1 = names.first
    sn_2 = names.last
    MEGAUNI::Message_Folder.create(sn_2, "news")
    command = MEGAUNI::Message_Receive_Command.create(sn_1, sn_2, "NEWS", "HIGH PRIORITY")
    assert command.id > 0
  end # === it "creates a command"
end # === desc "Message_Receive_Command.create"

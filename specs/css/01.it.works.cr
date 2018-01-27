
describe "MU_CSS" do
  it "works" do
    actual = MU_CSS.to_css("da01", %[nav_bar { padding: 10px; } ])

    assert actual == strip(%[
      da01 nav_bar {
        padding: 10px;
      }
    ])
  end # === it "works"
end # === desc "MU_CSS"

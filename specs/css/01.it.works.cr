
describe "MU_CSS" do
  it "works" do
    actual = MEGAUNI::CSS.to_css("da01", %[nav_bar { padding: 10px; } ])

    assert actual == strip(%[
      da01 nav_bar {
        padding: 10px;
      }
    ])
  end # === it "works"

  it "raises an error if the screen_name is invalid" do
    assert_raises(MEGAUNI::Screen_Name::Invalid) {
      MEGAUNI::CSS.to_css("***", "nav_bar { padding: 10px; }")
    }
  end # === it "raises an error if the username is invalid"
end # === desc "MU_CSS"

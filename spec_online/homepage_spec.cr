
require "./spec_helper"

describe "Homepage" do
  it "responds with 200 status code" do
    assert(request!("/").status_code == 200)
  end

  it "renders /index.html" do
    assert(request_body!("/") == public!("/index.html"))
  end

  it "has valid href values" do
    paths = relative_hrefs("/")
    paths.each { |x|
      assert request!(x).status_code == 200
    }
  end
end # describe

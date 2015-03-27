require 'spec_helper'

describe "snap-it-up app" do

  it "should respond to GET" do
    get "/"
    expect(last_response).to be_ok
    # expect(last_response.body).to match(/SNAP/)
  end

end

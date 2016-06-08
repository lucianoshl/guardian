require 'rails_helper'

RSpec.describe Screen::ServerSelect, type: :model do
  it "do_login" do
    Cookie.all.delete
    screen = Screen::ServerSelect.new
    expect(screen.hash_password).not_to be_empty
    puts screen.hash_password
  end
end

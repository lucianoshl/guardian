require 'rails_helper'

RSpec.describe Screen::Login, type: :model do
  it "do_login" do
    Cookie.all.delete
    # login_screen = Screen::Login.new({
    #   user: User.current.name,
    #   password: Screen::ServerSelect.new.hash_password,
    # })

    Screen::Place.new
  end
end

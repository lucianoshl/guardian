require 'rails_helper'

RSpec.describe Screen::Overview, type: :model do
  it "do_login" do
    Cookie.all.delete
    Screen::Overview.new
  end
end

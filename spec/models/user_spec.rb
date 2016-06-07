require 'rails_helper'

RSpec.describe User, type: :model do
  it "do_login" do
    map_screen = Screen::Map.neighborhood(OpenStruct.new(x: 534, y: 534),10)
    binding.pry
  end
end

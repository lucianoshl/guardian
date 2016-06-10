require 'rails_helper'

RSpec.describe Task::PillageAround, type: :model do
  it "do_login" do
    Task::PillageAround.new.test_local
  end
end

require 'rails_helper'

RSpec.describe Task::PillageAround, type: :model do
  it "pillage_test_local" do 
    Task::PillageAround.new.test_local
  end

end

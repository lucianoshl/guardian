require 'rails_helper'

RSpec.describe Task::UpdateDailyInformation , type: :model do
  it "update_daily_information" do
    Task::UpdateDailyInformation.new.run
  end
end

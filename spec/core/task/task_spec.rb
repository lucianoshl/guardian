require 'rails_helper'

RSpec.describe do
  it "UpdateDailyInformation" do
    Task::UpdateDailyInformation.new.run
  end
end

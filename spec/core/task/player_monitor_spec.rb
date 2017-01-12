require 'rails_helper'

RSpec.describe Task::PlayerMonitor, type: :model do
  it "player_monitor_task" do
    Task::PlayerMonitor.new.run
  end
end

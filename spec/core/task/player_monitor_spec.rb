require 'rails_helper'

RSpec.describe Task::PlayerMonitor, type: :model do
  it "do_login" do
    Task::PlayerMonitor.new.run
  end
end

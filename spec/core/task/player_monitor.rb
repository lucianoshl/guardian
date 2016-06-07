require 'rails_helper'

RSpec.describe Task::PlayerMonitor, type: :model do
  it "do_login" do
    Task::PlayerMonitor.new.delay(run_at: Time.now + 10.seconds).run
  end
end

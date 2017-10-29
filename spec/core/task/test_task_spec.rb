require 'rails_helper'

RSpec.describe "test_task", type: :model do
  it "test_task" do
    Task::AutoRecruit.new.execute
  end
end

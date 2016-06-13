require 'rails_helper'

RSpec.describe Village, type: :model do
  it "test_pillage_candidates" do
    puts Village.pillage_candidates.size
  end
end

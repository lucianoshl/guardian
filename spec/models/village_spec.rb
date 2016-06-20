require 'rails_helper'

RSpec.describe Village, type: :model do
  it "test_pillage_candidates" do
    Village.pillage_candidates
  end
end

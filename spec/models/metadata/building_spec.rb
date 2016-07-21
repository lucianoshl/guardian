require 'rails_helper'

RSpec.describe Metadata::Building, type: :model do
  it "metadata_building_populate" do
    Metadata::Building.populate
  end
end

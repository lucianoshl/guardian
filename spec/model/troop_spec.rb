require 'rails_helper'

RSpec.describe Troop do
  it "Compare Troop and troop model types" do 

    Unit.names.map do |field_name|
      field_name = field_name.to_s
      expect(Troop.fields[field_name] == Model::Troop.fields[field_name]).to be false
    end

    model = Model::Troop.new(spear: 1.5)
    troop = Troop.new(spear: 1)
    
    expect(model.spear.class).to eq(Float)
    expect(troop.spear.class).to eq(Fixnum)

    expect(model.spear).to eq(1.5)
    expect(troop.spear).to eq(1)
  end
end
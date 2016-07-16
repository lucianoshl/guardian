require 'rails_helper'

RSpec.describe Property::SurfProxy, type: :model do

  it "pupulate_proxy" do
    Property::SurfProxy.populate
  end
end

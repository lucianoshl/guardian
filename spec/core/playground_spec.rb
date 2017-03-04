require 'rails_helper'

RSpec.describe "playground" do

  it "playground" do
    Job::SendAttack.first.execute
  end

end

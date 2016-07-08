require 'rails_helper'

RSpec.describe GuardianDeploy, type: :model do
  it "get_heroku_deploy" do
    GuardianDeploy.get_current_version
  end


end

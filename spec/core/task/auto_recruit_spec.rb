require 'rails_helper'

RSpec.describe Task::AutoRecruit, type: :model do
  it "test_recruit" do 
  	# stub_villages = [
  	# 	Village.where('387|426'.to_coordinate).first,
  	# 	Village.where('400|421'.to_coordinate).first,
  	# 	Village.where('400|418'.to_coordinate).first,

  	# ]
  	# Village.stub(:my) { stub_villages }
    Task::AutoRecruit.new.run
  end

end

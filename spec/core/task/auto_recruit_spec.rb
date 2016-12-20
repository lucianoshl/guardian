require 'rails_helper'

RSpec.describe Task::AutoRecruit, type: :model do
  it "test_recruit" do 
  	# stub_villages = [Village.where('357|401'.to_coordinate).first,Village.where('395|413'.to_coordinate).first]
  	# stub_villages = Village.my.limit(2)
  	# Village.stub(:my) { stub_villages }
    Task::AutoRecruit.new.run
  end

end

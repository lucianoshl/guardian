require 'rails_helper'

RSpec.describe Task::AutoRecruit, type: :model do
  it "test_recruit" do 
  	stub_villages = [Village.where(x:389,y:414).first]
  	Village.stub(:my) { stub_villages }
    Task::AutoRecruit.new.run
  end

end

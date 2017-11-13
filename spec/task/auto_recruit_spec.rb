require 'rails_helper'

RSpec.describe Task::AutoRecruit, type: :task do

  # stub_villages = [
  #   Village.where('671|525'.to_coordinate).first, 

  # ]
  # Village.stub(:my) { stub_villages }


  it "auto_build" do 
    Task::AutoRecruit.new.run
  end

  # it "distribute_resources" do 
  #   Task::AutoRecruit.new.distribute_resources
  # end
end
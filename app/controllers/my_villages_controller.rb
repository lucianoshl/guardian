class MyVillagesController < ApplicationController
  def index
    @villages = Village.my.to_a

    @screens = {}
    @villages.map { |v| @screens[v.vid] = Screen::Train.new(village: v.vid) }
  end

  def show
  end
end

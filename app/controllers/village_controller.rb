class VillageController < ApplicationController
  def index
    @all = Village.all
  end
end

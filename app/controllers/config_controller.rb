class ConfigController < ApplicationController
  def index
  end

  def change_distance
    binding.pry
    Config.pillager.distance = params[:distance].to_i
    Village.where(state:'far_away').map {|a| a.clean_state }
    redirect_to request.referer
  end
end

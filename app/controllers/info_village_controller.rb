class InfoVillageController < InjectedController
  def show
  	@village = Village.where(vid: params["id"].to_i).first
  end
end

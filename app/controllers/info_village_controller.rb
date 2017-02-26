class InfoVillageController < InjectedController
  def show
  	@village = Village.where(vid: params["id"].to_i).first
  	if (@village.nil?)
  		@village = Village.unsaved_village(vid: params["id"].to_i)
  	end
  end
end

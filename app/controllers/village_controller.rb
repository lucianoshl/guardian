class VillageController < ApplicationController
  def index
    nils, not_nils = Village.all.asc(:next_event).partition { |p| p.next_event.nil? }
    @villages = not_nils + nils
  end
end

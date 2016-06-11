class VillageController < ApplicationController
  def index
    nils, not_nils = Village.all.asc(:next_event).partition { |p| p.next_event.nil? }
    @villages = not_nils + nils

    hash = Village.distinct(:state).pmap {|a| [a,Village.where(state: a).count] }.to_h
    @data = {
      labels: hash.keys,
      datasets: [
        {
            label: "My First dataset",
            backgroundColor: [
                'rgba(255, 99, 132, 1)',
                'rgba(54, 162, 235, 1)',
                'rgba(255, 206, 86, 1)',
                'rgba(75, 192, 192, 1)',
                'rgba(153, 102, 255, 1)',
                'rgba(255, 159, 64, 1)'
            ],
            data: hash.values
        }
      ]
    }
  end
end

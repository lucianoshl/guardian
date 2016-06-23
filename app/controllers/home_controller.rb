class HomeController < ApplicationController
	def index
    graph_loot = Screen::StatsOwn.new.graph_loot.reverse

    @graph_loot = {
      labels: graph_loot.map{|a| Time.at(a.first.to_i/1000).to_date }, 
      datasets: [
        {
          label: "Total saqueado",
          backgroundColor: "green",
          borderColor: "rgba(220,220,220,1)",
          data: graph_loot.map{|a| a.last}
        }
      ]
    }
    @opts = {
      height: 100,
      legend: {
        display: false
      },
      scales:
      {
          xAxes: [{
              display: false
          }]
      }
    }
  end
end

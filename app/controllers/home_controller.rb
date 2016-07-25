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

    states = Village.distinct(:state).select{|a| a != "far_away"}
    chart = states.pmap {|a| [a,Village.where(state: a).count] }.sort{|a,b| a[1] <=> b[1]}.reverse


    generator = ColorGenerator.new saturation: 1, value: 1.0

    colors = (1..chart.size).map { "rgba(#{generator.create_rgb.join(',')}, 1)" }

    @data = {
      labels: chart.map(&:first),
      datasets: [
        {
            label: "My First dataset",
            backgroundColor: colors,
            data: chart.map(&:last)
        }
      ]
    }

    @opts = {
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

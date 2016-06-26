class VillageController < ApplicationController
  def index

    query = Village.asc(:next_event)
    if (!params[:threat].nil?)
        query = query.in(state: [:has_troops,:strong,:trops_without_spy])
    end

    if (!params[:farms].nil?)
        query = query.not_in(state: [:has_troops,:strong])
    end

    nils, not_nils = query.partition { |p| p.next_event.nil? }
    @villages = not_nils + nils

    # chart = Village.distinct(:state).pmap {|a| [a,Village.where(state: a).count] }.sort{|a,b| a[1] <=> b[1]}.reverse


    # generator = ColorGenerator.new saturation: 1, value: 1.0

    # colors = (1..chart.size).map { "rgba(#{generator.create_rgb.join(',')}, 1)" }

    # @data = {
    #   labels: chart.map(&:first),
    #   datasets: [
    #     {
    #         label: "My First dataset",
    #         backgroundColor: colors,
    #         data: chart.map(&:last)
    #     }
    #   ]
    # }

    # chart = [
    #   Village.in(state: [:strong,:has_troops]).count,
    #   Village.in(state: [:ally]).count,
    #   Village.not_in(state: [:strong,:has_troops,:ally]).count,
    #   11
    # ]

    # @data2 = {
    #   labels: ["Ameaça","Neutro","Farm"],
    #   datasets: [
    #     {
    #         label: "Aldeias",
    #         backgroundColor: ["red","grey","blue"],
    #         data: chart
    #     }
    #   ]
    # }
  end

  def show
    @village = Village.find(params["id"])
    @points_history_chart = {
      labels: @village.points_history.map{|a| a["date"].strftime("%d/%m %H:%M") + " " + a["difference"].to_s  },
      datasets: [
        {
            label: "Evolução",
            backgroundColor: "white",
            borderColor: "green",
            data: @village.points_history.map{|a| a["points"] } 
        }
      ]
    }
    
    @opts = {
      height: 200,
      scaleOverride: true,
        scaleSteps: 2,
        scaleStepWidth: 5,
        scaleStartValue: 0 ,
      legend: {
        display: false
      }
    }

  end

  def waiting_report
    render :text => Village.in(state: :waiting_report).to_a.to_yaml, :content_type => 'text/yaml'
  end

  def last_report
    village = Village.where(vid: params[:vid]).first
    if (village.nil?)
      render :text => nil.to_yaml, :content_type => 'text/yaml'
      return
    end
    render :text => village.reports.desc(:occurrence).last.to_yaml, :content_type => 'text/yaml'
  end

end

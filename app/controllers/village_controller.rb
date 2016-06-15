class VillageController < ApplicationController
  def index

    query = Village.asc(:next_event)
    if (!params[:threat].nil?)
        query = query.in(state: [:has_troops,:strong])
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
  end
end

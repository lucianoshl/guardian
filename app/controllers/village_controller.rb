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
    result = Village.in(state: :waiting_report).gte(next_event: Time.zone.now).to_a
    result.each{ |a| a.points_history = nil }
    render :text => result.to_yaml, :content_type => 'text/yaml'
  end

  def last_report
    village = Village.where(vid: params[:vid]).first
    if (village.nil?)
      render :text => nil.to_yaml, :content_type => 'text/yaml'
      return
    end

    map = village.last_report.attributes
    map["origin_vid"] = Village.find(map.delete("origin_id")).vid
    map["target_vid"] = Village.find(map.delete("target_id")).vid
    
    render :text => map.to_yaml, :content_type => 'text/yaml'
  end

  def reset
    Village.find(params["id"]).clean_state
    redirect_to request.referer
  end

  def send_recognition
    Village.find(params["id"]).move_to_state("send_recognition")
    redirect_to request.referer
  end

end

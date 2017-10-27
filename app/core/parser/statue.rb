class Parser::Statue < Parser::Basic

  def parse(screen)
    super
    infos = JSON.parse(@page.body.scan(/BuildingStatue.receiveKnightsData\(\[\]\, ({.+}), 0\)/).flatten.first)

    screen.paladin_information = {}

    infos.map do |village_id,info|
      item = screen.paladin_information[village_id.to_i] = OpenStruct.new
      item.training_finish_time = info["activity"]["finish_time"]
      item.in_training = !item.training_finish_time.nil?

      item.training_finish_time = Time.at(item.training_finish_time) if item.in_training
      
      item.cost = info["usable_regimens"].first["res_cost"].to_resource
    end
  end

end

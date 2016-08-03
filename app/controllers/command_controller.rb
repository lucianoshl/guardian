class CommandController < ApplicationController

  helper_method :out_values

  def index
    all_places = Screen::Place.load_all
    @commands = (all_places.map(&:commands).flatten.pmap do |command|
      key = "command_controller_command_#{command.id}_#{command.returning}"
      
      json_extra = Rails.cache.fetch(key, expires_in: 1.year) do
        JSON.parse(Screen::Logged.client.get("https://#{User.current.world}.tribalwars.com.br/game.php?village=#{command.origin.vid}&screen=info_command&ajax=details&id=#{command.id}").body)
      end

      next if (!json_extra["no_authorization"].nil?)
      command.troops = Troop.new(json_extra["units"].map{|unit,info| [unit,info["count"].to_i]}.to_h)
      command.pillage = Resource.new(json_extra["booty"]) if (!json_extra["booty"].nil?)
      command
    end).compact

    @spy_commands = @commands.select do |item|
      ( item.troops.spy || 0 ) == item.troops.total
    end

    @pillage_commands = @commands - @spy_commands

    @incomings = all_places.map(&:incomings).flatten

  end

  def out_values(commands)
    out_troops = Troop.new
    out_pillage = Resource.new
    commands.map do |command|
      out_troops += command.troops if (!command.troops.nil?)
      out_pillage += command.pillage if (!command.pillage.nil?)
    end
    [out_troops,out_pillage]
  end
end

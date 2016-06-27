class Report
  include Mongoid::Document
  include Mongoid::Enum

  field :erase_url, type: String
  enum :status, [:win, :lost, :win_lost, :spy, :error, :spy_lost ]
  belongs_to :origin, class_name: Village.to_s
  belongs_to :target, class_name: Village.to_s
  field :occurrence, type: DateTime
  field :luck, type: Float
  field :moral, type: Float

  field :origin_troops, type: Hash
  field :origin_troops_losses, type: Hash

  field :target_troops, type: Hash
  field :target_troops_losses, type: Hash
  field :target_troops_away, type: Hash
  
  field :target_buildings, type: Hash

  field :full_pillage, type: Boolean

  field :read, type: Boolean, default: false

  embeds_one :pillage, as: :resourcesable, class_name: Resource.to_s
  embeds_one :resources, as: :resourcesable, class_name: Resource.to_s

  scope :important,->(){not_in(_status: [:win,:spy]).where(read: false).desc(:occurrence)}

  def erase screen
    screen.request(self.erase_url)
  end

  def has_spy_losses?
    !origin_troops_losses["spy"].nil? && origin_troops_losses["spy"] > 0
  end

  def has_troops?
     (Troop.new(target_troops) - Troop.new(target_troops_losses) + Troop.new(target_troops_away)).total > 0
  end

  def hour_production
      production = lambda do |level| 
        return 5 if (level.zero?)
        (30*1.163118 ** (level - 1)).ceil * 2
      end
      
      total_production_per_hour = 0
      total_production_per_hour += production.call(self.target_buildings["wood"] || 0)
      total_production_per_hour += production.call(self.target_buildings["stone"] || 0)
      total_production_per_hour += production.call(self.target_buildings["iron"] || 0)  
      total_production_per_hour.to_f
  end

  def rams_to_destroy_wall
    wall = self.target_buildings["wall"]

    results = {}
    results[1] = 2 
    results[2] = 7
    results[3] = 13
    results[4] = 20
    results[5] = 28
    results[6] = 37
    results[7] = 48
    results[8] = 60
    results[9] = 74
    results[10] = 90
    results[11] = 108
    results[12] = 129
    results[13] = 153
    results[14] = 180
    results[15] = 211
    results[16] = 246
    results[17] = 286
    results[18] = 330
    results[19] = 380
    results[20] = 437


    return results[wall]
  end

  def self.pillage_statistics
    days = Report.distinct(:occurrence).map{|a| a.in_time_zone(Time.zone.name) }.map(&:beginning_of_day).uniq.sort - [Time.zone.now.beginning_of_day.to_time]
    percents = days.map do |day|
      Rails.cache.fetch("pillage_statistics_#{day}") do
        itens = Report.gte(occurrence: day).lte(occurrence: day + 1.day).where(_status: :win).to_a
        occurrences = Report.gte(occurrence: day).lte(occurrence: day + 1.day).map(&:occurrence)
        percent = itens.select(&:full_pillage).size / itens.size.to_f
        speed = occurrences.each_with_index.map{|a,i| (occurrences[i].to_i - occurrences[i-1].to_i) }.max/1.hour
        [day,speed,percent]
      end
    end
  end

end
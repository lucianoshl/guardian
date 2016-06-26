class Partner
  include Mongoid::Document
  include Mongoid::Enum

  field :host, type: String

  def self.is_attacking?(target)
    villages = for_all("/village/waiting_report").map{|a| Village.new(a)}

    villages = villages.select{|a| a.next_event > Time.zone.now }

    same = villages.select{|other| target.distance(other).zero? }.first
    if (same.nil?)
      return nil
    end
    same.next_event
  end

  def self.last_report(target)
    reports = for_all("/village/#{target.vid}/last_report").map do |a|
      origin = Village.where(vid: a.delete("origin_vid")).first || Village.my.first
      target = Village.where(vid: a.delete("target_vid")).first
      a.delete('_id')
      r = Report.new(a)
      r.origin = origin
      r.target = target
      r
    end
    reports.sort{|a,b| a.occurrence <=> b.occurrence }.last
  end

  def self.for_all(url)
    Rails.cache.fetch("#{url}-for-#{count}", expires_in: 1.minute) do
      (all.to_a.map(&:host).map do |base| 
        begin
          YAML.load(Mechanize.my.get("#{base}#{url}").body)
        rescue
          nil
        end
      end).compact.flatten
    end
  end

end
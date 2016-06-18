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
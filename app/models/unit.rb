class Unit
	include Mongoid::Document

	field :name, type: String
	field :label, type: String
	field :type, type: String
	field :carry, type: Integer
	field :attack, type: Integer 
	field :speed, type: Float

	embeds_one :cost, as: :resourcesable, class_name: Resource.to_s

	@@memory_cache = {}

	def self.get name
		if (@@memory_cache[name].nil?)
			@@memory_cache = Rails.cache.fetch("unit_#{name}") do
				Unit.where(name:name).first
			end
		end
		return @@memory_cache[name]
	end

	def square_per_minutes
		(1 / (speed * 60)).round(2)
	end
end
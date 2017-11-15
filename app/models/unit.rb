class Unit
	include Mongoid::Document

	field :name, type: String
	field :label, type: String
	field :carry, type: Integer
	field :attack, type: Integer 
	field :general_defense, type: Integer 
	field :cavalry_defense, type: Integer 
	field :population, type: Integer 
	field :speed, type: Float

	embeds_one :cost, as: :resourcesable, class_name: Resource.to_s

	def self.get name
		Rails.cache.fetch("unit_#{name}") do
			Unit.where(name:name).first
		end
	end

	def self.names
		Rails.cache.fetch("unit_names") do
			Unit.all.map(&:name).map(&:to_sym)
		end
	end
	
	def square_per_minutes
		speed
	end
end
class Unit
	include Mongoid::Document

	field :name, type: String
	field :label, type: String
	field :carry, type: Integer
	field :attack, type: Integer 
	field :population, type: Integer 
	field :speed, type: Float

	embeds_one :cost, as: :resourcesable, class_name: Resource.to_s

	def self.get name
		Rails.cache.fetch("unit_#{name}") do
			Unit.where(name:name).first
		end
	end

	def self.names
		# Unit.all.map(&:name).map(&:to_sym)
		[:spear, :sword, :axe, :spy, :light, :heavy, :ram, :catapult, :knight, :snob, :militia]
	end


	def square_per_minutes
		(1 / (speed * 60)).round(2)
	end
end
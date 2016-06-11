class Unit
	include Mongoid::Document

	field :name, type: String
	field :label, type: String
	field :type, type: String
	field :carry, type: Integer
	field :attack, type: Integer 
	field :speed, type: Float

	def self.get name
		Rails.cache.fetch("unit_#{name}") do
			Unit.where(name:name).first
		end
	end
end
class Model::Troop < Troop
  # self.fields = self.fields.deep_dup
  Unit.names.map do |unit_name|
    field unit_name.to_sym, type: Float, default: 0, overwrite: true
  end
  # binding.pry
end

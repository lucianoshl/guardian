class Model::Troop < Troop
  # self.fields = self.fields.deep_dup
  Unit.names.map do |unit_name|
    field unit_name.to_sym, type: Float, default: 0, overwrite: true
    # fields[unit_name] = fields[unit_name].deep_dup
    # fields[unit_name].options = fields[unit_name].options.deep_dup
    # fields[unit_name].options[:type] = Float
    # fields[unit_name].options[:klass] = self
  end
  # binding.pry
end

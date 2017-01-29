class Model::Troop < Troop
  Unit.names.map do |unit_name|
    field unit_name.to_sym, type: Float, default: 0
  end
end

class ImpossibleUpgrade < Exception
end

class Troop
  include Mongoid::Document

  embedded_in :village

  Unit.names.map do |unit_name|
    field unit_name.to_sym, type: Integer, default: 0
  end

  def total
    self.to_h.values.inject(&:+) || 0
  end

  def validate
    if (self.to_h.values.select{|a| a < 0}.size > 0)
      raise Exception.new("Invalid troop")
    end
  end

  def contains other 
    result = self - other
    result.to_h.values.select{|a| a < 0}.empty?
  end

  def slow_unit
    self.to_h.select{|unit,qte| qte > 0}.keys.map{|a| Unit.get(a) }.sort{|a,b| a.speed <=> b.speed }.last
  end

  def fastest_unit
    self.to_h.select{|unit,qte| qte > 0}.keys.map{|a| Unit.get(a) }.sort{|b,a| a.speed <=> b.speed }.last
  end

  def travel_time origin,target
    (slow_unit.square_per_minutes * origin.distance(target)).minutes
  end

  def distribute amount
    troops = self.clone.to_h
    result = {}
    Unit.gt(carry:0).not_in(name: :knight).asc(:speed).map do |unit|
      unit_qte = troops[unit.name] || 0
      if (unit_qte > 0)
        while (amount > 0 && !unit_qte.zero?)
          unit_qte = troops[unit.name] -= 1
          result[unit.name] = (result[unit.name] || 0) + 1
          amount -= unit.carry
        end
      end
    end
    return Troop.new(result)
  end

  def win?(moral,wall,night_bonus)
    parameters = {}
    parameters[:luck] = '-25'
    parameters[:def_wall] = wall
    parameters[:moral] = moral || 0
    parameters[:night] = 'on' if (night_bonus)
    self.to_h.each do |unit, qte|
      parameters["att_#{unit}"] = qte.to_s
    end

    !Screen::Simulator.new(parameters).has_losses
  end

  def upgrade(disponible,pillage)
    troops = self.clone.to_h
    troops.each do |unit,qte|
      if (qte.zero?)
        troops.delete(unit)
      end
    end
    disponible = disponible.clone.to_h

    alternatives = disponible.sort{|b,a| Unit.get(a[0]).attack <=> Unit.get(b[0]).attack }.select{|a| a[1] > 0 && Unit.get(a[0]).carry > 0}

    strong_order = troops.sort{|b,a| Unit.get(a[0]).attack <=> Unit.get(b[0]).attack }

    weak_unit = strong_order.reverse.select{|unit,qte| Unit.get(unit).carry > 0}.first.first

    alternatives.map do |unit,qte|
      if (weak_unit == unit || Unit.get(unit).attack <= Unit.get(weak_unit).attack)
        break
      end
      troops[unit] = (troops[unit] || 0) + 1
      actual_carry = Troop.new(troops).carry

      while(actual_carry - Unit.get(weak_unit).carry >= pillage)
        if (troops[weak_unit] == 0)
          weak_order = troops.sort{|a,b| Unit.get(a[0]).attack <=> Unit.get(b[0]).attack }.select{|a,b| b> 0}
          raise ImpossibleUpgrade.new if weak_order.empty?
          weak_unit = weak_order.first.first
          next
        end
        troops[weak_unit] -= 1
        actual_carry = Troop.new(troops).carry
      end
      break
    end
    
    raise ImpossibleUpgrade.new if (self.eq?(troops))

    return Troop.new(troops)
  end

  def eq?(other)
    if (other.class == Hash)
      return Troop.new(other).to_h == self.to_h
    end
    other.to_h == self.to_h
  end

  def carry
    total = 0
    self.to_h.each do |unit, qte|
      total += Unit.get(unit).carry*qte
    end
    return total
  end

  def cost
    result = Resource.new(wood:0,stone:0,iron:0)
    self.to_h.each do |unit, qte|
      result += Unit.get(unit).cost*qte
    end
    return result
  end


  def -(other)
    result = self.clone

    Unit.names.map do |unit|
      qte = self.send("#{unit}") || 0
      self.send("#{unit}=",qte)

      other_qte = other.send("#{unit}")
      if (!other_qte.nil?)
        qte_result = qte - other_qte
        result.send("#{unit}=",qte_result)
      end

    end
    result
  end

  def population
    troops = self.to_h
    total = 0
    self.to_h.map do |unit,qte|
      total += Unit.get(unit).population*(qte||0)
    end
    total
  end

  def increase_population(disponible,target_population)
    result = self.clone.to_h
    disponible = (disponible - self).to_h
    actual_pop = self.population

    Unit.gt(carry:0).asc(:carry).map do |unit|
      qte = disponible[unit.name]
      if (!qte.nil? && !qte.zero?)
        while(actual_pop < target_population && qte > 0)
          result[unit.name] ||= 0
          result[unit.name] += 1
          qte -= 1
          actual_pop += unit.population
        end
      end
    end
    result = Troop.new(result)

    if (result.population != target_population)
      raise ImpossibleUpgrade.new
    end

    return result
  end

  def +(other)
    result = self.to_h.clone
    other = other.to_h.clone
    Unit.names.map(&:to_s).map do |unit_name|
      result[unit_name] ||= 0
      result[unit_name] += (other[unit_name] || 0)
    end
    return Troop.new(result)
  end

  def *(value)
    result = self.to_h.clone
    result.map do |unit,qte|
      result[unit] *= value
    end
    return Troop.new(result)
  end


  def to_h
    r = self.attributes.clone
    r.delete('_id')
    return r
  end

  def remove_negative
    result = self.to_h.clone
    result.map do |unit,qte|
      if (qte < 0)
        result.delete(unit)
      end
    end
    return Troop.new(result)
  end

  def from_building name
    locations = {
      barracks: ['spear','sword','axe'],
      stable: ['spy','light','heavy'],
      garage: ['ram','catapult']
    }
    result = self.to_h.clone
    result.map do |unit,qte|
      if (!locations[name.to_sym].include?(unit.to_s))
        result[unit] = 0
      end
    end
    return Troop.new(result)
  end

  def self.get_building(unit)
    unit = unit.to_s
    locations = {
      barracks: ['spear','sword','axe'],
      stable: ['spy','light','heavy'],
      garage: ['ram','catapult']
    }

    locations.map do |building,units|
      return building if units.include?(unit)
    end
  end

  def self.from_building?(building,name)
    locations = {
      barracks: ['spear','sword','axe'],
      stable: ['spy','light','heavy'],
      garage: ['ram','catapult']
    }
    return locations[building.to_sym].include?(name.to_s)
  end

end
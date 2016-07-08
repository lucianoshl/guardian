class ImpossibleUpgrade < Exception

end

class Troop
  include ActiveAttr::MassAssignment

  Unit.all.map(&:name).map(&:to_sym).map do |unit_name|
    attr_accessor unit_name
  end

  def total
    self.instance_values.values.inject(&:+) || 0
  end

  def validate
    if (self.instance_values.values.select{|a| a < 0}.size > 0)
      raise Exception.new("Invalid troop")
    end
  end

  def contains other 
    result = self - other
    result.instance_values.values.select{|a| a < 0}.empty?
  end

  def slow_unit
    self.instance_values.select{|unit,qte| qte > 0}.keys.map{|a| Unit.get(a) }.sort{|a,b| a.speed <=> b.speed }.first
  end

  def travel_time origin,target
    slow_unit.square_per_minutes * origin.distance(target)
  end

  def distribute amount
    troops = self.clone.instance_values
    result = {}
    Unit.gt(carry:0).not_in(name: :knight).asc(:attack).map do |unit|
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
    self.instance_values.each do |unit, qte|
      parameters["att_#{unit}"] = qte.to_s
    end

    !Screen::Simulator.new(parameters).has_losses
  end

  def upgrade(disponible,pillage)
    troops = self.clone.instance_values
    troops.each do |unit,qte|
      if (qte.zero?)
        troops.delete(unit)
      end
    end
    disponible = disponible.clone.instance_values

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
    
    raise ImpossibleUpgrade.new if (self.instance_values == troops)

    return Troop.new(troops)
  end

  def carry
    total = 0
    self.instance_values.each do |unit, qte|
      total += Unit.get(unit).carry*qte
    end
    return total
  end

  def cost
    result = Resource.new(wood:0,stone:0,iron:0)
    self.instance_values.each do |unit, qte|
      result += Unit.get(unit).cost*qte
    end
    return result
  end


  def -(other)
    result = self.clone

    result.spear ||= 0
    result.sword ||= 0
    result.axe ||= 0
    result.archer ||= 0
    result.spy ||= 0
    result.light ||= 0
    result.marcher ||= 0
    result.heavy ||= 0
    result.ram ||= 0
    result.catapult ||= 0
    result.knight ||= 0
    result.snob ||= 0

    result.spear -= other.spear || 0
    result.sword -= other.sword || 0
    result.axe -= other.axe || 0
    result.archer -= other.archer || 0
    result.spy -= other.spy || 0
    result.light -= other.light || 0
    result.marcher -= other.marcher || 0
    result.heavy -= other.heavy || 0
    result.ram -= other.ram || 0
    result.catapult -= other.catapult || 0
    result.knight -= other.knight || 0
    result.snob -= other.snob || 0
    result
  end

    def +(other)
    result = self.clone

    result.spear ||= 0
    result.sword ||= 0
    result.axe ||= 0
    result.archer ||= 0
    result.spy ||= 0
    result.light ||= 0
    result.marcher ||= 0
    result.heavy ||= 0
    result.ram ||= 0
    result.catapult ||= 0
    result.knight ||= 0
    result.snob ||= 0

    result.spear += other.spear || 0
    result.sword += other.sword || 0
    result.axe += other.axe || 0
    result.archer += other.archer || 0
    result.spy += other.spy || 0
    result.light += other.light || 0
    result.marcher += other.marcher || 0
    result.heavy += other.heavy || 0
    result.ram += other.ram || 0
    result.catapult += other.catapult || 0
    result.knight += other.knight || 0
    result.snob += other.snob || 0
    result
  end

  def *(value)
    result = self.instance_values.clone
    result.map do |unit,qte|
      result[unit] *= value
    end
    return Troop.new(result)
  end

end
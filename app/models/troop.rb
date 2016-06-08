class Troop
  include ActiveAttr::MassAssignment
  attr_accessor :spear,:sword,:axe,:archer,:spy,:light,:marcher,:heavy,:ram,:catapult,:knight,:snob,:militia

  def total
    self.instance_values.values.inject(&:+) || 0
  end

  def contains other
    result = self - other
    result.instance_values.values.select{|a| a < 0}.empty?
  end

  def -(other)
    result = self.clone
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

end
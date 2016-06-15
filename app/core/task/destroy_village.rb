class Task::DestroyVillage < Task::Abstract

  in_development true

  def run
    @origin = Village.my.first
    @target = (Village.in(state: :has_troops).to_a.sort do |a,b|
      a.distance(@origin) <=> b.distance(@origin)
    end).first
  end

end

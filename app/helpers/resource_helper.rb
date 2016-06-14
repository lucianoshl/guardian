module ResourceHelper
  def render_resource resource
    binding.pry if (!resource.nil?)
  end
end

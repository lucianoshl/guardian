module ApplicationHelper

  def progress_bar size,color
  %{
    <div class="progress"> 
      <div class="progress-bar progress-bar-#{color}" role="progressbar" aria-valuenow="#{size}" aria-valuemin="0" aria-valuemax="100" style="width: #{size}%">
        <span class="sr-only">#{size}% Complete (success)</span>
      </div>
    </div>
  }.html_safe
  end


  def active_route?(route)
    request.path.include?(route) ? "active" : ""
  end
end

Rails.application.routes.draw do
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  root to: -> (env) do
    erb_renderer = ActionView::Base.new(ActionController::Base.view_paths, {})
    [ 
        200,
        {"Content-Type" => "text/html"},
        [erb_renderer.render(file: 'public/index.html.erb')]
    ]
  end

end

Rails.application.routes.draw do
  if Rails.env.development?
    mount GraphiQL::Rails::Engine, at: "/graphiql", graphql_path: "/graphql"
  end

  post "/graphql", to: "graphql#execute"
  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'

  get 'task/run_now/:id' => 'task#run_now'

  root to: -> (env) do
    erb_renderer = ActionView::Base.new(ActionController::Base.view_paths, {})
    [ 
        200,
        {"Content-Type" => "text/html"},
        [erb_renderer.render(file: 'public/index.html.erb')]
    ]
  end

end

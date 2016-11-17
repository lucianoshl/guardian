Rails.application.routes.draw do

  get 'dashboard/index'

  get 'config/index'


  get 'game.php' => 'tribal_wars#proxy'
  post 'game.php' => 'tribal_wars#proxy'
  get 'map.php' => 'tribal_wars#proxy'
  post 'map.php' => 'tribal_wars#proxy'
  get 'page.php' => 'tribal_wars#page'
  get 'graphic/:name' => 'tribal_wars#page' 
  post 'page.php' => 'tribal_wars#page'

  get 'report/read_all'
  get 'village/:vid/last_report' => 'village#last_report'
  get 'village/:id/reset' => 'village#reset'
  get 'village/:id/send_recognition' => 'village#send_recognition'

  get 'task/run_now/:id' => 'task#run_now'

  get 'village/waiting_report' => 'village#waiting_report'

  resources :village,:task,:report,:my_villages,:task,:command

  resources :my_villages do
    member do
      get '/pillage/change' => 'my_villages#pillage_change'
    end
  end

  get 'cookie/latest'

  mount RailsAdmin::Engine => '/admin', as: 'rails_admin'
  root 'task#index'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end

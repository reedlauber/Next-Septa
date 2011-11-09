Nextsepta::Application.routes.draw do
  root :to => "home#index"
  
  get "/beta" => "home#index"
  get "/info" => "info#index"
  get "/debug" => "debug#index"
  
  get "/search(/:term)" => "search#index"
  
  get "/locations/:route_id" => "location#index"
  
  match ':controller(/:action(/:id(.:format)))'
  
  get "/:route_type/:route_id/:direction/:from_stop(/:to_stop)/map" => "map#index"
  get "/:route_type/:route_id/:direction/:from_stop/choose" => "stops#to"
  get "/:route_type/:route_id/:direction/:from_stop/:to_stop" => "stops#index"
  get "/:route_type/:route_id/:direction/:from_stop" => "stops#index"
  get "/:route_type/:route_id/:direction" => "stops#from"
  get "/:route_type/:route_id" => "directions#index"
  get "/:route_type" => "route_type#index"
end

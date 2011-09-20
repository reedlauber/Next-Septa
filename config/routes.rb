Nextsepta::Application.routes.draw do
  root :to => "home#index"
  
  get "/beta" => "home#index"
  
  get "/search(/:term)" => "search#index"
  
  get "/:route_type/:route_id/:direction/:from_stop/nodest" => "stops#index"
  get "/:route_type/:route_id/:direction/:from_stop/:to_stop" => "stops#index"
  get "/:route_type/:route_id/:direction/:from_stop" => "stops#to"
  get "/:route_type/:route_id/:direction" => "stops#from"
  get "/:route_type/:route_id" => "directions#index"
  get "/:route_type" => "route_type#index"
  
  match ':controller(/:action(/:id(.:format)))'
end

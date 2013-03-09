Nextsepta::Application.routes.draw do
  root :to => "home#index"
  #root :to => "content#upgrade"

  get "/beta" => "home#index"
  get "/info" => "content#info"
  get "/upgrade" => "content#upgrade"
  get "/debug" => "debug#index"

  get "/search(/:term)" => "search#index"

  get "/locations/:route_id" => "location#index"

  get "/data/:route_id/:direction_id/:trip_id/:stop_id" => "data#times"
  get "/data/:route_id/:direction_id/:trip_id" => "data#stops"
  get "/data/:route_id/:direction_id" => "data#trips"
  get "/data/:route_id" => "data#directions"
  get "/data" => "data#routes"

  #match ':controller(/:action(/:id(.:format)))'

  get "/:route_type/:route_id/map" => "map#index"
  get "/:route_type/:route_id/:direction/:from_stop(/:to_stop)/map" => "map#vehicle"
  get "/:route_type/:route_id/:direction/:from_stop/choose" => "stops#to"
  get "/:route_type/:route_id/:direction/:from_stop/:to_stop" => "stops#index"
  get "/:route_type/:route_id/:direction/:from_stop" => "stops#index"
  get "/:route_type/:route_id/:direction" => "stops#from"
  get "/:route_type/:route_id" => "directions#index"
  get "/:route_type" => "routes#index"
end
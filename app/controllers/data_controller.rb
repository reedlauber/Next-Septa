class DataController < ApplicationController
  def routes
    @routes = Route.where("").order("lpad(route_short_name, 6, '0')")
    render :layout => "data"
  end
  
  def directions
    @route_id = params[:route_id].upcase
    @route = Route.where("route_short_name = ?", @route_id).first
    @directions = RouteDirection.where("route_id = ?", @route.route_id).order("direction_id")
    render :layout => "data"
  end
  
  def stops
    @route_id = params[:route_id].upcase
    @route = Route.where("route_short_name = ?", @route_id).first
    @direction = RouteDirection.where("route_id = ? AND direction_id = ?", @route.route_id, params[:direction_id]).first
    @stops = SimplifiedStop.where("route_id = ? and direction_id = ?", @route.route_id, @direction.direction_id)
    render :layout => "data"
  end
  
  def times
    @route_id = params[:route_id].upcase
    @route = Route.where("route_short_name = ?", @route_id).first
    @direction = RouteDirection.where("route_id = ? AND direction_id = ?", @route.route_id, params[:direction_id]).first
    @stop = SimplifiedStop.where("route_id = ? and direction_id = ? and stop_id = ?", @route.route_id, @direction.direction_id, params[:stop_id])
    @times = StopTime.where("")
    render :layout => "data"
  end
end

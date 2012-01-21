class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :read_request_filter
  
  ROUTE_TYPES = { "subways" => 1, "trains" => 2, "buses" => 3, "trolleys" => 0 }
  ROUTE_TYPE_IDS = { 1 => "subways", 2 => "trains", 3 => "buses", 0 => "trolleys" }

  def create_headers
  end

  private
  
  def check_cookies
    @last_stop = cookies[:last_stop]
  end

  def read_request_filter
    check_cookies
    read_params
  end
  
  def read_params
    @title = "NEXT&rarr;Septa | Next Stop Times for SEPTA Buses, Subways and Tolleys".html_safe
    
    if(params[:route_id] != nil)
      read_params_route
    end
  end
  
  def read_params_route
    @route_id = params[:route_id].upcase
    @route = Route.find(:all, :conditions => ["route_short_name = ?", @route_id]).first
    
    if(@route != nil)
      @title = "#{@route.route_short_name} | NEXT&rarr;Septa".html_safe
      
      @route_type = params[:route_type]
    
      if(params[:direction] != nil)
        read_params_direction
      end
    else
      render "notfound"
    end
  end
  
  def read_params_direction
    @direction_id = params[:direction]
    @direction = RouteDirection.find(:all, :conditions => ["route_short_name = ? AND direction_id = ?", @route_id, params[:direction]]).first
  
    if(@direction != nil)
      if(params[:from_stop] != nil && params[:from_stop] != "nodest")
        read_params_stops
      end
    else
      render "notfound"
    end
  end
  
  def read_params_stops
    @from = SimplifiedStop.where("route_id = ? AND stop_id =? AND direction_id = ?", @route.route_id, params[:from_stop], @direction.direction_id).first
  
    if(params[:to_stop] != nil)
      @to = SimplifiedStop.find(:all, :conditions => ["route_id = ? AND stop_id = ?", @route.route_id, params[:to_stop]]).first
    end
  end
end

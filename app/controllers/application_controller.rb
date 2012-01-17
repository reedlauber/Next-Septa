class ApplicationController < ActionController::Base
  protect_from_forgery
  before_filter :check_cookies
  
  ROUTE_TYPES = { "subways" => 1, "trains" => 2, "buses" => 3, "trolleys" => 0 }
  ROUTE_TYPE_IDS = { 1 => "subways", 2 => "trains", 3 => "buses", 0 => "trolleys" }
  
  def check_cookies
    @last_stop = cookies[:last_stop]
  end
  
  def create_headers
    @title = "NEXT&rarr;Septa | Next Stop Times for SEPTA Buses, Subways and Tolleys".html_safe
    @header_2 = "Choose Route"
    @header_choose = "h2"
    
    if(params[:route_id] != nil)
      create_headers_route
    end
  end
  
  def create_headers_route
    @route_id = params[:route_id].upcase
    @route = Route.find(:all, :conditions => ["route_short_name = ?", @route_id]).first
    
    if(@route != nil)
      @title = "#{@route.route_short_name} | NEXT&rarr;Septa".html_safe
      
      @route_type = params[:route_type]
      
      @header_2 = "<span class=\"nxs-routelabel\">#{@route.route_short_name}</span> #{@route.route_long_name}".html_safe
      @header_2_path = "/#{@route_type}/#{@route_id}"
    
      @header_3 = "Choose Direction"
    
      @header_choose = "h3"
    
      if(params[:direction] != nil)
        create_headers_direction
      end
    else
      @header_2 = nil
      @header_choose = nil
      render "notfound"
    end
  end
  
  def create_headers_direction
    @direction_id = params[:direction]
    @direction = RouteDirection.find(:all, :conditions => ["route_short_name = ? AND direction_id = ?", @route_id, params[:direction]]).first
  
    if(@direction != nil)
      # @title = "#{@route.route_short_name} - To #{@direction.direction_name} | NEXT&rarr;Septa".html_safe
      
      @header_2 = "<span class=\"nxs-routelabel\">#{@route.route_short_name}</span> &rarr; #{@direction.direction_name}".html_safe
      @header_2_path = "/#{@route_type}/#{@route_id}/#{@direction_id}"
  
      @header_3 = "Choose Starting Station"
  
      if(params[:from_stop] != nil && params[:from_stop] != "nodest")
        create_headers_from
      end
    else
      render "notfound"
    end
  end
  
  def create_headers_from
    @from = SimplifiedStop.where("route_id = ? AND stop_id =? AND direction_id = ?", @route.route_id, params[:from_stop], @direction.direction_id).first
  
    if(params[:to_stop] == nil)
      path = "/#{@route_type}/#{@route_id}/#{@direction_id}/#{@from.stop_id}/choose"
      @header_3 = ("<span>#{@from.stop_name} &rarr; <a href=\"#{path}\" class=\"nxs-choose\">choose</a></span>").html_safe
    else
      @to = SimplifiedStop.find(:all, :conditions => ["route_id = ? AND stop_id = ?", @route.route_id, params[:to_stop]]).first
    
      @header_3 = ("<span>#{@from.stop_name} &rarr; #{@to.stop_name}</span>").html_safe
    
      @header_choose = "h4"
    end
  end
end

class ApplicationController < ActionController::Base
  protect_from_forgery
  
  ROUTE_TYPES = { "subways" => 1, "trains" => 2, "buses" => 3, "trolleys" => 0 }
  ROUTE_TYPE_IDS = { 1 => "subways", 2 => "trains", 3 => "buses", 0 => "trolleys" }
  
  def create_headers
    @header_2 = "Choose Route"
    @header_choose = "h2"
    
    if(params[:route_id] != nil)
      create_headers_route
    end
  end
  
  def create_headers_route
    @route_id = params[:route_id]
    @route = Route.where("route_short_name = '#{params[:route_id]}'").first
    
    if(@route != nil)
      @route_type = params[:route_type]
      
      @header_2 = "<span class=\"nxs-routelabel\">#{@route.route_short_name}</span>".html_safe
      @header_2_path = "/#{params[:route_type]}/#{params[:route_id]}"
    
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
    @direction = RouteDirection.where("route_short_name = '#{params[:route_id]}' AND direction_id = #{params[:direction]}").first
  
    @header_2 += "&rarr; #{@direction.direction_name}".html_safe
    @header_2_path = "/#{params[:route_type]}/#{params[:route_id]}/#{params[:direction]}"
  
    @header_3 = "Choose Starting Station"
  
    if(params[:from_stop] != nil)
      create_headers_from
    end
  end
  
  def create_headers_from
    @from = SimplifiedStop.where("route_id = #{@route.route_id} AND stop_id = #{params[:from_stop]}").first
  
    @header_3 = ("<span>" + @from.stop_name + " &rarr;</span> <span>Choose Ending Station</span>").html_safe
  
    if(params[:to_stop] != nil)
      @to = SimplifiedStop.where("route_id = #{@route.route_id} AND stop_id = #{params[:to_stop]}").first
    
      @header_3 = ("<span>" + @from.stop_name + " &rarr;</span> <span>" + @to.stop_name + "</span>").html_safe
    
      @header_choose = "h4"
    end
  end
end

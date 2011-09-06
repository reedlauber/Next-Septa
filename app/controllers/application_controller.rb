class ApplicationController < ActionController::Base
  protect_from_forgery
  
  ROUTE_TYPES = { "subways" => 1, "trains" => 2, "buses" => 3, "trolleys" => 4 }
  
  def create_headers
    @header_2 = "Choose Route"
    @header_choose = "h2"
    
    if(params[:route_id] != nil)
      @route = Route.where("route_short_name = '#{params[:route_id]}'").first
      
      @header_2 = @route.route_long_name
      @header_2_path = "/#{params[:route_type]}/#{params[:route_id]}"
      
      @header_3 = "Choose Direction"
      
      @header_choose = "h3"
      
      if(params[:direction] != nil)
        @direction = RouteDirection.where("route_short_name = '#{params[:route_id]}' AND direction_id = #{params[:direction]}").first
        
        @header_2 += " - #{@direction.direction_name}"
        @header_2_path = "/#{params[:route_type]}/#{params[:route_id]}/#{params[:direction]}"
        
        @header_3 = "Choose Starting Station"
        
        if(params[:from_stop] != nil)
          @from = SimplifiedStop.where("route_id = #{@route.route_id} AND stop_id = #{params[:from_stop]}").first
          
          @header_3 = @from.stop_name + " -> Choose Ending Station"
          
          if(params[:to_stop] != nil)
            @to = SimplifiedStop.where("route_id = #{@route.route_id} AND stop_id = #{params[:to_stop]}").first
            
            @header_3 = @from.stop_name + " -> " + @to.stop_name
            
            @header_choose = "h4"
          end
        end
      end
    end
  end
end

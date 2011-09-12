class SearchController < ApplicationController
  def index
    if(params[:term] != nil)
        @term = params[:term].upcase
        @routes = Route.find(:all, :conditions => ["upper(route_short_name) = ? OR upper(route_long_name) like ?", @term, @term])
        
        if(@routes.count == 1)
          type = ROUTE_TYPE_IDS[@routes[0].route_type]
          route = @routes[0].route_short_name
          if(type != nil)
            redirect_to "/#{type}/#{route}"
          end
        end
    end
  end
end
class DataController < ApplicationController
  def routes
    @routes = Route.where("").order("lpad(route_short_name, 6, '0')")
    #25,971.32
    render :layout => "data"
  end
  
  def route
    @route_id = params[:route_id].upcase
    @route = Route.find(:all, :conditions => ["route_short_name = ?", @route_id]).first
    
    render :json => @route
  end
end

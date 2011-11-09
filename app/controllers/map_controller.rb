class MapController < ApplicationController
  def index
    create_headers
    
    @back_path = "/#{@route_type}/#{@route_id}/#{@direction_id}/#{@from.stop_id}"
    if(@to != nil)
      @back_path += "/#{@to.stop_id}"
    end
    
    ll = params[:ll].split(',')
    @lat = ll[0]
    @lng = ll[1]
  end
end

class LocationController < ApplicationController
  def index
    url = "http://www3.septa.org/transitview/bus_route_data/" + params[:route_id]
    resp = Resourceful.get(url)
    render :json => resp.body
  end
end

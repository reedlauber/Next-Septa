class DirectionsController < ApplicationController
  def index
    create_headers
    @directions = RouteDirection.where("route_short_name = '" + params[:route_id] + "'")
  end
end

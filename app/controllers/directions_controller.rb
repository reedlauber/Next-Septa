class DirectionsController < ApplicationController
  def index
    create_headers
    @directions = RouteDirection.where("route_short_name = ? OR route_id = ?", @route_id, @route_id).order(:direction_name)
  end
end

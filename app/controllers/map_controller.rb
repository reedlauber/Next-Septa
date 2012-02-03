class MapController < ApplicationController
  def index
    @back_path = "/#{@route_type}/#{@route_id}/#{@direction_id}/#{@from.stop_id}"
    if(@to != nil)
      @back_path += "/#{@to.stop_id}"
    end

    @bus = params[:bus]

    if(params[:trip] != nil)
      trip = Trip.where("trip_id = ?", params[:trip]).first
      if(trip != nil)
        @shape_pts = Shape.where("shape_id = ?", trip.shape_id).order("shape_pt_sequence")
      end
    end
  end
end

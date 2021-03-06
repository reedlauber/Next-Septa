class MapController < ApplicationController
	def index
		@page_title = "Route Map"
		@back_path = "/#{@route_type}/#{@route_id}"

		coordinates = []
		Shape.find_by_route_id(@route_id).each do |point|
			coordinates << [point.shape_pt_lon, point.shape_pt_lat]
		end

		@coords = {
			:type => "LineString",
			:coordinates => coordinates
		}
	end

	def bus
		@page_title = "Bus Location"
		@back_path = "/#{@route_type}/#{@route_id}/#{@direction_id}/#{@from.stop_id}"
		if(@to != nil)
			@back_path += "/#{@to.stop_id}"
		end

		@bus = params[:bus]

		if(params[:trip] != nil)
			trip = Trip.where("trip_id = ?", params[:trip]).first
			if(trip != nil)
				shape_pts = Shape.where("shape_id = ?", trip.shape_id).order("shape_pt_sequence")

				coordinates = []
				shape_pts.each do |point|
					coordinates << [point.shape_pt_lon, point.shape_pt_lat]
				end

				@coords = {
					:type => "LineString",
					:coordinates => coordinates
				}
			end
		end

		render "index"
	end
end

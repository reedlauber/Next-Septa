class ApplicationController < ActionController::Base
	protect_from_forgery
	before_filter :read_request_filter

	ROUTE_TYPES = { "subways" => 1, "trains" => 2, "buses" => 3, "trolleys" => 0 }
	ROUTE_TYPE_IDS = { 1 => "subways", 2 => "trains", 3 => "buses", 0 => "trolleys" }

	def create_headers
	end

	private

	def check_cookies
		@last_stop = cookies[:last_stop]
	end

	def read_request_filter
		check_cookies
		read_params
	end

	def read_params
		@title = "NEXT&rarr;Septa | Next Stop Times for SEPTA Buses, Subways and Tolleys".html_safe

		@route_type = params[:route_type]

		if(@route_type != nil)
			@back_path = "/"

			if(params[:route_id] != nil)
				read_params_route
			end
		end
	end

	def read_params_route
		@route_id = params[:route_id].upcase
		@route = Route.where("route_id = ? OR route_short_name = ?", @route_id, @route_id).first

		if(@route != nil)
			@title = "#{@route.route_short_name} | NEXT&rarr;Septa".html_safe

			@back_path += @route_type

			if(params[:direction] != nil)
				read_params_direction
			end

			get_route_shape
		else
			render "notfound"
		end
	end

	def read_params_direction
		@direction_id = params[:direction]
		@direction = RouteDirection.where("(route_id = ? OR route_short_name = ?) AND direction_id = ?", @route_id, @route_id, @direction_id).first

		if(@direction != nil)
			@back_path += "/#{@route_id}"

			if(params[:from_stop] != nil)
				read_params_stops
			end
		else
			render "notfound"
		end
	end

	def read_params_stops
		@from = SimplifiedStop.where("route_id = ? AND stop_id =? AND direction_id = ?", @route.route_id, params[:from_stop], @direction.direction_id).first

		if(@from != nil)
			@back_path += "/#{@direction_id}"

			if(params[:to_stop] != nil)
				@to = SimplifiedStop.find(:all, :conditions => ["route_id = ? AND stop_id = ?", @route.route_id, params[:to_stop]]).first

				if(@to != nil)
					@back_path += "/#{@from.stop_id}"
				end
			end
		end
	end

	def get_route_shape
		coordinates = []
		Shape.find_by_route_id(@route_id).each do |point|
			coordinates << [point.shape_pt_lon, point.shape_pt_lat]
		end

		@coords = {
			:type => "LineString",
			:coordinates => coordinates
		}
	end
end

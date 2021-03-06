class StopsController < ApplicationController
	ROUTE_TYPES = { "subways" => 1, "trains" => 2, "buses" => 3, "trolleys" => 0 }
	SERVICE_IDS_BUS = ["7", "1", "1", "1", "1", "1", "5"]
	SERVICE_IDS_RAIL = ["S3", "S1", "S1", "S1", "S1", "S1", "S2"]
	Time::DATE_FORMATS[:display_time] = "%l:%M %P"
	Time::DATE_FORMATS[:compare_time] = "%H:%M:%S"
	Time::DATE_FORMATS[:mins] = "%M:00"
	Time::DATE_FORMATS[:display_iso_time] = "%FT%H:%M:%S-" + (Time.now.isdst ? "04" : "05") + ":00"

	def index
		now = Time.now - (60 * 5)
		c_time = now.to_formatted_s(:compare_time)

		# if it's really "after midnight", not "tomorrow", convert to 25:10:00 format for comparison
		if (now.hour < 5)
			c_time = (now.hour.to_i + 24).to_s + ":" + now.to_formatted_s(:mins)
		end

		# handles "backwards" paging
		# if a negative offset is detected, we reverse the time comparison, reverse the sort order, and then reverse the results
		offset = 0
		sort_dir = "ASC"
		compare_dir = ">"
		if(params[:offset] != nil)
			offset = params[:offset].to_i
			if(offset < 0)
				offset += 5 # this is because an offset of -5 actually means reverse order and start from 0
				sort_dir = "DESC"
				compare_dir = "<"
			end
		end

		stop_times = StopTime.select("DISTINCT stop_times.*, t.block_id, tv.stop_count, tv.first_stop_sequence, tv.last_stop_sequence")
									.joins("JOIN trips t ON stop_times.trip_id = t.trip_id")
									.joins("LEFT OUTER JOIN trip_variants tv ON t.trip_variant_id = tv.id")
									.where("t.route_id = '#{@route.route_id}' AND stop_id = #{@from.stop_id} AND t.direction_id = #{@direction_id} AND service_id = '#{service_id}' AND departure_time #{compare_dir} '#{c_time}'")
									.order("departure_time #{sort_dir}")
									.limit(5)
									.offset(offset.abs)
		@stop_times = StopTime.convert_list(stop_times, @to)

		if(sort_dir == "DESC")
			@stop_times.reverse!
		end

		respond_to do |format|
			format.html  { cookies[:last_stop] = "/#{@route_type}/#{@route_id}/#{@direction_id}/#{@from.stop_id}" } # index.html.erb
			format.json  { render :json => @stop_times }
		end
	end

	def from
		if(@direction != nil)
			@stops = SimplifiedStop.where("route_id = ? and direction_id = ?", @route.route_id, @direction_id).order("stop_sequence")

			render "choose"
		end
	end

	def to
		@choose_arrival = true

		if(@direction != nil)
			@stops = SimplifiedStop.where("route_id = ? AND direction_id = ? AND stop_sequence > ?", @route.route_id, @direction_id, @from.stop_sequence).order("stop_sequence")

			render "choose"
		end
	end

	private

	def service_id
		wday = Time.now.wday
		if (Time.now.hour < 5)
			wday = (Time.now + (60 * 60 * 24) - (60 * 5)).wday
		end
		@route.is_rail? ? SERVICE_IDS_RAIL[Time.now.wday] : SERVICE_IDS_BUS[Time.now.wday]
	end
end
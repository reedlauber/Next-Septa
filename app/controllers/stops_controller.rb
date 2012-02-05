class StopsController < ApplicationController
  ROUTE_TYPES = { "subways" => 1, "trains" => 2, "buses" => 3, "trolleys" => 0 }
  SERVICE_IDS = ["7", "1", "1", "1", "1", "1", "5"]
  Time::DATE_FORMATS[:display_time] = "%l:%M %P"
  Time::DATE_FORMATS[:compare_time] = "%H:%M:%S"
  Time::DATE_FORMATS[:display_iso_time] = "%FT%H:%M:%S-" + (Time.now.isdst ? "04" : "05") + ":00"
  
  def index
    service_id = SERVICE_IDS[Time.zone.now.wday]
    
    c_time = (Time.now - (60 * 5)).to_formatted_s(:compare_time)

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
    
    stop_times = StopTime.select("DISTINCT stop_times.*, t.block_id")
                    .joins("JOIN trips t ON stop_times.trip_id = t.trip_id")
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
      @stops = SimplifiedStop.where("route_id = #{@route.route_id} and direction_id = #{@direction_id}").order("stop_sequence")
    
      render "choose"
    end
  end
  
  def to
    @choose_arrival = true
    
    if(@direction != nil)
      @stops = SimplifiedStop.where("route_id = #{@route.route_id} AND direction_id = #{@direction_id} AND stop_sequence > #{@from.stop_sequence}").order("stop_sequence")
    
      render "choose"
    end
  end
end
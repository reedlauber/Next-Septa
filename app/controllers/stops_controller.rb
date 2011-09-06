class StopsController < ApplicationController
  ROUTE_TYPES = { "subways" => 1, "trains" => 2, "buses" => 3, "trolleys" => 4 }
  #SERVICE_IDS = ["S3", "S1", "S1", "S1", "S1", "S1", "S2"]
  SERVICE_IDS = ["7", "1", "1", "1", "1", "1", "5"]
  Time::DATE_FORMATS[:display_time] = "%l:%M %P"
  Time::DATE_FORMATS[:compare_time] = "%H:%M:%S"
  
  def index
    create_headers
    
    service_id = SERVICE_IDS[Time.zone.now.wday]
    
    c_time = Time.now.to_formatted_s(:compare_time)
    
    stop_times = StopTime.select("DISTINCT stop_times.*")
                    .joins("JOIN trips ON stop_times.trip_id = trips.trip_id")
                    .where("trips.route_id = '#{@route.route_id}' AND stop_id = #{@from.stop_id} AND trips.direction_id = #{@direction.direction_id} AND service_id = '#{service_id}' AND departure_time > '#{c_time}'")
                    .order("departure_time")
                    .limit(5)
    @stop_times = StopTime.convert_list(stop_times, @to)
  end
  
  def from
    create_headers
    
    @path = "/#{params[:route_type]}/#{params[:route_id]}/#{params[:direction]}"
    
    @stops = SimplifiedStop.where("route_id = #{@route.route_id} and direction_id = #{params[:direction]}").order("stop_sequence")
    
    render "choose"
  end
  
  def to
    create_headers
    
    @path = "/#{params[:route_type]}/#{params[:route_id]}/#{params[:direction]}/#{params[:from_stop]}"
    
    @stops = SimplifiedStop.where("route_id = #{@route.route_id} AND direction_id = #{params[:direction]} AND stop_sequence > #{@from.stop_sequence}").order("stop_sequence")
    
    render "choose"
  end
end

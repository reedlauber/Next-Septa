class SimplifiedStop < ActiveRecord::Base
  def self.generate_stops
    columns = [:route_id, :route_direction_id, :direction_id, :stop_id, :stop_sequence, :stop_name, :stop_lat, :stop_lon]
    stops = []

    RouteDirection.all.each do |dir|
      Stop.find_by_sql("SELECT DISTINCT s.stop_id, s.stop_name, st.stop_sequence, s.stop_lat, s.stop_lon " + 
        "FROM stops s " + 
        "JOIN stop_times st ON s.stop_id = st.stop_id " + 
        "JOIN trips t ON st.trip_id = t.trip_id " + 
        "JOIN routes r ON r.route_id = '#{dir.route_id}' " + 
        "WHERE t.route_id = '#{dir.route_id}' " + 
        "AND t.direction_id = #{dir.direction_id} " + 
        "ORDER BY st.stop_sequence").each do |stop|
          if(stop.stop_name != nil && stop.stop_name != "")
            stops << [dir.route_id, dir.id, dir.direction_id, stop.stop_id, stop.stop_sequence, stop.stop_name, stop.stop_lat, stop.stop_lon]
          end
      end
    end

    SimplifiedStop.import columns, stops
  end
end

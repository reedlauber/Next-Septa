class RouteDirection < ActiveRecord::Base
  def self.get_last_stop_by_direction(route, direction)
    Stop.find_by_sql("SELECT s.stop_id, s.stop_name, st.stop_sequence " + 
            "FROM routes r " + 
            "JOIN trips t ON t.route_id = r.route_id " + 
            "LEFT OUTER JOIN stop_times st ON t.trip_id = st.trip_id " + 
            "LEFT OUTER JOIN stops s ON st.stop_id = s.stop_id " + 
            "WHERE r.route_id = '#{route.route_id}' AND t.direction_id = #{direction} " + 
            "AND st.id IS NOT NULL AND s.id IS NOT NULL " + 
            "ORDER BY st.stop_sequence DESC " + 
            "LIMIT 1").first
  end
  
  def self.generate_directions
    Route.all.each do |route|
      puts "Route #{route.route_short_name}"
      [0, 1].each do |i|
        last_stop = RouteDirection.get_last_stop_by_direction route, i

        direction = RouteDirection.new
        direction.route_id = route.route_id
        direction.route_short_name = route.route_short_name
        direction.direction_id = i
        direction.direction_name = last_stop == nil ? i.to_s : last_stop.stop_name
        direction.save
      end
    end
  end
end
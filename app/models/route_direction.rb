class RouteDirection < ActiveRecord::Base
  @@dir_names = {
    :NorthSouth => ["Southbound", "Northbound"],
    :EastWest => ["Westbound", "Eastbound"]
  }

  def self.get_stop_by_direction(first, route, direction)
    sort_dir = first ? "" : "DESC"
    Stop.find_by_sql("SELECT s.stop_id, s.stop_name, st.stop_sequence, s.stop_lat, s.stop_lon " +
            "FROM routes r " +
            "JOIN trips t ON t.route_id = r.route_id " +
            "LEFT OUTER JOIN stop_times st ON t.trip_id = st.trip_id " +
            "LEFT OUTER JOIN stops s ON st.stop_id = s.stop_id " +
            "WHERE r.route_id = '#{route.route_id}' AND t.direction_id = #{direction} " +
            "AND st.id IS NOT NULL AND s.id IS NOT NULL " +
            "ORDER BY st.stop_sequence #{sort_dir} " +
            "LIMIT 1").first
  end

  def self.get_direction_name(route, first_stop, last_stop, direction)
    direction_name = direction.to_s
    if route.is_rail?
      direction_name = direction == 0 ? 'Inbound' : 'Outbound'
    elsif (first_stop != nil && last_stop != nil)
      delta_x = (first_stop.stop_lon - last_stop.stop_lon).abs
      delta_y = (first_stop.stop_lat - last_stop.stop_lat).abs

      direction = 0
      if(delta_x > delta_y)
        if(last_stop.stop_lon > first_stop.stop_lon)
          direction = 1
        end
        direction_name = @@dir_names[:EastWest][direction]
      else
        if(last_stop.stop_lat > first_stop.stop_lat)
          direction = 1
        end
        direction_name = @@dir_names[:NorthSouth][direction]
      end
    end
    direction_name
  end

  def self.generate_directions
    columns = [:route_id, :route_short_name, :direction_id, :direction_name, :direction_long_name]

    directions = []

    Route.all.each do |route|
      puts "Route #{route.route_short_name}"
      [0, 1].each do |i|
        first_stop = RouteDirection.get_stop_by_direction(true, route, i)
        last_stop = RouteDirection.get_stop_by_direction(false, route, i)
        direction_name = get_direction_name(route, first_stop, last_stop, i)
        direction_long_name = last_stop == nil ? nil : last_stop.stop_name
        directions << [route.route_id, route.route_short_name, i, direction_name, direction_long_name]
      end
    end

    RouteDirection.import columns, directions
  end
end
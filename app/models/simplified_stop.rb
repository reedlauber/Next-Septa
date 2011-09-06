class SimplifiedStop < ActiveRecord::Base
  has_one :stop
  
  def self.generate_stops
    SimplifiedStop.destroy_all
    
    RouteDirection.all.each do |dir|
      Stop.find_by_sql("SELECT DISTINCT s.stop_id, s.stop_name, st.stop_sequence " + 
        "FROM stops s " + 
        "JOIN stop_times st ON s.stop_id = st.stop_id " + 
        "JOIN trips t ON st.trip_id = t.trip_id " + 
        "JOIN routes r ON r.route_id = '#{dir.route_id}' " + 
        "WHERE t.route_id = '#{dir.route_id}' " + 
        "AND t.direction_id = #{dir.direction_id} " + 
        "ORDER BY st.stop_sequence").each do |stop|
          
          if(stop.stop_name != nil && stop.stop_name != "")
            puts "#{dir.route_short_name} - #{dir.direction_id} - #{stop.stop_name} (#{stop.stop_id} > #{stop.stop_sequence})"
            simplified_stop = self.new
            simplified_stop.route_id = dir.route_id
            simplified_stop.route_direction_id = dir.id
            simplified_stop.direction_id = dir.direction_id
            simplified_stop.stop_id = stop.stop_id
            simplified_stop.stop_sequence = stop.stop_sequence
            simplified_stop.stop_name = stop.stop_name
            
            simplified_stop.save
          end
      end
    end
  end
end

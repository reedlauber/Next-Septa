class Route < ActiveRecord::Base
  def get_last_stop_by_direction!(direction)
    Stop.find_by_sql("SELECT s.stop_id, s.stop_name, st.stop_sequence " + 
            "FROM routes r " + 
            "JOIN trips t ON t.route_id = r.route_id " + 
            "JOIN stop_times st ON t.trip_id = st.trip_id " + 
            "JOIN stops s ON st.stop_id = s.stop_id " + 
            "WHERE r.route_id = '#{self.route_id}' AND t.direction_id = #{direction} " + 
            "ORDER BY st.stop_sequence DESC " + 
            "LIMIT 1").first
  end

  def add_directions!
    dir_1_last_stop = self.get_last_stop_by_direction! 0
    dir_2_last_stop = self.get_last_stop_by_direction! 1
    
    direction0 = RouteDirection.new
    direction0.route_id = self.route_id
    direction0.route_short_name = self.route_short_name
    direction0.direction_id = 0
    direction0.direction_name = dir_1_last_stop == nil ? "0" : dir_1_last_stop.stop_name
    direction0.save
    
    direction1 = RouteDirection.new
    direction1.route_id = self.route_id
    direction1.route_short_name = self.route_short_name
    direction1.direction_id = 1
    direction1.direction_name = dir_2_last_stop == nil ? "0" : dir_2_last_stop.stop_name
    direction1.save
  end
end
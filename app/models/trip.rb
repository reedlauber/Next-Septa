class Trip < ActiveRecord::Base
	def self.find_longest_trip(route_id, direction_id)
		self.find_by_sql([@@longest_trip_sql, direction_id, route_id]).first
	end

	private

	@@longest_trip_sql = "SELECT t.id, t.route_id, t.trip_id, t.shape_id, count(st.*) stop_count " +
							"FROM trips t " +
							"JOIN stop_times st ON t.trip_id = st.trip_id " +
							"WHERE t.direction_id = ? " +
								"AND t.route_id = ? " +
							"GROUP BY t.id, t.route_id, t.trip_id, t.shape_id " +
							"ORDER BY stop_count DESC " +
							"LIMIT 1"
end

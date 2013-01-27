class SimplifiedStop < ActiveRecord::Base
	@@columns = [:route_id, :route_direction_id, :direction_id, :stop_id, :stop_sequence, :stop_name, :stop_lat, :stop_lon]

	def self.generate_stops
		self.generate_bus_stops
		self.generate_rail_stops
	end

	private

	@@distinct_stops_bus_sql = "SELECT DISTINCT s.stop_id, s.stop_name, st.stop_sequence, s.stop_lat, s.stop_lon " +
									"FROM stops s " +
									"JOIN stop_times st ON s.stop_id = st.stop_id " +
									"JOIN trips t ON st.trip_id = t.trip_id " +
									"JOIN routes r ON r.route_id = ? " +
									"WHERE t.route_id = ? " +
									"AND t.direction_id = ? " +
									"ORDER BY st.stop_sequence"

	@@distinct_stops_rail_sql = "SELECT s.*, st.stop_sequence " +
									"FROM stop_times st " +
									"JOIN stops s ON st.stop_id = s.stop_id " +
									"WHERE st.trip_id = ? " +
									"ORDER BY st.stop_sequence"

	def self.generate_bus_stops
		stops = []

		RouteDirection.joins("JOIN routes ON routes.route_id = route_directions.route_id").where("routes.route_type <> ?", 2).each do |dir|
			Stop.find_by_sql([@@distinct_stops_bus_sql, dir.route_id, dir.route_id, dir.direction_id]).each do |stop|
					if(stop.stop_name != nil && stop.stop_name != "")
						stops << [dir.route_id, dir.id, dir.direction_id, stop.stop_id, stop.stop_sequence, stop.stop_name, stop.stop_lat, stop.stop_lon]
					end
			end
		end

		SimplifiedStop.import @@columns, stops
	end

	def self.generate_rail_stops
		stops = []

		RouteDirection.joins("JOIN routes ON routes.route_id = route_directions.route_id").where("routes.route_type = ?", 2).each do |dir|
			longest_trip = Trip.find_longest_trip(dir.route_id, dir.direction_id)

			if longest_trip != nil
				Stop.find_by_sql([@@distinct_stops_rail_sql, longest_trip.trip_id]).each do |stop|
						if(stop.stop_name != nil && stop.stop_name != "")
							stops << [dir.route_id, dir.id, dir.direction_id, stop.stop_id, stop.stop_sequence, stop.stop_name, stop.stop_lat, stop.stop_lon]
						end
				end
			end
		end

		SimplifiedStop.import @@columns, stops
	end
end
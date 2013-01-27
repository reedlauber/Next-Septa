class Shape < ActiveRecord::Base
	def self.assign_route_shapes(route_id)
		longest_trip = Trip.find_longest_trip(route_id, 0)
		if longest_trip != nil
			puts "Setting Shape for Route '#{route_id}' with Trip/Shape: '#{longest_trip.trip_id}'/'#{longest_trip.shape_id}'"

			Shape.update_all ['route_id = ?', route_id], ['shape_id = ?', longest_trip.shape_id]
		end
	end
end

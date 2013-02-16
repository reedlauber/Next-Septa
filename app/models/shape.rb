class Shape < ActiveRecord::Base
	def self.find_by_route_id(route_id)
		self.where("route_id = ?", route_id).order("shape_pt_sequence")
	end

	def self.assign_route_shapes(route_id, route_pub_id)
		longest_trip = Trip.find_longest_trip(route_id, 0)
		if longest_trip != nil
			puts "Setting Shape for Route '#{route_pub_id}' with Trip/Shape: '#{longest_trip.trip_id}'/'#{longest_trip.shape_id}'"

			Shape.update_all ['route_id = ?', route_pub_id], ['shape_id = ?', longest_trip.shape_id]
		end
	end
end

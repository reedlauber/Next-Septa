class Route < ActiveRecord::Base
	def is_rail?
		route_type == 2
	end

	def has_realtime?
		route_type != 1
	end

	def slug
		(is_rail? ? route_id : route_short_name).downcase
	end

	def self.assign_route_shapes
		Route.all.each do |route|
			route_id = route.is_rail? ? route.route_id : route.route_short_name
			Shape.assign_route_shapes(route.route_id, route_id)
		end
	end
end
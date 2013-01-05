class Route < ActiveRecord::Base
	def is_rail?
		route_type == 2
	end

	def slug
		(is_rail? ? route_id : route_short_name).downcase
	end
end
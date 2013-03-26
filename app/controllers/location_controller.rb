class LocationController < ApplicationController
	SERVICE_IDS_BUS = ["7", "1", "1", "1", "1", "1", "5"]
	SERVICE_IDS_RAIL = ["S3", "S1", "S1", "S1", "S1", "S1", "S2"]

	def index
		route = Route.where("route_id = ? OR route_short_name = ?", params[:route_id], params[:route_id]).first

		resp = { :vehicles => [] }
		if (route != nil)
			if (route.is_rail?)
				url = "http://www3.septa.org/hackathon/TrainView/"
				resp = Resourceful.get(url)
				resp = normalize_rail(resp, route)
			elsif (!route.is_subway?)
				url = "http://www3.septa.org/transitview/bus_route_data/" + params[:route_id]
				resp = Resourceful.get(url)
				resp = normalize_buses(resp, route)
			end
		end
		render :json => resp
	end

	private

	def bus_direction(bus)
		direction = ""
		if(bus['Direction'] == 'NorthBound' || bus['Direction'] == 'EastBound')
			direction = "1"
		elsif(bus['Direction'] == 'SouthBound' || bus['Direction'] == 'WestBound')
			direction = "0"
		end
		direction
	end

	def normalize_buses(resp, route)
		buses = []
		if (resp != nil && resp.body != nil)
			resp_obj = ActiveSupport::JSON.decode(resp.body)
			if (resp_obj != nil)
				resp_buses = resp_obj['bus']
				resp_buses.each do |bus|
					buses << {
						:mode => 'bus',
						:lat => bus['lat'],
						:lng => bus['lng'],
						:vehicle_id => bus['VehicleID'],
						:offset => bus['Offset'],
						:block_id => bus['BlockID'],
						:destination => bus['destination'],
						:late => nil,
						:route_id => route.route_short_name,
						:direction => bus_direction(bus)
					}
				end
			end
		end
		{ :mode => 'bus', :vehicles => buses }
	end

	def normalize_rail(resp, route)
		trains = []
		if (resp != nil && resp.body != nil)
			resp_obj = ActiveSupport::JSON.decode(resp.body)
			if (resp_obj != nil)
				resp_obj.each do |train|
					trip = Trip.where('block_id = ? AND service_id = ? AND route_id = ?', train['trainno'], SERVICE_IDS_RAIL[Time.now.wday], route.route_id).first
					route_id = trip == nil ? '' : trip.route_id

					trains << {
						:mode => 'rail',
						:lat => train['lat'],
						:lng => train['lon'],
						:vehicle_id => train['trainno'],
						:offset => 0,
						:block_id => 0,
						:destination => train['dest'],
						:late => train['late'],
						:route_id => route_id
					}
				end
			end
		end
		{ :mode => 'rail', :vehicles => trains }
	end
end

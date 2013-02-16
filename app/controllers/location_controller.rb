class LocationController < ApplicationController
	def index
		route = Route.where("route_id = ? OR route_short_name = ?", params[:route_id], params[:route_id]).first

		resp = "{}"
		if (route != nil)
			if (route.is_rail?)
				url = "http://www3.septa.org/hackathon/TrainView/"
				resp = Resourceful.get(url)
				resp = normalize_rail resp
			else
				url = "http://www3.septa.org/transitview/bus_route_data/" + params[:route_id]
				resp = Resourceful.get(url)
				resp = normalize_buses resp
			end
		end
		render :json => resp
	end

	private

	def normalize_buses(resp)
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
						:late => nil
					}
				end
			end
		end
		{ :mode => 'bus', :vehicles => buses }
	end

	def normalize_rail(resp)
		trains = []
		if (resp != nil && resp.body != nil)
			resp_obj = ActiveSupport::JSON.decode(resp.body)
			if (resp_obj != nil)
				resp_obj.each do |train|
					route = Trip.where('block_id = ?', train['trainno']).first
					route_id = route == nil ? '' : route.route_id

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

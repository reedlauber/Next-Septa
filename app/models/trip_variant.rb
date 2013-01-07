class TripVariant < ActiveRecord::Base
	@@variant_names = ("A".."Z").to_a

	def self.generate_variants
		variant_existing_lookup = Hash.new

		Trip.all.each do |trip|
			stop_info = TripVariant.trip_stop_info(trip)

			if(stop_info != nil)
				variant = TripVariant.where("route_id = ? AND direction_id = ? AND first_stop_sequence = ? AND last_stop_sequence = ?",
					trip.route_id, trip.direction_id, stop_info.min_sequence, stop_info.max_sequence).first

				if(variant == nil)
					variant = TripVariant.new
					variant.route_id = trip.route_id
					variant.direction_id = trip.direction_id
					variant.trip_headsign = trip.trip_headsign
					variant.stop_count = SimplifiedStop.where("route_id = ? AND direction_id = ?", trip.route_id, trip.direction_id).count
					variant.first_stop_sequence = stop_info.min_sequence
					variant.last_stop_sequence = stop_info.max_sequence
					variant.variant_name = TripVariant.variant_name(trip, stop_info)

					variant.save
				end

				trip.trip_variant_id = variant.id
				trip.save
			end
		end
		variant_existing_lookup = nil
	end

	private
	def self.trip_stop_info(trip)
		StopTime.find_by_sql("SELECT MIN(stop_sequence) as min_sequence, MAX(stop_sequence) as max_sequence " +
			"FROM stop_times " +
			"WHERE trip_id = '#{trip.trip_id}' " +
			"GROUP BY trip_id").first
	end

	def self.variant_name(trip, stop_info)
		count = TripVariant.where("route_id = ? AND direction_id = ?",
			trip.route_id, trip.direction_id).count
		@@variant_names[count]
	end
end

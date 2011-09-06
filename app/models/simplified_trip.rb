class SimplifiedTrip < ActiveRecord::Base
  MERGES = { "BSS" => [
              { "Name" => "To Fern Rock", "Merge" => ["AT&T Station", "Walnut-Locust Station", "8th St Station"] },
              { "Name" => "To South Philly", "Merge" => ["Fern Rock Trans Ctr", "Olney Trans Ctr"]}
            ] }

  def create_trips
    gtfs_trips = Trip.find_by_sql("")
  end
end
class DataController < ApplicationController
  Time::DATE_FORMATS[:display_time] = "%l:%M %P"

  def routes
    @routes = Route.where("").order("lpad(route_short_name, 6, '0')")
    render :layout => "data"
  end
  
  def directions
    @route_id = params[:route_id].upcase
    @route = Route.where("route_short_name = ?", @route_id).first
    @directions = RouteDirection.where("route_id = ?", @route.route_id).order("direction_id")
    generate_breadcrumbs
    render :layout => "data"
  end

  def trips
    @route_id = params[:route_id].upcase
    @route = Route.where("route_short_name = ?", @route_id).first
    @direction_id = params[:direction_id]
    @direction = RouteDirection.where("route_id = ? AND direction_id = ?", @route.route_id, @direction_id).first
    @weekdays = []
    @saturdays = []
    @sundays = []
    Trip.where("route_id = ? AND direction_id = ?", @route.route_id, @direction_id).order("service_id, trip_id").each do |t|
      first_stop = StopTime.where("trip_id = ?", t.trip_id).order("stop_sequence").first
      start_time = StopTime.parse_time(first_stop.departure_time)
      trip = {
        :trip_id => t.trip_id, 
        :trip_headsign => t.trip_headsign, 
        :start_time => start_time,
        :service_label => trip_service_label(t)
      }
      if(t.service_id == "7")
        @sundays << trip
      elsif(t.service_id == "5")
        @saturdays << trip
      else
        @weekdays << trip
      end
    end

    generate_breadcrumbs

    render :layout => "data"
  end
  
  def stops
    @route_id = params[:route_id].upcase
    @route = Route.where("route_short_name = ?", @route_id).first
    @direction_id = params[:direction_id]
    @direction = RouteDirection.where("route_id = ? AND direction_id = ?", @route.route_id, @direction_id).first
    @trip_id = params[:trip_id]
    @trip = Trip.where("trip_id = ?", @trip_id).first
    @stops = []
    StopTime.where("trip_id = ?", @trip_id).order("stop_sequence").each do |st|
      stop = SimplifiedStop.where("stop_id = ?", st.stop_id).first
      arrival_time = StopTime.parse_time(st.arrival_time)
      @stops << {
        :stop_id => st.stop_id,
        :stop_sequence => st.stop_sequence,
        :stop_name => stop.stop_name,
        :arrival_time => arrival_time
      }
    end
    generate_breadcrumbs
    render :layout => "data"
  end
  
  def times
    @route_id = params[:route_id].upcase
    @route = Route.where("route_short_name = ?", @route_id).first
    @direction = RouteDirection.where("route_id = ? AND direction_id = ?", @route.route_id, params[:direction_id]).first
    @stop = SimplifiedStop.where("route_id = ? and direction_id = ? and stop_id = ?", @route.route_id, @direction.direction_id, params[:stop_id])
    @times = StopTime.where("")
    render :layout => "data"
  end

  private
  def trip_service_label (trip)
    label = "Weekday"
    if(trip.service_id == "7")
      label = "Sunday"
    elsif(trip.service_id == "5")
      label = "Saturday"
    end
    label
  end

  def generate_breadcrumbs
    @bc = [{ :text => "Data", :url => "/data" }]
    if(@route != nil)
      @bc << { :text => @route.route_short_name, :url => "/data/#{@route.route_short_name}" }

      if(@direction)
        @bc << { :text => @direction.direction_name, :url => "/data/#{@route.route_short_name}/#{@direction_id}" }

        if(@trip)
          @bc << { :text => @trip.trip_headsign, :url => "/data/#{@route.route_short_name}/#{@direction_id}/#{@trip.trip_id}" }
        end
      end
    end
  end
end

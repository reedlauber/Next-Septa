class RoutesController < ApplicationController
  def index
    create_headers
    @title = (params[:route_type].capitalize + " | NEXT&rarr;Septa").html_safe
    type = ROUTE_TYPES[params[:route_type]]
    @routes = Route.where("route_type = " + type.to_s).order("lpad(route_short_name, 6, '0')")
    @first_letter = ''
  end
end
class MapController < ApplicationController
  def index
    create_headers
    
    ll = params[:ll].split(',')
    @lat = ll[0]
    @lng = ll[1]
  end
end

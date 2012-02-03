(function(NXS) {
	NXS.Map = function(options) {
		var _self = {},
			_options = $.extend({
				id: 'map',
                baseLayers: {
                    gphy: { label: 'Physical', layer: new OpenLayers.Layer.Google("Google Physical", { type: google.maps.MapTypeId.TERRAIN, numZoomLevels: 20 }) },
                    gmap: { label: 'Streets', layer: new OpenLayers.Layer.Google("Google Streets", { type: google.maps.MapTypeId.ROADMAP, numZoomLevels: 20 }) },
                    gsat: { label: 'Satellite', layer: new OpenLayers.Layer.Google("Google Satellite", { type: google.maps.MapTypeId.SATELLITE, numZoomLevels: 22 }) },
                    ghyb: { label: 'Hybrid', layer: new OpenLayers.Layer.Google("Google Hybrid", { type: google.maps.MapTypeId.HYBRID, numZoomLevels: 20 }) }
                },
                zoom: 16,
                center: { lat:39.9523350, lng:-75.163789 } // Philadelphia
			}, options),
			_manager,
			_zoom = _options.zoom;

		var _map, _proj, _mapProj, 
			_vectorLayer, _markerLayer, _markerShadowLayer,
			_markerPath = '/images/markers/bus.png';

		var $map;

		function _addUserLocation(userLatLng) {	
			var bounds = new google.maps.LatLngBounds();
			bounds.extend(latlng);
			bounds.extend(userLatLng);
			map.fitBounds(bounds);

			var marker = new google.maps.Marker({
				position: userLatLng,
				map: map, 
				title: 'Your Location'
			});
		}
		
		function _updateBusLocation(bus) {
			var label = '',
				offset = parseInt(bus.Offset, 10);
			if(!isNaN(offset)) {
				label = offset + ' min' + (offset == 1 ? '' : 's') + ' ago';
			}

			_markerLayer.clearMarkers();
            _setCenter(bus.lng, bus.lat);
            _addMarker(bus.lng, bus.lat, label);
		}

		function _getBusLocation(routeId, vehicleId) {
			NXS.Data.get('/locations/' + routeId, function(resp) {
				var buses = {};
				if(resp.bus) {
					$.each(resp.bus, function(i, bus) {
						buses[bus.VehicleID] = bus;
					});
				}
				if(vehicleId in buses) {
					_updateBusLocation(buses[vehicleId]);
					setTimeout(function() {
						_getBusLocation(routeId, vehicleId);
					}, 60000); // 1 min
				} else {
					// SHOW WARNING THAT DATA COULDN'T BE FOUND
				}
			});
		}

		function _addMarkerInfo(marker, info) {
			var $icon = $(marker.icon.imageDiv);
			if($icon.length) {
				var $info = $('<div class="ns-map-markerinfo s-corner-all-4"></div>').html(info).appendTo($icon);
			}
		}

        function _addMarker(x, y, info) {
            var size = new OpenLayers.Size(32, 37),
                offset = new OpenLayers.Pixel(-(size.w / 2), -size.h),
                icon = new OpenLayers.Icon(_markerPath, size, offset),
                point = new OpenLayers.LonLat(x, y).transform(_proj, _map.getProjectionObject()),
                marker = new OpenLayers.Marker(point, icon);

            _markerLayer.addMarker(marker);

            if(info) {
            	_addMarkerInfo(marker, info);
            }
        }

        function _setCenter(lng, lat, zoom) {
        	zoom = zoom || _zoom;
            _map.setCenter(new OpenLayers.LonLat(lng, lat).transform(_proj, _map.getProjectionObject()), zoom);
        }

		function _setupMapControls() {
			var $zoom = $('<div class="ns-map-zoom"></div>').appendTo($map);
			var $zoomIn = $('<a href="javascript:void(0)" data-zoom="in" class="s-shadow-small"></a>').appendTo($zoom);
			var $zoomOut = $('<a href="javascript:void(0)" data-zoom="out" class="s-shadow-small"></a>').appendTo($zoom);

			$('a', $zoom).click(function() {
				var zoomFn = $(this).attr('data-zoom') === 'in' ? 'zoomIn' : 'zoomOut';
				_map[zoomFn]();
			});
		}


        function _setupOverlayLayers() {
        	_vectorLayer = new OpenLayers.Layer.Vector("Vectors", { style: { strokeColor:'#3366DD', strokeWidth:6, strokeOpacity:0.7 } });
            //_markerShadowLayer = new OpenLayers.Layer.Markers("Shadows");
            _markerLayer = new OpenLayers.Layer.Markers("Markers");

            _map.addLayers([_vectorLayer, _markerLayer]);
        }

        function _setupRouteOverlay() {
        	var wkt = $('#' + _options.id + '-shape').html();
        	if(wkt) {
        		var wktReader = new OpenLayers.Format.WKT({
	                'internalProjection': _map.baseLayer.projection,
	                'externalProjection': new OpenLayers.Projection("EPSG:4326")
	            });
        		var feature = wktReader.read(wkt);
        		if(feature) {
	        		_vectorLayer.addFeatures([feature]);
	        	}
        	}
        }

		_self.init = function(manager, state) {
			_manager = manager;

			$map = $('#' + _options.id);
			var routeId = $map.attr('data-route'),
				vehicleId = $map.attr('data-bus');

            _proj = new OpenLayers.Projection("EPSG:4326");

            _map = NXS.Map = new OpenLayers.Map(_options.id + '-inner', {
                sphericalMercator: true,
                units: 'degrees',
                controls: [
					new OpenLayers.Control.Navigation()
				]
            });
            _mapProj = _map.getProjectionObject();

            _map.addLayers([
			    _options.baseLayers.gmap.layer
		    ]);

			$('.olLayerDiv', $map).addClass('ns-shadow-inset');

            _setupMapControls();
            _setupOverlayLayers();
            _setupRouteOverlay();

            _getBusLocation(state.routeId, vehicleId);

            _setCenter(_options.center.lng, _options.center.lat, 13);

			//if(navigator.geolocation) {
			//	navigator.geolocation.getCurrentPosition(function(position) {
			//    	var userLatLng = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
			//    	_addUserLocation(userLatLng);
			//    });
			//}

			return _self;
		};
		
		return _self;
	};
})(NextSepta);
(function(NXS) {
	NXS.Map = function(options) {
		var _self = {},
			_options = $.extend({
				id: 'map',
				zoom: 16,
				center: { lat:39.9523350, lng:-75.163789 } // Philadelphia
			}, options),
			_manager,
			_zoom = _options.zoom;

		var _map,
			_vehicleMarker,
			_vehicle, _user,
			_icons = {
				bus: {
					width: 32,
					height: 37,
					path: '/images/markers/bus.png'
				},
				user: {
					width: 24,
					height: 24,
					path: '/images/gentleface/black/pin_map_icon&24.png'
				}
			};

		var $map;

		var _vehicleLocated = _userLocated = false;
		function _setExtendedLocation() {
			if(_vehicle && _user) {
				var bounds = _map.getBounds();
				if(!_vehicleLocated) {
					bounds.extend([_vehicle.lat, _vehicle.lng]);
					_vehicleLocated = true;
				}
				if(!_userLocated) {
					bounds.extend([_user.lat, _user.lon]);
					_userLocated = true;
				}
				_map.fitBounds(bounds);
			} else if(_vehicle) {
				_vehicleLocated = true;
				_setCenter(_vehicle.lng, _vehicle.lat);
			} else if(_user) {
				_userLocated = true;
				_setCenter(_user.lon, _user.lat);
			}
		}

		function _addUserLocation() {
			_addMarker(_user.lon, _user.lat, null, 'user');
			_setExtendedLocation();
		}

		function _updateBusLocation() {
			var label = '',
				offset = parseInt(_vehicle.Offset, 10);
			if(!isNaN(offset)) {
				label = offset + ' min' + (offset == 1 ? '' : 's') + ' ago';
			}

			if(_user) {
				_addMarker(_user.lon, _user.lat, null, 'user');
			}

			if(_vehicleMarker) {
				var vehicleLatLng = _vehicleMarker.getLatLng();
				if(vehicleLatLng.lat !== _vehicle.lat && vehicleLatLng.lng !== _vehicle.lng) {
					_vehicleLocated = false;
					_updateMarker(_vehicle.lng, _vehicle.lat, _vehicleMarker, label);
				}
			} else {
				_addMarker(_vehicle.lng, _vehicle.lat, label);
			}
			_setExtendedLocation();
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
					_vehicle = buses[vehicleId];
					_vehicle.lat = parseFloat(_vehicle.lat);
					_vehicle.lng = parseFloat(_vehicle.lng);
					_updateBusLocation();
					setTimeout(function() {
						_getBusLocation(routeId, vehicleId);
					}, 60000); // 1 min
				} else {
					// SHOW WARNING THAT DATA COULDN'T BE FOUND
				}
			});
		}

		function _addMarkerInfo(marker, info) {
			marker.unbindPopup();
			marker.bindPopup(info, {
				offset: L.point(57, 10),
				closeButton: false,
				className: 'ns-map-markerinfo s-corner-all-4'
			});
			marker.openPopup();
		}

		function _addMarker(x, y, info, type) {
			var iconInfo = _icons[type || 'bus'],
				icon = L.icon({
					iconUrl: iconInfo.path,
					iconSize: [iconInfo.width, iconInfo.height]
				});

			var marker = L.marker([y, x], {
				icon: icon,
				title: info || ''
			}).addTo(_map);

			if(type !== 'user') {
				_vehicleMarker = marker;
			}

			if(info) {
				_addMarkerInfo(marker, info);
			}
		}

		function _updateMarker(x, y, marker, label) {
			marker.setLatLng([y, x]);

			if(label) {
				_addMarkerInfo(marker, label);
			}
		}

		function _setCenter(lng, lat, zoom) {
			zoom = zoom || _zoom;
			_map.setView([lat, lng], zoom);
		}

		function _setupRouteOverlay() {
			var geoJson = $('#' + _options.id + '-shape').html();
			if(geoJson) {
				geoJson = JSON.parse(geoJson);
				if(geoJson) {
					L.geoJson(geoJson, {

					}).addTo(_map);
				}
			}
		}

		_self.init = function(manager, state) {
			_manager = manager;

			$map = $('#' + _options.id);
			var routeId = $map.attr('data-route'),
				vehicleId = $map.attr('data-bus');

			_map = L.map(_options.id + '-inner')

			L.tileLayer('http://{s}.tile.cloudmade.com/fdb4e543deef4dccbc7d4383c5f3c783/997/256/{z}/{x}/{y}.png', {
				maxZoom: 22
			}).addTo(_map);

			_setupRouteOverlay();

			_getBusLocation(state.routeId, vehicleId);

			_setCenter(_options.center.lng, _options.center.lat, 12);

			if(navigator.geolocation) {
				navigator.geolocation.getCurrentPosition(function(position) {
					_user = { lat:position.coords.latitude, lon:position.coords.longitude };
					_addUserLocation();
				});
			}

			return _self;
		};

		return _self;
	};
})(NextSepta);
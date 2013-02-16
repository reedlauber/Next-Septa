(function(NXS) {
	NXS.Map = function(options) {
		var _self = {},
			_options = $.extend({
				id: 'map',
				zoom: 16,
				centerOn: 'shape',
				center: { lat:39.9523350, lng:-75.163789 } // Philadelphia
			}, options),
			_manager,
			_state,
			_initialized = false;

		var _map,
			_zoom = _options.zoom,
			_vehicleMarker,
			_vehicle, _user,
			_routeLayer,
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

		var _centering = false;
		function _setExtendedLocation() {
			if(_vehicle && _user) {
				var userPoint = L.latLng(_user.lat, _user.lon),
					vehiclePoint = L.latLng(_vehicle.lat, _vehicle.lng),
					bounds = new L.LatLngBounds();

				bounds.extend(userPoint);
				bounds.extend(vehiclePoint);
				// If a vehicle or user was already being centered on, wait a bit of the animation to finish.
				if(_centering) {
					setTimeout(function() {
						_map.fitBounds(bounds);
						_centering = false;
					}, 500);
				} else {
					_map.fitBounds(bounds);
				}
			} else if(_vehicle) {
				_centering = true;
				// Wait a bit to see if a user comes in and we can just do a bounds extend
				setTimeout(function() {
					if(!_user) {
						_setCenter(_vehicle.lng, _vehicle.lat);
					}
				}, 500);
			} else if(_user) {
				_centering = true;
				// Wait a bit to see if a vehicle comes in and we can just do a bounds extend
				setTimeout(function() {
					if(!_vehicle) {
						_setCenter(_user.lon, _user.lat);
					}
				}, 500);
			}
		}

		function _addUserLocation() {
			_addMarker(_user.lon, _user.lat, null, 'user');
			if(_options.centerOn === 'user') {
				_setExtendedLocation();
			}
		}

		function _updateBusLocation() {
			var label = '',
				offset = parseInt(_vehicle.offset, 10);
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

		function _addVehicles(routeId, vehicles) {
			$.each(vehicles, function(i, vehicle) {
				if(vehicle.route_id === routeId) {
					var offset = parseInt(vehicle.offset, 10),
						late = parseInt(vehicle.late, 10),
						label = vehicle.mode === 'rail' ? (late + ' min' + (late === 1 ? '' : 's') + '  late') : (offset + ' min' + (offset == 1 ? '' : 's') + ' ago');
					_addMarker(vehicle.lng, vehicle.lat, label);
				}
			});
		}

		function _getVehicleLocations(vehicleId) {
			var routeId = _state.routeId;
			NXS.Data.get('/locations/' + routeId, function(resp) {
				var vehicles = {};
				if(resp.vehicles) {
					$.each(resp.vehicles, function(i, bus) {
						vehicles[bus.vehicle_id] = bus;
					});
				}
				if(vehicleId) {
					if(vehicleId in vehicles) {
						_vehicle = vehicles[vehicleId];
						_vehicle.lat = parseFloat(_vehicle.lat);
						_vehicle.lng = parseFloat(_vehicle.lng);
						_updateBusLocation();
						setTimeout(function() {
							_getBusLocation(routeId, vehicleId);
						}, 60000); // 1 min
					} else {
						// SHOW WARNING THAT DATA COULDN'T BE FOUND
					}
				} else {
					_addVehicles(routeId, resp.vehicles);
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
				if(geoJson && geoJson.coordinates && geoJson.coordinates.length) {
					_routeLayer = L.geoJson(geoJson, {
						style: function() {
							return {
								color: '#a33',
								opacity: 0.8
							};
						}
					}).addTo(_map);
					if(_options.centerOn === 'shape') {
						_map.fitBounds(_routeLayer.getBounds());
					}
				}
			}
		}

		function _adjustSize() {
			var height = $(window).height() -  $('#header').outerHeight();
			$('#' + _options.id + '-inner').height(height);
		}

		function _initializeMap() {
			var routeId = $map.attr('data-route'),
				vehicleId = $map.attr('data-bus');

			_adjustSize();

			_map = L.map(_options.id + '-inner');

			L.tileLayer('http://{s}.tile.cloudmade.com/fdb4e543deef4dccbc7d4383c5f3c783/86814/256/{z}/{x}/{y}.png?v=1', {
				maxZoom: 22
			}).addTo(_map);

			_setupRouteOverlay();

			_getVehicleLocations(vehicleId);

			if(!_routeLayer || _options.centerOn != 'shape') {
				_setCenter(_options.center.lng, _options.center.lat, 12);
			}

			if(navigator.geolocation) {
				navigator.geolocation.getCurrentPosition(function(position) {
					_user = { lat:position.coords.latitude, lon:position.coords.longitude };
					_addUserLocation();
				});
			}

			_initialized = true;
		}

		_self.init = function(manager, state) {
			_manager = manager;
			_state = state;

			$map = $('#' + _options.id);

			if($map.is(':visible')) {
				_initializeMap();
			}

			return _self;
		};

		return _self;
	};
})(NextSepta);
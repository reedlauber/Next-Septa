(function(NXS) {
	NXS.Stops = function(options) {
		var _self = {},
			_options = {
				id: 'stops',
				target: '#content'
			},
			_manager,
			_state,
			_stops = [],
			_buses = null;

		var _intervals = [{ l:'week', s:604800 }, { l:'day', s:86400 }, { l:'hr', s:3600 }, { l:'min', s:60 }];

		var $list;

		function _getRelTime(diff) {
			if(diff < 0) {
				return '(GONE)';
			} else if(diff < 60) {
				return '(< 1 min)';
			} else {
				var s = '', v = 0;
				$.each(_intervals, function(i, inv) {
					if(diff > inv.s) {
						v = Math.floor(diff / inv.s);
						if(s) {
							s += ' ';
						}
						s += v + ' ' + inv.l + (v == 1 ? '' : 's');
						diff = diff % inv.s;
					}
				});
				return '(' + s + ')';
			}
		}

		function _timer() {
			var now = new Date();
			$.each(_stops, function(i, stop) {
				var diff = (stop.time - now) / 1000;
				stop.el.html(_getRelTime(diff));
			});
			if(_stops.length) {
				setTimeout(function() {
					_timer();
				}, 25000);
			}
		}

		function _updateRealTime() {
			$('.nxs-stoptime').each(function() {
				var blockId = $(this).attr('data-block'),
					tripId = $(this).attr('data-trip');
				if(blockId && blockId in _buses) {
					var bus = _buses[blockId];
					var mapUrl = _manager.getPath('map?bus=' + bus.vehicle_id + '&trip=' + tripId);
					$('.nxs-stoptime-aside', this).addClass('active').find('a').attr('href', mapUrl).attr('title', 'View Vehicle Location');
				} else {
					$('.nxs-stoptime-aside', this).removeClass('active').find('a').attr('href', 'javascript:void(0)').attr('title', 'Couldn\'t Find Location Info');
				}
			});
		}

		function _getRealTimeData(routeId) {
			NXS.Data.get('/locations/' + routeId, function(resp) {
				_buses = {};
				if(resp.vehicles) {
					$.each(resp.vehicles, function(i, bus) {
						_buses[bus.block_id] = bus;
					});
				}
				_updateRealTime();
			});
		}

		function _setupPaging() {
			var offset = 0;

			var cache = {
				"0": {
					$first: $('li:first', $list)
				}
			};

			$('.nxs-stoptimes-pager').click(function() {
				var fwd = $(this).attr('data-dir') === 'fwd';
				var prevKey = offset.toString();
				offset += fwd ? 5 : -5;
				var cacheKey = offset.toString();

				if(cacheKey in cache) {
					$list.scrollTo(cache[cacheKey].$first, 500);
				} else {
					NXS.Data.get(window.location.pathname, function(data) {
						if(data && data.length) {
							var html = NXS.template(NXS.Templates.stopTime, { stop_times:data });
							var $first;
							if(offset < 0) {
								$list.prepend(html);
								$list.scrollTo(cache[prevKey].$first);
							} else {
								$list.append(html);
							}

							if(_state.routeType === 'buses') {
								_updateRealTime();
							}

							$first = $('li[data-trip=' + data[0].trip_id + ']', $list);
							$list.scrollTo($first, 500);
							cache[cacheKey] = { $first:$first };
						} else {
							offset = parseInt(prevKey, 10); // hackalicious
						}
					}, null, { offset:offset });
				}
			});
		}

		_self.init = function(manager, state) {
			_manager = manager;
			_state = state;

			$list = $('#times-list');
			$list.height($list.height());

			_setupPaging();

			$('.nxs-stoptime-left').each(function() {
				var ts = $('time', this).attr('datetime'),
					relText = $('span', this);

				if(ts) {
					var dt = new Date(Date.parse(ts));
					if(dt && !$.isNaN(dt)) {
						_stops.push({ time:dt, el:relText });
					}
				}
			});


			if(_state.routeType === 'buses' && _state.routeId) {
				_getRealTimeData(_state.routeId);
			}

			_timer();

			return _self;
		};

		return _self;
	};
})(NextSepta);
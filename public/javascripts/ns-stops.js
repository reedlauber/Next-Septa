(function(NXS) {
	NXS.Stops = function(options) {
		var _self = {},
			_options = {
				id: 'stops',
				target: '#content'
			},
			_manager,
			_state,
			_stops = [];
		
		var _intervals = [{ l:'week', s:604800 }, { l:'day', s:86400 }, { l:'hr', s:3600 }, { l:'min', s:60 }]
		
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
		
		function _updateRealTime(buses) {
			$('.nxs-stoptime').each(function() {
				var blockId = $(this).attr('data-block');
				if(blockId && blockId in buses) {
					var bus = buses[blockId];
					var mapUrl = _manager.getPath('map?ll=' + bus.lat + ',' + bus.lng);
					$('.nxs-stoptime-aside', this).html('<a href="' + mapUrl + '">map</a>')
				}
			});
		}
		
		function _getRealTimeData(routeId) {
			NXS.Data.get('/locations/' + routeId, function(resp) {
				var buses = {};
				if(resp.bus) {
					$.each(resp.bus, function(i, bus) {
						buses[bus.BlockID] = bus;
					});
				}
				_updateRealTime(buses);
			});
		}
		
		_self.init = function(manager, state) {
			_manager = manager;
			_state = state;
			
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
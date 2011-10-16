var NextSepta = {};

(function(NXS) {
	NXS.Data = (function() {
		var _d = {};
		
		function _ajax(url, type, data, success, error, customParams) {
			if(data && typeof data === 'object') {
				$.each(data, function(p, v) {
					if(v === null) {
						data[p] = undefined;
					}
				});
			}

			function errorFn(resp, status) {
	            // This object gets passed through the custom error function so it can communicate back
	            var errEvt = { message: true, resp: resp };
	            if (error && typeof error === 'function') {
	                error(errEvt);
	            }
	            if (errEvt.message && status !== 'abort') {
	                $(NXS).trigger('message', [resp.message || 'Something bad happened with your request.', { error: true}]);
	            }
			}

	        var ajaxOpts = $.extend({
	            url: url,
	            type: type,
	            data: data,
	            dataType: 'json',
	            success: function (resp) {
	                if (resp && resp.success === false) {
	                    errorFn(resp);
	                } else if (success && typeof success === 'function') {
	                    success(resp);
	                }
	            },
	            error: errorFn
	        }, customParams);

	        return $.ajax(ajaxOpts);
		}
		
		_d.get = function(url, success, error, params, customParams) {
			_ajax(url, 'GET', params, success, error, customParams);
		};
		
		return _d;
	})();
	
	NXS.Manager = function(options) {
		var _self = {},
			_options = $.extend({
				id: 'container',
				components: {}
			}, options),
			_state = {};
		
		function _resize() {
			var $r = $('.nxs-resize');
			if($r.length) {
				var maxHeight = $(window).height() - $r.offset().top - $('#footer').outerHeight();
				$r.css('maxHeight', maxHeight);
			}
		}
		
		function _setupHistory() {
			if(window.history && window.history.pushState) {
				$('.nxs-hist-link').click(function() {
					var href = $(this).attr('href');
					window.history.pushState({}, '', href);
					return false;
				});
			}
		}
		
		_self.getPath = function(add) {
			var path = '';
			var pathNames = ['routeType', 'routeId', 'direction', 'from', 'to'];
			$.each(pathNames, function(i, name) {
				if(_state[name]) {
					path += '/' + _state[name];
					return true;
				}
				return false;
			});
			if(add) {
				path += '/' + add;
			}
			return path;
		};
		
		_self.init = function() {
			//_resize();
			
			//_setupHistory();
			
			var $content = $('#content');
			_state = {
				routeType: $content.attr('data-type'),
				routeId: $content.attr('data-route'),
				direction: $content.attr('data-direction'),
				from: $content.attr('data-from'),
				to: $content.attr('data-to')
			};
			
			$.each(_options.components, function(p, c) {
				c.init(_self, _state);
			});
			
			return _self;
		};
		
		NXS._manager = _self;
		NXS._components = _options.components;
		
		return _self;
	};
	
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
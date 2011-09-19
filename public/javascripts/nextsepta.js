var NextSepta = {};

(function(NXS) {
	NXS.Manager = function(options) {
		var _self = {},
			_options = $.extend({
				id: 'container',
				components: {}
			}, options);
		
		function _resize() {
			var $r = $('.nxs-resize');
			if($r.length) {
				var maxHeight = $(window).height() - $r.offset().top - $('#footer').outerHeight();
				$r.css('maxHeight', maxHeight);
			}
		}
		
		_self.init = function() {
			//_resize();
			
			$.each(_options.components, function(p, c) {
				c.init(_self);
			});
			
			return _self;
		};
		
		return _self;
	};
	
	NXS.Stops = function(options) {
		var _self = {},
			_options = {
				id: 'stops',
				target: '#content'
			},
			_manager,
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
		
		_self.init = function(manager) {
			_manager = manager;
			
			$('.nxs-stoptime-left').each(function() {
				var ts = $('time', this).attr('datetime'),
					relText = $('span', this);
					
				if(ts) {
					var dt = new Date(Date.parse(ts));
					if(dt && $.isNaN(dt) === false) {
						_stops.push({ time:dt, el:relText });
					}
				}
			});
			
			_timer();
			
			return _self;
		};
		
		return _self;
	};
})(NextSepta);
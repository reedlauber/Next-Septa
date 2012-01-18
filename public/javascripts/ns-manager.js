(function(NXS) {
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
		
		return _self;
	};
})(NextSepta);
/* NextSepta.Data */
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
})(NextSepta);
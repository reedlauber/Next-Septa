(function(NXS) {
	NXS.Map = function(options) {
		var _self = {},
			_options = $.extend({
				id: 'map'
			}, options),
			_manager;
		
		_self.init = function(manager) {
			_manager = manager;
			
			var $map = $('#' + _options.id);
			
			var lat = parseFloat($map.attr('data-lat')),
				lng = parseFloat($map.attr('data-lng'));

			var latlng = new google.maps.LatLng(lat, lng);

		    var myOptions = {
				zoom: 16,
				center: latlng,
				streetViewControl: false,
				mapTypeId: google.maps.MapTypeId.TERRAIN
		    };
			var map = new google.maps.Map(document.getElementById("map-inner"), myOptions);
			var marker = new google.maps.Marker({
				position: latlng,
				map: map, 
				icon: '/images/markers/bus.png',
				title: 'Bus Location'
			});	

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

			if(navigator.geolocation) {
				navigator.geolocation.getCurrentPosition(function(position) {
			    	var userLatLng = new google.maps.LatLng(position.coords.latitude, position.coords.longitude);
			    	_addUserLocation(userLatLng);
			    });
			}
			
			return _self;
		};
		
		return _self;
	};
})(NextSepta);
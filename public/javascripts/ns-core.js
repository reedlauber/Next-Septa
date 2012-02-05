var NextSepta = {
	Components: {},
	Templates: {},
	template: function(template, data) {
		return Mustache.to_html(template, data);
	}
};
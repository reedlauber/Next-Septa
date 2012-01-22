class ContentController < ApplicationController
	before_filter :set_back_path

	def set_back_path
		@back_path = "javascript:window.history.back();"
	end
end

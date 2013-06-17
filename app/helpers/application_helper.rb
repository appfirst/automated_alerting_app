module ApplicationHelper
	require 'mulit-json'

	def isolate_data(data)
		MultiJson.decode(data)

		print data
		puts "whale"

		:render => data
		logger.debug(data)
		logger.info "blah"
	end

	def last_hour_average(data)

	end
end
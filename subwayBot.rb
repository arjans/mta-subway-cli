#!/usr/bin/env ruby
require 'cinch'

bot = Cinch::Bot.new do
	configure do |c|
		c.server = "serverdomain"
		c.channels = ["#channel1"]
		c.nick = "nick"
		c.password = "password"
	end

	on :message, /^subway ([a-zA-Z0-9_ ]*)$/ do |message, cap|
                cap.gsub!(/status/, "--status")
		reply = %x[./mta-subway-cli/subway.rb --no-color #{cap}].gsub!(/  /, " ")
		message.reply reply
	end
end

bot.start

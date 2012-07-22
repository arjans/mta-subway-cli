#!/usr/bin/ruby
require 'csv'

$filename = "stops.csv"
$colorsEnabled = true
$timeOption = "AMPM"

class String
	def color(c)
		return $colorsEnabled ? "\e[#{c}m#{self}\e[0m" : self
	end
end

def loadStopsFile (filename)
	stops =  CSV.read($filename)
	return stops
end

def getStopTimes (stopID, stops, numTimes)
	case Time.now.wday
	when 0 then day = "SUN"
	when 6 then day = "SAT"
	else        day = "WKD"
	end

	time = (Time.now.hour * 3600) + (Time.now.min * 60) + Time.now.sec
	counter = 0

	case stopID[0].chr
	when "B", "D", "F", "M" then subwayColor = 101
	when "1", "2", "3"      then subwayColor = 41
	when "4", "5", "6"      then subwayColor = 42
	when "G"                then subwayColor = 102
	when "N", "Q", "R"      then subwayColor = 103
	when "A", "C", "E"      then subwayColor = 44
	when "J", "Z"           then subwayColor = 100
	when "7"                then subwayColor = 45
	end

	direction = (stopID[-1,1] == "N") ? "Northbound ".color(40).color(37): "Southbound ".color(40).color(37)

	print "#{direction}"
	print " #{stopID[0].chr} ".color(subwayColor).color(97)

	stops.each do |row|
		if (row[0] == stopID) then
			print " arriving at #{row[1].color(32)} "
			break
		end
	end
	stops.each do |row|
		if (row[0] == stopID && row[2] == day) then
			seconds = row[3].to_i
			if (seconds > time) then
				seconds = $timeOption == "relative" ? seconds -= time : seconds 

				hours = seconds / 3600
				minutes = (seconds / 60) - (hours * 60)
				seconds = seconds - (hours * 3600) - (minutes * 60)
				if ($timeOption == "AMPM") then
					ampm = (hours > 12) ? "PM" : "AM"
					hours = hours - 12 if (hours > 12)
				end


				if ($timeOption == "relative") then
					prefix = numTimes > 1 ? "\n   in " : "in "
					hours = hours > 0 ? "#{hours} Hours " : ""
					minutes = "#{minutes} Minutes" if (minutes > 0)
					minutes = "#{minutes} and "  if (hours || minutes)
					seconds = "#{seconds} Seconds" if (seconds > 0)
				else
					prefix = "at "
					hours = "#{hours}:" if (hours)
					minutes = minutes < 10 ? "0#{minutes}:" : "#{minutes}:"
					seconds = seconds < 10 ? "0#{seconds}:" : "#{seconds}"
				end

				print "#{prefix}#{hours}#{minutes}#{seconds}#{ampm} "      

				counter += 1
				if (counter == numTimes) then
					puts ""
					return true
				end
			end
		end
	end
end

def main

	puts "Please run 'generateStops.rb'." if (!File.exists?($filename))

	stops = loadStopsFile($filename)
	uniqueStops = []
	numTimes = 3
	excludeDirection = nil

	if (ARGV.include?("-n")) then
		numTimesIndex = ARGV.index("-n") + 1
		numTimes = ARGV[numTimesIndex]
		ARGV.delete_at(numTimesIndex)
		ARGV.delete("-n")
	end

	if (ARGV.include?("--no-color")) then
		$colorsEnabled = false
		ARGV.delete("--no-color")
	end

	if (ARGV.include?("--military")) then
		$timeOption = "military"
		ARGV.delete("--military")
	end

	if (ARGV.include?("--relative")) then
		$timeOption = "relative"
		ARGV.delete("--relative")
	end

	excludeDirection = (ARGV.include?("N") || ARGV.include?("n") || ARGV.include?("North") || ARGV.include?("north")) ? "S" : excludeDirection
	excludeDirection = (ARGV.include?("S") || ARGV.include?("s") || ARGV.include?("South") || ARGV.include?("south")) ? "N" : excludeDirection

	if (ARGV.length > 0) then
		stops.each do |row|
			if (row[1].downcase.match(ARGV[0].downcase) && !(uniqueStops.include?(row[0])) && !(row[0][-1,1] == excludeDirection))
				getStopTimes(row[0], stops, numTimes.to_i)
				uniqueStops.push(row[0])
			end
		end
	else
		stops.each do |row|
			if (!uniqueStops.include?(row[0]) && !("stop_id" == row[0])) then
				uniqueStops.push(row[0])
			end
		end
		uniqueStops.sort!
		uniqueStops.each do |row|
			getStopTimes(row, stops, numTimes.to_i)
		end
	end
end

main

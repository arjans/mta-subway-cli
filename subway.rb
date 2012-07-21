#!/usr/bin/ruby
require 'csv'

$filename = "stops.csv"
$colorsEnabled = true

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
      print " arriving at #{row[1].color(32)} at "
      break
    end
  end
  stops.each do |row|
    if (row[0] == stopID && row[2] == day) then
      if (row[3].to_i > time) then
        hours = row[3].to_i / 3600
        minutes = (row[3].to_i - (hours * 3600)) / 60
        seconds = (row[3].to_i - (hours * 3600) - (minutes * 60))
        hours = hours - 12 if (hours > 12)
        hours = "0" + hours.to_s if (hours < 10)
        minutes = "0" + minutes.to_s if (minutes < 10)
        seconds = "0" + seconds.to_s if (seconds < 10)
        print "#{hours}:#{minutes}:#{seconds} "
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

  if (ARGV.include?("-n"))
    numTimesIndex = ARGV.index("-n") + 1
    numTimes = ARGV[numTimesIndex]
    ARGV.delete_at(numTimesIndex)
    ARGV.delete("-n")
  end

  if (ARGV.include?("--no-color"))
  then
    $colorsEnabled = false
    ARGV.delete("--no-color")
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

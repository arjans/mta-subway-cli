#!/usr/bin/ruby
require 'csv'

$filename = "milstops.csv"
$colorsEnabled = true

class String
  def color(c)
    colors = {
      :black   => 30,
      :red     => 31,
      :green   => 32,
      :yellow  => 33,
      :blue    => 34,
      :magenta => 35,
      :cyan    => 36,
      :white   => 37,
      :orange  => 91
    }
    if ($colorsEnabled) then
      return "\e[#{colors[c] || c}m#{self}\e[0m"
    else
      return self
    end
  end
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
  when "B", "D", "F", "M"
    subwayColor = 101
  when "1", "2", "3"
    subwayColor = 41
  when "4", "5", "6"
    subwayColor = 42
  when "G"
    subwayColor = 102
  when "N", "Q", "R"
    subwayColor = 103
  when "A", "C", "E"
    subwayColor = 44
  when "J", "Z"
    subwayColor = 100
  when "7"
    subwayColor = 45
  end
  if (stopID[-1,1] == "N")
    direction = "Northbound ".color(40).color(:white)
  else
    direction = "Southbound ".color(40).color(:white)
  end
  print "#{direction}"
  print " #{stopID[0].chr} ".color(subwayColor).color(:white)
  stops.each do |row|
    if (row[0] == stopID) then
      print " arriving at #{row[1].color(:green)} at "
      break
    end
  end
  stops.each do |row|
    if (row[0] == stopID && row[2] == day) then
      if (row[3].to_i > time) then
        hours = row[3].to_i / 3600
        minutes = (row[3].to_i - (hours * 3600)) / 60
        seconds = (row[3].to_i - (hours * 3600) - (minutes * 60))
        if (hours > 12)
          hours = hours - 12
        end
        if (hours < 10)
          hours = "0" + hours.to_s
        end
        if (minutes < 10)
          minutes = "0" + minutes.to_s
        end
        if (seconds < 10)
          seconds = "0" + seconds.to_s
        end
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

def loadStopsFile (filename)
  stops =  CSV.read($filename)
  return stops
end

def main

  if (!File.exists?($filename))
    puts "Please run 'generateStops.rb'."
  end

  stops = loadStopsFile($filename)
  uniqueStops = []
  numTimes = 3

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

  if (ARGV.include?("N") || ARGV.include?("n") || ARGV.include?("North") || ARGV.include?("north")) then
    stops.each do |row|
      if (row[1].downcase.match(ARGV[0].downcase) && (row[0][-1,1] == "S"))
        uniqueStops.push(row[0])
        break
      end
    end
  end

  if (ARGV.include?("S") || ARGV.include?("s") || ARGV.include?("South") || ARGV.include?("south")) then
    stops.each do |row|
      if (row[1].downcase.match(ARGV[0].downcase) && (row[0][-1,1] == "N"))
        uniqueStops.push(row[0])
        break
      end
    end
  end

  clOption = false
  if (ARGV) then
    ARGV.each do |arg|
      if (arg.match('.*'))
        clOption = true
      end
    end
  end

  if (clOption) then
    stops.each do |row|
      if (row[1].downcase.match(ARGV[0].downcase) && !(uniqueStops.include?(row[0])))
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
    uniqueStops.each do |row|
      getStopTimes(row, stops, numTimes.to_i)
    end
  end
end

main

#!/usr/bin/env ruby
require 'csv'
require 'nokogiri'
require 'open-uri'

$filename = "stops.csv"
$colorsEnabled = true
$timeOption = "AMPM"
$statusUpdates = false

class String
  def color(c)
    return $colorsEnabled ? "\e[#{c}m#{self}\e[0m" : self
  end
end

def loadStopsFile (filename)
  stops =  CSV.read($filename)
  return stops
end

def getStopTimes (stopandline, stops, numTimes)
  case Time.now.wday
  when 0 then day = "SUN"
  when 6 then day = "SAT"
  else        day = "WKD"
  end

  time = (Time.now.hour * 3600) + (Time.now.min * 60) + Time.now.sec
  counter = 0

  case stopandline[1]
  when "B", "D", "F", "M" then subwayColor = 101
  when "1", "2", "3"      then subwayColor = 41
  when "4", "5", "6"      then subwayColor = 42
  when "G"                then subwayColor = 102
  when "N", "Q", "R"      then subwayColor = 103
  when "A", "C", "E"      then subwayColor = 44
  when "J", "Z"           then subwayColor = 100
  when "7"                then subwayColor = 45
  end

  direction = (stopandline[0][-1,1] == "N") ? "Northbound ".color(40).color(37): "Southbound ".color(40).color(37)

  print "#{direction}"
  print " #{stopandline[1]} ".color(subwayColor).color(97)

  stops.each do |row|
    if (row[0] == stopandline[0]) then
      print " arriving at #{row[2].color(32)} "
      break
    end
  end
  stops.each do |row|
    if (row[0] == stopandline[0] && stopandline[1] == row[1] && row[3] == day) then
      seconds = row[4].to_i
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

        if ((counter+=1) == numTimes) then
          puts ""
          return true
        end
      end
    end
  end
end

def getStatusUpdates (stops, allUpdates)
  if ($statusUpdates) then
    filestring = ""
    f = (open ('http://www.mta.info/status/serviceStatus.txt'))
    f.each do |line|
      filestring += line
    end
#    filestring.gsub!(/                    &lt;/, "<").gsub!(/                    &amp;nbsp;/, "")
    filestring.gsub!(/&lt;/, "<").gsub!(/&gt;/, ">").gsub!(/&amp;nbsp;/, " ").gsub!(/&amp;/, "")
    doc = Nokogiri::HTML(filestring)
    uniqueLines = []
    stops.each do |row|
      doc.xpath('//subway//name').each do |name|
        if (/#{row[1]}/.match(name) && !(uniqueLines.include?(name)) && !(name.text == "SIR"))
          print name.text.color(31)
          print ": "
          puts name.next_sibling.text.color(31)
          if (allUpdates)
            statusArray = name.next_sibling.next_sibling.text.split("\n").drop(2)
            statusArray.each do |child|
              puts child.color(31)
            end
          elsif(/\[#{row[1]}\]/.match(name.next_sibling.next_sibling.text))
            statusArray = name.next_sibling.next_sibling.text.split("\n").drop(2)
            statusArray.each do |child|
              puts child.color(31)
            end
          end
          uniqueLines.push(name)
        end
      end
    end
  end
end

def main

  if (!File.exists?($filename))
    puts "Please run 'generateStops.rb'"
    return
  end

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

  if (ARGV.include?("--military")) then
    $timeOption = "military"
    ARGV.delete("--military")
  end

  if (ARGV.include?("--relative")) then
    $timeOption = "relative"
    ARGV.delete("--relative")
  end

  if (ARGV.include?("--status")) then
    $statusUpdates = true
    ARGV.delete("--status")
  end

  excludeDirection = (ARGV.include?("North") || ARGV.include?("north")) ? "S" : excludeDirection
  excludeDirection = (ARGV.include?("South") || ARGV.include?("south")) ? "N" : excludeDirection

  userLine = false
  ARGV.each do |elt|
    if !(elt[1]) then
      userLine = elt[0]
    end
  end

  if (ARGV.length > 0) then
    stops.each do |row|
      if (row[2].downcase.match(ARGV[0].downcase) && !(uniqueStops.include?([row[0],row[1]])) && !(row[0][-1,1] == excludeDirection))
        if userLine then
          if (row[1] == userLine.upcase) then
            getStopTimes([row[0],row[1]], stops, numTimes.to_i)
            uniqueStops.push([row[0],row[1]])
          end
        else
          getStopTimes([row[0],row[1]], stops, numTimes.to_i)
          uniqueStops.push([row[0],row[1]])
        end
      end
    end
    getStatusUpdates(uniqueStops.sort!,false)
  else
    stops.each do |row|
      if (!uniqueStops.include?([row[0],row[1]]) && !("id" == row[0])) then
        uniqueStops.push([row[0],row[1]])
      end
    end
    uniqueStops.sort!{|x,y| x[0] <=> y[0]}.each do |row|
      getStopTimes(row, stops, numTimes.to_i)
    end
    getStatusUpdates(uniqueStops,true)
  end
end

main

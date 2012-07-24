#!/usr/bin/env ruby
require 'rubygems'
require 'zipruby'
require 'csv'

require 'net/http'

$mtaSubwayData = "mta.info/developers/data/nyct/subway/google_transit.zip"
$outputFile = ARGV[0] ? ARGV[0] : "stops.csv"
$lines = {}

class String
  def color(c)
    colors = {
      :red     => 31,
      :green   => 32,
      :yellow  => 33,
      :blue    => 34,
      :magenta => 35
    }
    return "\e[#{colors[c] || c}m#{self}\e[0m"
  end
end

def printHeader
  system("clear")
  puts "generateStops.rb ::".color(:green) + " Generates a consise CSV database for subway.rb".color(:yellow)
  puts "------------------------------------------------------------------"
end

def generateStopsFile (userStops, stopTimesCsv)
  printHeader

  puts "--> Generating Stops CSV".color(:green)
  puts "    (This may take a little while, go brew some coffee)"
  puts "    (No worries, this is a one time proccess)"

  CSV.open($outputFile, "wb") do |csv|
    csv << ["id", "line", "name", "day", "time"]
    CSV.parse(stopTimesCsv) do |row|
      line = row[0].match(/_(.)\.\./)
      if line then
        line = line[1]
      else
        next
      end

      userStops.each do |stop|
        if (stop[:id] == row[3] && stop[:line] == line) then
          day = row[0].match(/^[ABRS]\d+(WKD|SAT|SUN)/)[1]
          hours,minutes,seconds = row[1].split(':')
          seconds = seconds.to_i + (hours.to_i * 3600) + (minutes.to_i * 60)
          csv << [stop[:id], stop[:line], stop[:name], day, seconds]
        end
      end
    end
  end

  printHeader
  puts "--> Stops CSV File Generated to #{$outputFile}, subway.rb may be used now".color(:green)
end

def stopInfo(stop)
  info  = "#{stop[:id][-1,1] == "N" ? "North" : "South"}bound".color(:yellow)
  info += " #{stop[:line]} Train ".color(:magenta)
  return info += "at #{stop[:name]} ".color(:red)
end

def promptStops(stopsCsv)
  allStops = []
  CSV.parse(stopsCsv).each do |row|
    if (row[0].match(/.+[NS]/)) then
      if ($lines[row[0]]) then
        $lines[row[0]].each do |line|
          allStops.push({ :id => row[0], :name => row[2], :line => line })
        end
      end
    end	
  end

  #Continually add stops to added stops until 'done'
  addedStops = []
  loop do

    #Print Header & Current Stops Added
    printHeader
    if (addedStops.length > 0) then
      puts"Your Subway Stops:".color(:magenta)
      addedStops.each { |stop| puts "--> #{stopInfo(stop)}" }
      print "\n\n"
    end

    #Prompt User for a stop to add
    print "Add a Subway Stop (ex: York, Prospect, 7 Ave) (or \"done\")\n> "
    stopname = gets.downcase.chomp!

    #End once user types done
    if (stopname == "done") then
      return addedStops 


    else
      print "\n"
      options = []
      allStops.each do |stop|
        if (stop[:name].downcase.match(/#{stopname}/)) then
          puts "[#{options.length.to_s}] #{stopInfo(stop)}".color(:green)
          options.push(stop)
        end
      end
      print "\nEnter desired #{"[stop numbers]".color(:green)}, separated by spaces (ex: 0 2 5)\n> "
      gets.chomp!.split(' ').each do |choice|
        if (choice.to_i <= options.length) then
          addedStops.push(options[choice.to_i])
        end
      end
    end
  end
end

def generateLines(stopTimesCsv)
  printHeader
  puts "--> Determining Lines Running at Each Station".color(:green)
  puts "    (Sorry for the delay, Parsing a 31MB CSV File"
  puts "    (Hopefully this won't take too long)"

  CSV.parse(stopTimesCsv) do |row|
    lineLetter = row[0].match(/_(.)\.\./)
    if lineLetter then
      lineLetter = lineLetter[1]
    else
      next
    end

    if (!$lines[row[3]])
      $lines[row[3]] = [ lineLetter ]
    elsif (!$lines[row[3]].include?(lineLetter))
      $lines[row[3]].push(lineLetter)
    end
  end	
end

def main

  # Check if output file already exists, prompt if so, if no then continue
  if (File.exists?($outputFile)) then
    printHeader
    print "#{$outputFile} already exists. Continue/Overwrite? [Y/N]: ".color(:red)
    if (!(gets.chomp! =~ /y/i)) then
      puts "Please rerun generateStops.rb with a non-existant file"
      return
    end
  end

  # Print Generating file
  printHeader
  puts "--> Generated file will be stored in #{$outputFile.color(:red)}".color(:green)


  # Split up URL for Net:HTTP
  mtaDomain  = $mtaSubwayData.split('/')[0]
  subwayData = $mtaSubwayData[mtaDomain.length .. $mtaSubwayData.length]

  Net::HTTP.start(mtaDomain) do |http|
    # Fetch the ZIP file from the MTA Site
    puts "--> Fetching Subway Data from the MTA Site".color(:green);
    puts "    (This may take a bit, the ZIP is around 5MB)"
    puts "    (I hope you gots good internets)"

    Zip::Archive.open_buffer(http.get(subwayData).response.body) do |zip|
      lines = generateLines(zip.fopen("stop_times.txt").read)
      stops = promptStops(zip.fopen("stops.txt").read)
      generateStopsFile(stops, zip.fopen("stop_times.txt").read)
    end
  end
end

main

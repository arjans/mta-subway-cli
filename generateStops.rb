#!/usr/bin/ruby
require 'zipruby'
require 'csv'
require 'net/http'

$mtaSubwayData = "mta.info/developers/data/nyct/subway/google_transit.zip"
$outputFile = "stops.csv"

class String
	def color(c)
		colors = {
			:red    => 31,
			:green  => 32,
			:yellow => 33,
			:blue   => 34,
			:magenta => 35
		}
		return "\e[#{colors[c] || c}m#{self}\e[0m"
	end
end

def generateStopsFile (userStops, stopTimesCsv)
  puts "--> Generating Stops CSV...".color(:green)
  CSV.open($outputFile, "wb") do |csv|
    csv << ["stop_id", "day", "time"]
    i = 0
    CSV.parse(stopTimesCsv) do |row|
      userStops.each do |stop|
        if (stop[0] == row[3]) then
          day = row[0].match(/^[ABRS]\d+(WKD|SAT|SUN)/)[1]
          hours,minutes,seconds = row[1].split(':')
          seconds = seconds.to_i + (hours.to_i * 3600) + (minutes.to_i * 60)
        csv << [row[3], stop[1], day, seconds]
        end
      end
    end
  end

	puts "--> Stops CSV File Generated, subway.rb may be used now"
end

def promptStops(stopsCsv)
	puts "--> Extracted Stops CSV, Parsing Now".color(:green)
	puts "-----------------------------------------------------------------"
	puts "Add Subway Stops:".color(:magenta)
  allstops = []
  CSV.parse(stopsCsv) do |row|
    allstops.push([row[0],row[2]])
  end
  userchoices = []
  loop do
    print "Enter the name of your stop (or 'done' when finished): "
    stopname = gets.chomp!
    if (stopname == "done") then
      return userchoices
    end
    useroptions = []
    allstops.each do |row|
      if (row[0].match(/.+[NS]/) && row[1].downcase.match(/#{stopname.downcase}/)) then
        puts "[#{useroptions.length.to_s}] #{row[0]} #{row[1]}"
        useroptions.push(row)
      end
    end
    print "Enter your stop number(s), separated by spaces: "
    stopchoices = gets.chomp!.split(' ')
    stopchoices.each do |choice|
      userchoices.push([useroptions[choice.to_i][0],useroptions[choice.to_i][1]])
    end
  end
end

def main
	mtaDomain  = $mtaSubwayData.split('/')[0]
	subwayData = $mtaSubwayData[mtaDomain.length .. $mtaSubwayData.length]

	puts "generateStops.rb ::".color(:red) + " Generates a consise CSV database for subway.rb".color(:yellow)
	puts "-----------------------------------------------------------------"
	puts "--> Fetching Subway Data from the MTA Site".color(:green);
	Net::HTTP.start(mtaDomain) do |http|
		Zip::Archive.open_buffer(http.get(subwayData).response.body) do |zip|

			#Get the stop times
			stopsCsv = ""
			zip.fopen("stops.txt") do |line|
				stopsCsv = line.read
			end
			stops = promptStops(stopsCsv)

			stopTimesCsv =""
			zip.fopen("stop_times.txt") do |line|
				stopTimesCsv = line.read
			end
			generateStopsFile(stops, stopTimesCsv)


		end
	end
end

main

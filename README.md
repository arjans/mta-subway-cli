MTA Subway CLI
==============
![MTA Subway CLI](http://userbound.com/images/mta-subway-cli/3-stations.png)

This is a simple command line interface to the NYC MTA Subways. The jist of it is you can do something like ```subway.rb york north``` and you'll get the next few subway times for York Street Northbound. ```subway.rb``` may be used with several command line options such that you can specify: the number of upcoming times, 24hr/12hr clock, relative times (next subway in 12 minutes), and a no color option for scripting.

The one caveat is that you have to fetch and download MTA's Subway data prior to first use. This is handled by the included script called ```generateStops.rb```. ```generateStops.rb``` generates a ```stops.csv``` file from MTA's Open Subway data. ```generateStops.rb``` will prompt you for the stops you'd like to be able to use ```subway.rb```. ```generateStops.rb``` may be re-run at any time to re-fetch the most up to date MTA Subway data and regenerate ```stops.csv```.

Setup
-----
1. Clone the repo:           ```git clone http://github.com/jns2/mta-subway-cli```
2. Go into the directory:    ```cd mta-subway-cli```
3. Install gems:  ```gem install zipruby nokogiri```
3. Run generateStops.rb:     ```ruby generateStops.rb```
4. That's it, Use subway.rb: ```ruby subway.rb```

Usage
-----
**subway.rb** stop-name *[line]* *[north/south]*
- ```-n #```: Specifies the number of upcoming times for each stop
- ```--status```: Shows an up to date status update for the given subway line
- ```--military```: Displays time in 24 hour format (ex: 15:30:20)
- ```--relative```: Display times relative to the current time (ex: 14 Minutes)
- ```--no-color```: Removes color from the output

**Examples:**

- $ ```./subway``` 
    * ![MTA Subway CLI](http://userbound.com/images/mta-subway-cli/3-stations.png)

- $ ```./subway.rb herald d south```
    * ![MTA Subway CLI Herald North](http://userbound.com/images/mta-subway-cli/herald-north.png)

- $ ```./subway.rb 6 south 33 st```
    * ![MTA Subway CLI 33 S](http://userbound.com/images/mta-subway-cli/33-s.png)


Requirements & Dependencies
---------------------------
- Ruby >=1.8.7
- [zipruby Gem](http://bitbucket.org/winebarrel/zip-ruby)
	* Used to extract the ZIP of MTA's Subway Data to generate ```stops.csv```
- [Nokogiri Gem](http://nokogiri.org)
	* Used to fetch subway status updates from the MTA site

Authors
-------
Created by Arjan Singh ([jns2](http://github.com/jns2)) and Miles Sandlar ([mil](http://github.com/mil)) during [Hacker School [3]](http://hackerschool.com)

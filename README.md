MTA Subway CLI
==============
This is a simple command line interface to the MTA Subways. The jist of it is you can do something like ```subway.rb york north``` and you'll get the next few subway times for York Street Northbound.

The one caveat is that you have to generate a stops.csv file from MTA's Open Subway data. This is necessary as parsing through ~5MB of data each run is not reasonable. generateStops.rb faciliates generating a concise CSV file (stops.csv) containing only the stop times necessary for you.

Setup
-----
1. Clone the repo:           ```git clone http://github.com/jns2/mta-subway-cli```
2. Go into the directory:    ```cd mta-subway-cli```
3. Install the zipruby gem:  ```gem install zipruby```
3. Run generateStops.rb:     ```ruby generateStops.rb```
4. That's it, Use subway.rb: ```ruby subway.rb```

Requirements & Dependencies
---------------------------
- Ruby 1.9 >
- zipruby gem


Authors
-------
Created by Arjan Singer ([jns2](http://github.com/jns2)) and Miles Sandlar ([mil](http://github.com/mil))

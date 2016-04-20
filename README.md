# CIS REST Server
A simple REST server for the [CIS challenge 2016](http://cis.eecs.qmul.ac.uk/IoT2016.html), an instance of which is running at https://cis.amar.io/.

Since this is for a small-scale project, no load-balancing is done. If the primary instance can no longer handle your requests, there is an alternate instance running at http://cis3.amar.io/. Note however that that instance uses plain, unencrypted HTTP and that you may get worse latency as the server is in the US.

## Installation
	git clone https://github.com/yousefamar/cis-rest-server.git
	cd rest-server
	npm install

## Usage

### Running

	npm start

Default port is 8080, but can be overridden using the PORT environment variable, i.e.:

	PORT=8081 npm start

### Visualization

Currently, rudimentary single line charts are supported. Browse to `/[group]/[type]` to see a live visualization of the corresponding `value` for each entry for that group and sensor type. Data range can be adjusted by time and count using sliders:

![CIS Server Live Line Chart Visualization](https://i.imgur.com/6bKBOFR.gif "CIS Server Live Line Chart Visualization")

## API Endpoints

All accept form-encoded POST parameters and return JSON.

### /write

Writes an entry to the DB.

#### Parameters:
  - group
  - type
  - value

#### Response:
  - Empty response with status code 200 on success

### /read-all

Lists all entries for a given group and sensor type.

#### Parameters:
  - group
  - type

#### Response:
  - An array of JSON-encoded DB entries

### /read

Lists all entries for a given group and sensor type between a set time range [from, to]. 

If just a 'to' is provided than everything is loaded from the start until the given time (inclusive). If just 'from' is provided, the data from this given time until now is loaded.

Limit is a numerical limit, i.e. if limit is 1, you only get the latest entry, and if it's 500, you get up to the latest 500 entries.

If no parameter is given, all values are loaded.

#### Parameters:
  - group
  - type
  - from (inclusive, optional)
  - to (inclusive, optional)
  - limit (optional)

#### Response:
  - An array of JSON-encoded DB entries

##License
[ISC](https://opensource.org/licenses/ISC).

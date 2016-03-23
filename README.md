# CIS REST Server
A simple REST server for the [CIS challenge 2016](http://cis.eecs.qmul.ac.uk/IoT2016.html), an instance of which is running at http://cis.amar.io/.

## Installation
	git clone https://github.com/yousefamar/cis-rest-server.git
	cd rest-server
	npm install

## Usage
	npm start

Default port is 8080, but can be overridden using the PORT environment variable, i.e.:

	PORT=8081 npm start

Browse to `/[group]/[type]` to see a live line chart visualization of the corresponding `value`.

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

If no parameter is given, all values are loaded. 

#### Parameters:
  - group
  - type
  - from (inclusive, optional)
  - to (inclusive, optional)

#### Response:
  - An array of JSON-encoded DB entries

##License
[ISC](https://opensource.org/licenses/ISC).

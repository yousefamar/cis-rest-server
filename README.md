# CIS REST Server
A Databox Docker registry front-end, an instance of which is running at http://datashop.amar.io/.

## Installation
	git clone https://github.com/yousefamar/rest-server.git
	cd rest-server
	npm install

## Usage
	npm start

Default port is 8080, but can be overridden using the PORT environment variable, i.e.:

	PORT=8081 npm start

## API Endpoints

All accept form-encoded POST or GET parameters and return JSON.

### /api/write

Writes an entry to the DB.

#### Parameters:
  - group
  - type
  - value

#### Response:
  - Empty response with status code 200 on success

### /api/read-all

Lists all entries for a given group and sensor type.

#### Parameters:
  - group
  - type

#### Response:
  - An array of JSON-encoded DB entries

### /api/read

Lists all entries for a given group and sensor type between a set time range [from, to].

#### Parameters:
  - group
  - type
  - from (inclusive)
  - to (inclusive)

#### Response:
  - An array of JSON-encoded DB entries

##License
[ISC](https://opensource.org/licenses/ISC).

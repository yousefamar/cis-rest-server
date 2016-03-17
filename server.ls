#!/usr/bin/env lsc

require! {
  express
  \body-parser
  mongodb
}

err, db <-! mongodb.MongoClient.connect \mongodb://localhost:27017/cis-iot-challenge

throw err if err?


app = express!
  ..use body-parser.urlencoded extended: false

#####################################################################################

app.post \/write (req, res) !->
  data = req.body

  unless data.group?
    res.write-head 400 "no 'group' defined" 'content-type': \text/plain
    res.end!
    return

  unless data.type?
    res.write-head 400 "no 'type' defined" 'content-type': \text/plain
    res.end!
    return

  unless data.value?
    res.write-head 400 "no 'value' defined" 'content-type': \text/plain
    res.end!
    return

  entry =
    timestamp: new Date!
    type: data.type
    value: data.value

  db.collection data.group .insert-one entry

  res.write-head 200 do
    'Access-Control-Allow-Origin': req.headers.origin or \*
    'Content-Type': \application/json
  res.end!

#####################################################################################

app.post \/write-bulk (req, res) !->
  data = req.body

  # TODO: Implement
  #db.collection data.group .insert-many!

  res.write-head 501, "write data in bulk is not yet implemented" 'content-type': \text/plain
  res.end!

#####################################################################################

app.post \/read-all (req, res) !->
  data = req.body

  unless data.group?
    res.write-head 400 "no 'group' defined" 'content-type': \text/plain
    res.end!
    return

  unless data.type?
    res.write-head 400 "no 'type' defined" 'content-type': \text/plain
    res.end!
    return

  err, docs <-! db.collection data.group .find { data.type } .to-array

  throw err if err?

  res.write-head 200 do
    'Access-Control-Allow-Origin': req.headers.origin or \*
    'Content-Type': \application/json
  docs |> JSON.stringify |> res.end

#####################################################################################

app.post \/read (req, res) !->
  data = req.body

  unless data.group?
    res.write-head 400 "no 'group' defined" 'content-type': \text/plain
    res.end!
    return

  unless data.type?
    res.write-head 400 "no 'type' defined" 'content-type': \text/plain
    res.end!
    return

  from = data.from or new Date 0
  to   = data.to   or new Date!

  db.collection data.group .find do
    type: data.type
    timestamp:
      $gte: new Date from
      $lte: new Date to
  .to-array (err, docs) !->
    throw err if err?

    res.write-head 200 do
      'Access-Control-Allow-Origin': req.headers.origin or \*
      'Content-Type': \application/json
    docs |> JSON.stringify |> res.end

#####################################################################################

app.post \* (req, res) !->
  res.write-head 404
  res.end!

app.listen (process.env.PORT or 8080)

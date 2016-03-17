require! {
  express
  \body-parser
  mongodb
}

err, db <-! mongodb.MongoClient.connect \mongodb://localhost:27017/cis-iot-challenge

throw err if err?

app = express!
  ..use body-parser.urlencoded extended: false

handle = (req, res, data) !->

  unless data.group?
    res.write-head 400 "no 'group' defined" 'content-type': \text/plain
    res.end!
    return

  switch req.params.method

  | \write
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

  | \write-bulk
    # TODO: Implement
    #db.collection data.group .insert-many!

    res.write-head 501, "write data in bulk is not yet implemented" 'content-type': \text/plain
    res.end!

  | \read-all
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

  | \read
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

  | otherwise
    res.write-head 404
    res.end!
    break

app.get  \/:method (req, res) !-> handle req, res, req.query
app.post \/:method (req, res) !-> handle req, res, req.body

app.listen (process.env.PORT or 8080)

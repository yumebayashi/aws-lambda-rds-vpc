aws = require 'aws-sdk'
s3 = new aws.S3 { apiVersion: '2006-03-01' }
mysql = require 'mysql'
async = require 'async'
dns = require 'dns'
stages = "production"
bucket = "mybucket-lambda"

config = (_key, callback) ->
  params =
    Bucket: bucket
    Key: "#{_key}/#{stages}.json"
  s3.getObject params, (err, data) ->
    return callback(err, null) if err
    callback(null, JSON.parse(data.Body))

defineRDS = (next) ->
  config "rds", (err, data) ->
    return next(err, null) if err
    dns.lookup data.endpoint, (err, address, family) ->
      return next(err, null) if err
      pool = mysql.createPool {
        host : address
        user : data.username
        password : data.password
        database : data.database
        connectionLimit: 5
      }
      next null, pool

execQuery = (pool, next) ->
  console.log "start rds connect"
  query = "select id, name from users;"
  pool.query query, (err, rows, fields) ->
    next err, rows

exports.handler = (event, context) ->
  async.waterfall [
    (callback) ->
      defineRDS callback
    ,(args, callback) ->
      execQuery args, callback
  ], (err, args) ->
    return context.fail err if err
    console.log args
    context.done()

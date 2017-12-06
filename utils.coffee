redis = require("redis")
{Response} = require('./vo/Response')
dbconfig = require('./config').db


#如果用户登陆了，返回true，否则返回false，并且转向登陆界面
exports.authenticateUser = (req,res)->
  result = @isLoginUser(req)
  path = "/login"
  path = "/m/login" if @isMobileClient(req)
  res.redirect(path) unless result

  result

exports.isMobileClient = (req)->
  urlArray = req.path.split("/")
  #console.log urlArray
  urlArray[1] == "m"

#如果用户登陆了，返回true，否则返回false
exports.isLoginUser = (req)->
  req.session?.userId and true


#如果用户是管理员，返回true，否则返回false ，并且转向登陆界面
exports.authenticateAdmin = (req,res)->
  result = @isAdmin(req)
  unless result
    if @isLoginUser(req)
      res.redirect('/show')
    else
      res.redirect('/login')

  result

#如果用户是管理员，返回true，否则返回false
exports.isAdmin = (req)->
  @isLoginUser(req) and req.session.isAdmin == 1

exports.showDBError = (callback, client=null, message='数据库错误')->
  client.quit() if client
  callback(new Response(0,message))

exports.createClient = ->
  client = redis.createClient(dbconfig.port, dbconfig.host)
  if dbconfig.pass
    client.auth(dbconfig.pass, (err)->
      throw err if err)

  client.on("error", (err)->
    console.log(err)
    client.end())

  client



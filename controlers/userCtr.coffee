crypto = require('crypto')
check = require('validator').check
utils = require('../utils')
userModel = require('../models/usersModel')
{Response} = require('../vo/Response')

exports.loginIndex = (req, res) ->
    res.render("login")

exports.indexMobile = (req, res) ->
  if utils.isLoginUser(req)
    res.redirect('/m/write')
  else
    res.redirect('/m/login')

exports.loginIndexMobile = (req, res) ->
  if utils.isLoginUser(req)
    res.redirect('/m/write')
  else
    res.render("mobile/login", {'title':"登录", layout:"mobile/layout.hbs"})

exports.login = (req, res) ->
  userName = req.body.userName
  password = req.body.password
  hashedPassword = crypto.createHash("sha1").update(password).digest('hex')
  userModel.getAllUsersWithPassword((response)->
    return res.send(response) if response.state == 0
    users = response.data
    userId = null
    for key, value of users
      [id,property] = key.split(":")

      if (property == "user_name" and value == userName)
        userId = id
        break

    return res.send(new Response(1, "用户名:#{userName}不存在", 0)) unless userId
    #return res.render("login",{hasError:true, message:"用户名:#{userName}不存在"}) unless userId

    hasThisUser = false
    for key, value of users
      [id,property] = key.split(":")
      if (id == userId and property == "password" and value == hashedPassword)
        userId = id
        hasThisUser = true
        break
    #return res.render("login",{hasError:true, message:"密码错误"}) unless hasThisUser
    return res.send(new Response(1, "密码错误", 0)) unless hasThisUser
    #console.log "userName:#{userName}, userId:#{userId}"
    req.session.userId = userId

    userModel.getAdminIds((response)->
      return res.send(new Response(1, "success", 1)) if response.state == 0
      ids = response.data

      for id in ids
        if id == userId
          req.session.isAdmin = 1
          break
      res.send(new Response(1, "success", 1))))
      #return res.redirect("/show")))

exports.logout = (req, res) ->
  return unless utils.authenticateUser(req,res)
  req.session.destroy()
  res.redirect("/login")

exports.logoutMobileIndex = (req, res) ->
  return unless utils.authenticateUser(req,res)
  req.session.destroy()
  res.render("mobile/login", {'title':"登录", layout:"mobile/layout.hbs"})

exports.passwordIndex = (req, res) ->
  return unless utils.authenticateUser(req,res)
  userId = req.session.userId
  userModel.hasSubordinate(userId, (result)->
    data = {hasSubordinate: result, isLoginUser:utils.isLoginUser(req), isAdmin:utils.isAdmin(req)}
    res.render("password", data))

exports.passwordMobileIndex = (req, res) ->
  return unless utils.authenticateUser(req,res)
  userId = req.session.userId
  userModel.hasSubordinate(userId, (result)->
    data = {hasSubordinate: result,'title':"修改密码", layout:"mobile/layout.hbs"}
    console.log data
    res.render("mobile/password", data))

exports.changePassword = (req, res) ->
  return unless utils.authenticateUser(req,res)

  userId = req.session.userId
  oldPassword = crypto.createHash("sha1").update(req.body.oldPassword).digest('hex')
  newPassword = crypto.createHash("sha1").update(req.body.newPassword).digest('hex')

  userModel.changePassword(userId, newPassword, oldPassword, (response)->
    res.send(response))


exports.createUser = (req, res) ->
  return unless utils.authenticateAdmin(req,res)

  userName = req.body.userName
  password = req.body.password
  departmentId = req.body.departmentId;
  superiorId = req.body.superiorId;

  try
    check(userName, "字符长度为2-25").len(2,25)
    check(password, "字符长度为7-25").len(7,25)
  catch  error
    errorMessage = error.message
    return res.send(new Response(0, errorMessage))

  userModel.hasUser(userName, (response)->
    return res.send(response) if response.state == 0 or response.data
    hashedPassword = crypto.createHash("sha1").update(password).digest('hex')
    userModel.createUser(userName, hashedPassword, departmentId, superiorId, (response)->
      res.send(response)))

exports.removeUser = (req, res) ->
  return unless utils.authenticateAdmin(req,res)
  userId = req.body.userId
  userModel.removeUser(userId, (response)->
      res.send(response))

exports.updateUser = (req, res) ->
  return unless utils.authenticateAdmin(req,res)
  userId = req.body.userId
  userName = req.body.userName
  password = req.body.password
  departmentId = req.body.departmentId;
  superiorId = req.body.superiorId;

  try
    check(userName, "字符长度为6-25").len(6,25)
    hashedPassword = null
    hashedPassword = crypto.createHash("sha1").update(password).digest('hex') if password
    userModel.updateUser(userId, userName, hashedPassword, departmentId, superiorId, (response)->
      res.send(response))
  catch error
    res.send(new Response(0,error.errorMessage))

exports.getAllUsers = (req, res) ->
  userModel.getAllUsers((response)->
    res.send(response))

exports.getAdmins = (req, res) ->
  return unless utils.authenticateAdmin(req,res)
  userModel.getAdminIds((response)->
    res.send(response))

exports.setAdmin = (req, res) ->
  return unless utils.authenticateAdmin(req,res)
  userId = req.body.userId
  userModel.setAdmin(userId, (response)->
    res.send(response))

exports.deleteAdmin = (req, res) ->
  return unless utils.authenticateAdmin(req,res)
  userId = req.body.userId
  userModel.deleteAdmin(userId, (response)->
    res.send(response))

exports.hasUser = (req, res) ->
  userName = req.body.userName
  userModel.hasUser(userName, (response)->
    res.send(response))

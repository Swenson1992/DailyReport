crypto = require('crypto')
userModel = require('../models/usersModel')

exports.install = (req, res) ->
  userName = "admin"
  password = "1234567"
  hashedPassword = crypto.createHash("sha1").update(password).digest('hex')
  userModel.createDefaultAdmin(userName, hashedPassword, (response)->
    res.render("install"))

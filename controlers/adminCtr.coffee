utils = require('../utils')

exports.index = (req, res) ->
  return unless utils.authenticateAdmin(req,res)
  res.render("admin/department")

exports.usersIndex = (req, res) ->
  return unless utils.authenticateAdmin(req,res)
  res.render("admin/users")

exports.admingroupIndex = (req, res) ->
  return unless utils.authenticateAdmin(req,res)
  res.render("admin/admingroup")


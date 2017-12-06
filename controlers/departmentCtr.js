(function() {
  var Response, check, crypto, departmentModel, utils;

  crypto = require('crypto');

  check = require('validator').check;

  utils = require('../utils');

  departmentModel = require('../models/departmentsModel');

  Response = require('../vo/Response').Response;

  exports.createDepartment = function(req, res) {
    var departmentName, error, errorMessage, parentId;
    if (!utils.authenticateAdmin(req, res)) {
      return;
    }
    departmentName = req.body.departmentName;
    parentId = req.body.pid;
    try {
      check(departmentName, "部门名称不能为空").notEmpty().notContains(":");
      return departmentModel.createDepartment(departmentName, parentId, function(response) {
        return res.send(response);
      });
    } catch (_error) {
      error = _error;
      errorMessage = error.message;
      return res.send(new Response(0, errorMessage));
    }
  };

  exports.removeDepartment = function(req, res) {
    var departmentId;
    if (!utils.authenticateAdmin(req, res)) {
      return;
    }
    departmentId = req.body.departmentId;
    return departmentModel.removeDepartment(departmentId, function(response) {
      return res.send(response);
    });
  };

  exports.updateDepartment = function(req, res) {
    var departmentId, departmentName, error, errorMessage, parentId;
    if (!utils.authenticateAdmin(req, res)) {
      return;
    }
    departmentId = req.body.departmentId;
    departmentName = req.body.departmentName;
    parentId = req.body.pid;
    try {
      check(departmentName, "部门名称不能为空").notEmpty().notContains(":");
      return departmentModel.updateDepartment(departmentId, departmentName, parentId, function(response) {
        return res.send(response);
      });
    } catch (_error) {
      error = _error;
      errorMessage = error.message;
      return res.send(new Response(0, errorMessage));
    }
  };

  exports.getAllDepartments = function(req, res) {
    return departmentModel.getAllDepartments(function(response) {
      return res.send(response);
    });
  };

}).call(this);

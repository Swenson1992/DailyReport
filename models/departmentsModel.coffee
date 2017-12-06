
{Response} = require('../vo/Response')
utils = require("../utils")

exports.createDepartment = (departmentName, parentId, callback) ->
  client = utils.createClient()

  client.incr("next_department_id", (err, reply)->
    return utils.showDBError(callback, client) if err

    client.hset("departments", "#{reply}:name", departmentName)
    result = {name:departmentName}

    #id 以字符串形式返回
    department = {name:departmentName, id:"#{reply}"}
    if parentId
      client.hset("departments", "#{reply}:pid", parentId)
      result["pid"] = parentId
      department["pid"] = parentId

    client.quit()

    callback(new Response(1,'success',department)))

#删除部门
exports.removeDepartment = (departmentId, callback) ->
  client = utils.createClient()
  client.hdel("departments", "#{departmentId}:name", "#{departmentId}:pid", (err, reply)->
    return utils.showDBError(callback, client) if err
    client.hgetall("departments", (err, reply)->
      return utils.showDBError(callback, client) if err
      newDepartments = {}
      for key, value of reply
        childOfKey = key.split(":")
        if childOfKey[1] == "pid" and value == departmentId
          client.hdel("departments", key)
        else
          newDepartments[key] = value

      client.hgetall("users", (err, users)->
        return utils.showDBError(callback, client) if err
        for key, value of users
          childOfKey = key.split(":")
          if childOfKey[1] == "department_id" and value == departmentId
            client.hdel("users", key)
        callback(new Response(1,'success',newDepartments)))))

#更新部门
exports.updateDepartment = (departmentId, departmentName, parentId, callback)->
  client = utils.createClient()

  replycallback =  (err, reply)->
    return utils.showDBError(callback, client) if err
    client.hgetall("departments", (err, reply)->
       client.quit()
       callback(new Response(1,'success',reply)))

  if parentId
    client.hmset("departments", "#{departmentId}:name", departmentName, "#{departmentId}:pid", parentId, replycallback)
  else
    client.hset("departments", "#{departmentId}:name", departmentName, replycallback)

exports.getAllDepartments = (callback) ->
  client = utils.createClient()
  client.hgetall("departments", (err, reply)->
    return utils.showDBError(callback, client) if err
    client.quit()
    callback(new Response(1,'success',reply)))
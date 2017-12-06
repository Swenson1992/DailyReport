
{Response} = require('../vo/Response')
utils = require("../utils")

exports.createUser = (userName, password, departmentId, superiorId, callback) ->
  client = utils.createClient()
  client.incr("next_user_id", (err, reply)->
    return utils.showDBError(callback, client) if err

    userId = "#{reply}"
    replycallback =  (err, reply)->
      return utils.showDBError(callback, client) if err
      client.quit()
      if superiorId
        data = {id: userId, userName:userName, departmentId:departmentId, superiorId:superiorId}
      else
        data = {id: userId, userName:userName, departmentId:departmentId}

      callback(new Response(1,'success',data))

    if superiorId
      client.hmset("users", "#{userId}:user_name", userName, "#{userId}:password", password, "#{userId}:department_id", departmentId, "#{userId}:superior_id", superiorId, replycallback)
    else
      client.hmset("users", "#{userId}:user_name", userName, "#{userId}:password", password, "#{userId}:department_id", departmentId, replycallback)
  )

#创建初始管理员账户
exports.createDefaultAdmin = (userName, password, callback) ->
  client = utils.createClient()
  client.incr("next_user_id", (err, nextUserId)->
    return utils.showDBError(callback, client) if err

    userId = "#{nextUserId}"
    client.hmset("users", "#{userId}:user_name", userName, "#{userId}:password", password, (err, reply)->
      client.sadd("administrators", userId, (err, reply)->
        return utils.showDBError(callback, client) if err
        client.quit()
        callback(new Response(1, "success",reply)))))

exports.updateUser = (userId, userName, password, departmentId, superiorId, callback) ->
  client = utils.createClient()

  replycallback =  (err, reply)->
    return utils.showDBError(callback, client) if err
    client.hgetall("users", (err, reply)->
      return utils.showDBError(callback, client) if err
      client.quit()
      users = getUsersWithoutPassword(reply)
      callback(new Response(1, "success",users)))

  if (superiorId and password)
    client.hmset("users", "#{userId}:user_name", userName, "#{userId}:password", password, "#{userId}:department_id", departmentId, "#{userId}:superior_id", superiorId, replycallback)
  else if superiorId
    client.hmset("users", "#{userId}:user_name", userName, "#{userId}:department_id", departmentId, "#{userId}:superior_id", superiorId, replycallback)
  else if password
    client.hmset("users", "#{userId}:user_name", userName, "#{userId}:password", password, "#{userId}:department_id", departmentId, replycallback)
  else
    client.hmset("users", "#{userId}:user_name", userName, "#{userId}:department_id", departmentId, replycallback)


exports.getAllUsers = (callback) ->
  client = utils.createClient()
  client.hgetall("users", (err, reply)->
    return utils.showDBError(callback, client) if err
    client.quit()
    users = getUsersWithoutPassword(reply)
    callback(new Response(1, "success",users)))

exports.getAllUsersWithPassword = (callback) ->
  client = utils.createClient()
  client.hgetall("users", (err, users)->
    return utils.showDBError(callback, client) if err
    client.quit()
    callback(new Response(1, "success",users)))

exports.removeUser = (userId, callback) ->
  client = utils.createClient()
  client.hdel("users", "#{userId}:user_name", "#{userId}:password", "#{userId}:department_id", "#{userId}:superior_id", (err, reply)->
    return utils.showDBError(callback, client) if err
    client.hgetall("users", (err, reply)->
      return utils.showDBError(callback, client) if err
      newUsers = getUsersWithoutPassword(reply)
      for key, value of newUsers
        childOfKey = key.split(":")
        if childOfKey[1] == "superior_id" and value == userId
          client.hdel("users", key)
        else
          newUsers[key] = value
      client.quit()

      callback(new Response(1, "success",newUsers))))

# 将用户数据中的密s码信息过滤掉
getUsersWithoutPassword = (users)->
  filterUsers = {}
  for key, value of users
    childOfKey = key.split(":")
    filterUsers[key] = value unless childOfKey[1] == "password"

  filterUsers

# 查看某个用户（userId）是否有下属
exports.hasSubordinate = (userId, callback) ->
  client = utils.createClient()
  client.hgetall("users", (err, users)->
    return utils.showDBError(callback, client) if err
    result = false
    for key, value of users
      childOfKey = key.split(":")
      if childOfKey[1] == "superior_id" and value == userId
        result = true
        break
    client.quit()
    callback(result))

# 获取所有管理员Id
exports.getAdminIds = (callback) ->
  client = utils.createClient()
  client.smembers("administrators", (err, ids)->
    return utils.showDBError(callback, client) if err
    client.quit()
    callback(new Response(1, "success",ids)))

exports.setAdmin = (userId, callback) ->
  client = utils.createClient()
  client.sadd("administrators", userId, (err, reply)->
    return utils.showDBError(callback, client) if err
    client.quit()
    callback(new Response(1, "success",reply)))

exports.deleteAdmin = (userId, callback) ->
  client = utils.createClient()
  client.srem("administrators", userId, (err, reply)->
    return utils.showDBError(callback, client) if err
    client.quit()
    callback(new Response(1, "success",reply)))

exports.hasUser = (userName, callback) ->
  client = utils.createClient()
  client.hgetall("users", (err, users)->
    return utils.showDBError(callback, client) if err
    result = false
    client.quit()
    for key, value of users
      [_,property] = key.split(":")
      if property == "user_name" and value == userName
        result = true
        break

    callback(new Response(1, "success",result)))

exports.changePassword = (userId, newPassword, oldPassword, callback) ->
  client = utils.createClient()
  client.hget("users", "#{userId}:password", (err, password)->
    return utils.showDBError(callback, client) if err
    if oldPassword == password
      client.hset("users", "#{userId}:password", newPassword, (err, password)->
        return utils.showDBError(callback, client) if err
        client.quit()
        callback(new Response(1, "success", 1)))
    else
      callback(new Response(1, "success", 0)))


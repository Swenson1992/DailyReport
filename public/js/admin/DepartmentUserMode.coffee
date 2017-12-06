
# department model层，处理数据调用和解析 ---------------------------------------------------------------
class DepartmemtModel

  @getAllDepartments: (callback)->
    $.get("/admin/alldepartments",
         (response)->
           if response.state == 1
             departments = DepartmemtModel.parseDepartments(response.data)
             response['data'] = departments
           callback(response)
         , "json")
  # data 后台返回数据  	Object { 1:name="PHP", 2:name="IOS", 3:name="p2", 3:pid="1"}
  # 输出数据 Object { 1:{id:1, name:"PHP"}, 2:{id:2, name:"ios"},3:{id:3, name:"p2", pid:"1"}}
  @parseDepartments: (data)->
    resultObj = {}
    for key, value of data
      childOfKey = key.split(":")
      departmentId = childOfKey[0]
      resultObj[departmentId] ?= {id: departmentId}
      if childOfKey[1] == "name"
        resultObj[departmentId]["name"] = value
      else if childOfKey[1] == "pid"
        resultObj[departmentId]["pid"] = value

    result = []
    for key2, value2 of resultObj
      result.push(value2)

    # h该函数输出数据 [{id:1, name:"PHP"}, {id:2, name:"ios"},{id:3, name:"p2", pid:"1"}]
    result

  @createNewDepartment: (data, callback)->
    $.post("/admin/createDepartment", data,
          (response)->
            callback(response)
          , "json")

  @updateDepartment: (data, callback)->
    $.post("/admin/updatedepartment", data,
          (response)->
            if response.state == 1
              departments = DepartmemtModel.parseDepartments(response.data)
              response['data'] = departments
            callback(response)
          , "json")

  @removeDepartment: (data, callback)->
    $.post("/admin/removedepartment", data,(response)->
      if response.state == 1
        departments = DepartmemtModel.parseDepartments(response.data)
        response.data = departments
      callback(response)
    , "json")

window.DepartmemtModel = DepartmemtModel

# user model层，处理数据调用和解析 ---------------------------------------------------------------
class UserModel

  @setAdministrator: (userId, callback)->
    $.post("/admin/setadmin", {userId:userId}, (response)->
      callback(response)
    , "json")

  @deleteAdministrator: (userId, callback)->
    $.post("/admin/deleteadmin", {userId:userId}, (response)->
      callback(response)
    , "json")

  @getAdmins: (callback)->
    $.post("/admin/getadmins", (response)->
      callback(response)
    , "json")

  @hasUser: (userName, callback)->
    $.post("/admin/hasuser", {userName:userName}, (response)->
      callback(response)
    , "json")

  @login: (data, callback)->
    $.post("/login", data, (response)->
      callback(response)
    , "json")

  @createUser: (data, callback)->
    $.post("/admin/createuser", data, (response)->
      if response.state == 1
        user = response.data
        user["name"] = user["userName"]
        delete user["userName"]
        if user["superiorId"]
          user["pid"] = user["superiorId"]
          delete user["superiorId"]
        response.data = user
        UserModel.allUsers.push(user)
      callback(response)
    , "json")

  @updateUser: (data, callback)->
    $.post("/admin/updateuser", data, (response)->
      if response.state == 1
        users = UserModel.parseUsers(response.data)
        response.data = users
        UserModel.allUsers = users
      callback(response)
    ,"json")

  @changePassword: (data, callback)->
    $.post("/password", data, (response)->
      if response.state == 1
        callback(response)
    ,"json")

  @removeUser: (data, callback)->
    $.post("/admin/removeuser", data, (response)->
      if response.state == 1
        users = UserModel.parseUsers(response.data)
        response.data = users
        UserModel.allUsers = users
      callback(response)
    ,"json")

  @getAllUsers: (callback)->
    $.get("/admin/getallusers",(response)->
      if response.state == 1
        users = UserModel.parseUsers(response.data)
        response.data = users
        UserModel.allUsers = users
      callback(response)
    , "json")

  @allUsers: []

  @getLocalAllUsers: ->
    @allUsers

  # data 后台返回数据  	Object { 1:user_name="walter", 1:department_id="7", 1:superior_id:"3"}
  @parseUsers: (data)->

    resultObj = {} #Object { 1:{id:1, name:"walter",pid:"3", departmentId:"7"}}
    for key, value of data
      childOfKey = key.split(":")
      userId = childOfKey[0]
      resultObj[userId] ?= {id: userId}
      if childOfKey[1] == "user_name"
        resultObj[userId]["name"] = value
      else if childOfKey[1] == "department_id"
        resultObj[userId]["departmentId"] = value
      else if childOfKey[1] == "superior_id"
        resultObj[userId]["pid"] = value

    result = []
    for key2, value2 of resultObj
      result.push(value2)

    # h该函数输出数据 [{id:1, name:"walter",pid:"3", departmentId:"7"}]
    result

window.UserModel = UserModel
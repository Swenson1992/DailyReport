
#  -----------------------------------------------------------------------------------------------
AdminGroupViewModel = ->
  self = @

  self.departments = ko.observableArray([])
  self.selectedDepartment = ko.observable(null)

  self.users = ko.observableArray([])
  self.selectedUser = ko.observable(null)

  self.admins = ko.observableArray([])

  self.valid = ko.computed(->
    self.selectedDepartment() and self.selectedUser())

  self.submit = ->
    console.log  "fail: 必须选择一个成员" unless self.valid()
    user = self.selectedUser()
    UserModel.setAdministrator(user["id"], (response)->
      return if response.state == 0
      self.admins.push(user))

  self


# 初始化 ----------------------------------------------------------------------------
init = ->
  adminvm = new AdminGroupViewModel()
  ko.applyBindings(adminvm)

  DepartmemtModel.getAllDepartments((response)->
    adminvm.departments(response.data))

  UserModel.getAllUsers((response)->
    return if response.state == 0

    users = response.data
    UserModel.getAdmins((response)->
      return if response.state == 0
      adminIds = response.data
      admins = getAdmins(users, adminIds)
      adminvm.admins(admins))
    null)

  getAdmins = (allUsers, adminIds)->
    result = []
    for adminId in adminIds
      for user in allUsers
        if adminId == user["id"]
          result.push(user)
          break
    result

  $("#depar").change( ->
    departmentId = adminvm.selectedDepartment()?['id']
    users = UserModel.getLocalAllUsers()
    departmentUsers = getUsersByDepartmentId(departmentId, users)
    adminvm.users(departmentUsers)
    admins = adminvm.admins()
    #从部门成员中移除管理员
    for admin in admins
      for user in users
        if user["id"] == admin["id"]
          adminvm.users.remove(user)
          break
    )

  #根据部门Id获取该部门所有成员
  getUsersByDepartmentId = (departmentId, allUsers)->
    result = []
    return result unless departmentId

    for user in allUsers
      result.push(user) if departmentId == user["departmentId"]
    result

  $("#adminlist").on("click", "a.delete", (event)->
    userId = $(@).attr("userid")
    confirm(userId))

  deleteAdmin = (userId)->
    UserModel.deleteAdministrator(userId, (response)->
      return if response.state == 0
      admins = adminvm.admins()
      for admin in admins
        return adminvm.admins.remove(admin) if admin["id"] == userId)

  confirm = (userId)->
    $("#dialog-confirm").dialog({
      dialogClass: "no-close",
      resizable: false,
      height:160,
      modal: true,
      buttons: {
        "删除": ->
          deleteAdmin(userId)
          $(@).dialog("close")
        Cancel: ->
          $(this).dialog("close")}})

  $("#adminlist").on("mouseenter", "li", (event)->
     $(@).addClass('itemOver'))

  $("#adminlist").on("mouseleave", "li", (event)->
    $(@).removeClass('itemOver'))

init()
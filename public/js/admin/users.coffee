treeList = new TreeList("#usersTree")

#  -----------------------------------------------------------------------------------------------
UserViewModel = ->
  self = @
  self.userName = ko.observable('')
  self.password = ko.observable('1234567')
  self.repassword = ko.observable('1234567')
  self.validUserName = ko.computed(->
    un = $.trim(self.userName())
    un.length >= 6 and un.length<=25)

  self.validPassword = ko.computed(->
    pw = $.trim(self.password())
    pw.length >= 7 and pw.length<=25)

  self.validRePassword = ko.computed(->
    $.trim(self.password()) ==  $.trim(self.repassword()))

  self.departments = ko.observableArray([])
  self.selectedDepartment = ko.observable(null)

  self.superiors = ko.observableArray([])
  self.selectedSuperior = ko.observable(null)

  self.valid = ko.computed(->
    self.selectedDepartment()? and self.validUserName() and self.validPassword() and self.validRePassword())

  self.submit = ->
    if self.valid()
      data = {userName: $.trim(self.userName()), password:$.trim(self.password()),
      departmentId:self.selectedDepartment()?["id"], superiorId:self.selectedSuperior()?["id"]}
      UserModel.createUser(data, (response)->
        return if response.state == 0
        newUser = response.data
        self.superiors.push(newUser)
        treeList.show(UserModel.getLocalAllUsers(), "user"))
    else
      console.log("creation fail.")

  self.updateUser = ko.observable(null)

  self.userName1 = ko.observable('')
  self.password1 = ko.observable('')
  self.repassword1 = ko.observable('')
  self.validUserName1 = ko.computed(->
    un = $.trim(self.userName1())
    un.length >= 2 and un.length<=25)

  self.validPassword1 = ko.computed(->
    pw = $.trim(self.password1())
    pw.length >= 7 and pw.length<=25)

  self.validRePassword1 = ko.computed(->
    $.trim(self.password1()) ==  $.trim(self.repassword1()))

  self.selectedDepartment1 = ko.observable(null)

  self.superiors1 = ko.observableArray([])
  self.selectedSuperior1 = ko.observable(null)

  self.valid1 = ko.computed(->
    result = self.selectedDepartment1()? and self.validUserName1() and self.validRePassword1()
    if self.password1()
      result = result and self.validPassword1()

    result)

  #输入的用户名已经存在
  self.hasUser = ko.observable(false)
  self.oldUserName = ""

  self.showHasUserTip = ko.computed(->
    return false if !self.validUserName()
    self.hasUser())

  self.checkUserExit = ->
    return  if self.oldUserName == self.userName()
    self.oldUserName = self.userName()
    return self.hasUser(false) unless self.validUserName()
    UserModel.hasUser(self.userName(), (response)->
      return if response.state == 0
      self.hasUser(response.data))

  self


# 初始化 ----------------------------------------------------------------------------
init = ->
  uservm = new UserViewModel()
  ko.applyBindings(uservm)

  DepartmemtModel.getAllDepartments((response)->
    uservm.departments(response.data))

  UserModel.getAllUsers((response)->
    return if response.state == 0
    users = response.data
    treeList.show(users, "user"))

  $("#usersTree").on("delete", (event)->
    userId = event["itemId"]
    confirm(userId))

  deleteUser = (userId)->
    UserModel.removeUser({userId:userId}, (response)->
      return if response.state == 0
      treeList.show(response["data"], "user"))

  $("#userDepartment").change( ->
    departmentId = uservm.selectedDepartment()?['id']
    setSuperiorsByDepartmentId(departmentId))

  setSuperiorsByDepartmentId = (departmentId)->
    if departmentId
      users = UserModel.getLocalAllUsers()
      superiors = getUsersAndSuperiosByDepartmentId(departmentId, users, uservm.departments())
      setSuperiors(superiors)
    else
      setSuperiors([])

  setSuperiors = (superiors)->
     if isEditing()
       uservm.superiors1(superiors)
     else
       uservm.superiors(superiors)

  isEditing = ->
    result = false
    result = true if uservm.updateUser()
    return result

  #根据部门Id获取该部门和上级部门所有成员
  getUsersAndSuperiosByDepartmentId = (departmentId, allUsers, allDepartments)->
    result = getUsersByDepartmentId(departmentId, allUsers)
    for department in allDepartments
      if departmentId == department["id"]
        pid =  department["pid"]
        pusers = getUsersByDepartmentId(pid, allUsers)
        return result.concat(pusers)

  #根据部门Id获取该部门所有成员
  getUsersByDepartmentId = (departmentId, allUsers)->
    result = []
    return result unless departmentId

    for user in allUsers
      result.push(user) if departmentId == user["departmentId"]
    result

  #设置用户编辑界面状态
  $("#usersTree").on("update", (event)->
    userId = event["itemId"]
    user =  finduser(userId)
    uservm.updateUser(user)
    uservm.userName1(user["name"])
    selectedDepartment = getDepartmentByUserId(userId, UserModel.getLocalAllUsers(), uservm.departments())
    uservm.selectedDepartment1(selectedDepartment)
    setSuperiorsByDepartmentId(selectedDepartment["id"])
    superiors = uservm.superiors1()
    return unless user["pid"]

    for superior in superiors
      if superior["id"] == user["pid"]
        uservm.selectedSuperior1(superior)
        return)

  finduser = (userId)->
    users = UserModel.getLocalAllUsers()
    for user in users
      if (user['id'] == userId)
        return user

  #根据用户Id获取该用户所在部门
  getDepartmentByUserId = (userId, allUsers, departments)->
    allUsers = UserModel.getLocalAllUsers()
    departmentId = null
    for user in allUsers
      if userId == user["id"]
        departmentId = user["departmentId"]
        break
    for department in departments
      return department if department["id"] == departmentId
    null

  #取消更新
  $("#cancelBtn").click( ->
    cancelUpdate())

  cancelUpdate = ->
    treeList.showEditingItem()
    uservm.updateUser(null)

  $("#updateBtn").click( ->
    if uservm.valid1()
      data = {userId:uservm.updateUser()["id"] ,userName: $.trim(uservm.userName1()), password:$.trim(uservm.password1()),
      departmentId:uservm.selectedDepartment1()?["id"], superiorId:uservm.selectedSuperior1()?["id"]}
      UserModel.updateUser(data, (response)->
        return if response.state == 0
        setSuperiorsByDepartmentId(uservm.selectedDepartment["id"])
        cancelUpdate()
        treeList.show(UserModel.getLocalAllUsers(), "user"))
    else
      console.log "valid fail")

  confirm = (userId)->
    $("#dialog-confirm").dialog({
      dialogClass: "no-close",
      resizable: false,
      height:160,
      modal: true,
      buttons: {
        "删除": ->
          deleteUser(userId)
          $(@).dialog("close")
        Cancel: ->
          $(this).dialog("close")}})


init()
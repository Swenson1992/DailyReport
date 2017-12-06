#  -----------------------------------------------------------------------------------------------
PasswordViewModel = ->
  self = @

  validPassword = (password)->
    pw = $.trim(password)
    pw.length >= 7 and pw.length<=25

  self.oldpassword = ko.observable('')
  self.newpassword = ko.observable('')
  self.renewpassword = ko.observable('')

  self.validOldPassword = ko.computed(->
    validPassword(self.oldpassword()))

  self.validNewPassword = ko.computed(->
    validPassword(self.newpassword()))

  self.validRePassword = ko.computed(->
    $.trim(self.newpassword()) ==  $.trim(self.renewpassword()))

  self.valid = ko.computed(->
    self.validOldPassword() and self.validNewPassword() and self.validRePassword())

  self.submit = ->
    if self.valid()
      data = {newPassword: $.trim(self.newpassword()), oldPassword: $.trim(self.oldpassword())}
      UserModel.changePassword(data, (response)->
        return if response.state == 0
        if response.data == 1
          self.oldpassword('')
          self.newpassword('')
          self.renewpassword('')
          $("#successTip").css("display","block")
          $("#passwordErrorTip").css("display","none")
        else
          $("#passwordErrorTip").css("display","block")
          $("#successTip").css("display","none")
        )
    else
      console.log("creation fail.")

  self


# 初始化 ----------------------------------------------------------------------------
init = ->
  passwordvm = new PasswordViewModel()
  ko.applyBindings(passwordvm)

init()
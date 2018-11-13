// Generated by CoffeeScript 1.6.1
(function() {
  var AdminGroupViewModel, init;

  AdminGroupViewModel = function() {
    var self;
    self = this;
    self.departments = ko.observableArray([]);
    self.selectedDepartment = ko.observable(null);
    self.users = ko.observableArray([]);
    self.selectedUser = ko.observable(null);
    self.admins = ko.observableArray([]);
    self.valid = ko.computed(function() {
      return self.selectedDepartment() && self.selectedUser();
    });
    self.submit = function() {
      var user;
      if (!self.valid()) {
        console.log("fail: 必须选择一个成员");
      }
      user = self.selectedUser();
      return UserModel.setAdministrator(user["id"], function(response) {
        if (response.state === 0) {
          return;
        }
        return self.admins.push(user);
      });
    };
    return self;
  };

  init = function() {
    var adminvm, confirm, deleteAdmin, getAdmins, getUsersByDepartmentId;
    adminvm = new AdminGroupViewModel();
    ko.applyBindings(adminvm);
    DepartmemtModel.getAllDepartments(function(response) {
      return adminvm.departments(response.data);
    });
    UserModel.getAllUsers(function(response) {
      var users;
      if (response.state === 0) {
        return;
      }
      users = response.data;
      UserModel.getAdmins(function(response) {
        var adminIds, admins;
        if (response.state === 0) {
          return;
        }
        adminIds = response.data;
        admins = getAdmins(users, adminIds);
        return adminvm.admins(admins);
      });
      return null;
    });
    getAdmins = function(allUsers, adminIds) {
      var adminId, result, user, _i, _j, _len, _len1;
      result = [];
      for (_i = 0, _len = adminIds.length; _i < _len; _i++) {
        adminId = adminIds[_i];
        for (_j = 0, _len1 = allUsers.length; _j < _len1; _j++) {
          user = allUsers[_j];
          if (adminId === user["id"]) {
            result.push(user);
            break;
          }
        }
      }
      return result;
    };
    $("#depar").change(function() {
      var admin, admins, departmentId, departmentUsers, user, users, _i, _len, _ref, _results;
      departmentId = (_ref = adminvm.selectedDepartment()) != null ? _ref['id'] : void 0;
      users = UserModel.getLocalAllUsers();
      departmentUsers = getUsersByDepartmentId(departmentId, users);
      adminvm.users(departmentUsers);
      admins = adminvm.admins();
      _results = [];
      for (_i = 0, _len = admins.length; _i < _len; _i++) {
        admin = admins[_i];
        _results.push((function() {
          var _j, _len1, _results1;
          _results1 = [];
          for (_j = 0, _len1 = users.length; _j < _len1; _j++) {
            user = users[_j];
            if (user["id"] === admin["id"]) {
              adminvm.users.remove(user);
              break;
            } else {
              _results1.push(void 0);
            }
          }
          return _results1;
        })());
      }
      return _results;
    });
    getUsersByDepartmentId = function(departmentId, allUsers) {
      var result, user, _i, _len;
      result = [];
      if (!departmentId) {
        return result;
      }
      for (_i = 0, _len = allUsers.length; _i < _len; _i++) {
        user = allUsers[_i];
        if (departmentId === user["departmentId"]) {
          result.push(user);
        }
      }
      return result;
    };
    $("#adminlist").on("click", "a.delete", function(event) {
      var userId;
      userId = $(this).attr("userid");
      return confirm(userId);
    });
    deleteAdmin = function(userId) {
      return UserModel.deleteAdministrator(userId, function(response) {
        var admin, admins, _i, _len;
        if (response.state === 0) {
          return;
        }
        admins = adminvm.admins();
        for (_i = 0, _len = admins.length; _i < _len; _i++) {
          admin = admins[_i];
          if (admin["id"] === userId) {
            return adminvm.admins.remove(admin);
          }
        }
      });
    };
    confirm = function(userId) {
      return $("#dialog-confirm").dialog({
        dialogClass: "no-close",
        resizable: false,
        height: 160,
        modal: true,
        buttons: {
          "删除": function() {
            deleteAdmin(userId);
            return $(this).dialog("close");
          },
          Cancel: function() {
            return $(this).dialog("close");
          }
        }
      });
    };
    $("#adminlist").on("mouseenter", "li", function(event) {
      return $(this).addClass('itemOver');
    });
    return $("#adminlist").on("mouseleave", "li", function(event) {
      return $(this).removeClass('itemOver');
    });
  };

  init();

}).call(this);
treeList = new TreeList2("#userTree")

ReportModel.getSubordinateUserAndDepartment((response)->
  return if response.state == 0
  treeData = response.data
  treeList.renderTree("#userTree", treeData))

#设置用户编辑界面状态
$("#userTree").on("review", (event)->
  userId = event["itemId"]
  initPageState()
  reportvm.userId(userId)
  getReports(userId)
  getReportNum(userId))

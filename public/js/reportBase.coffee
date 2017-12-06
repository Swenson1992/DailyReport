
# ViewModel---------------------------------------------------------------
ShowReportsViewModel = ->
  self = @
  self.reports = ko.observableArray([])
  self.reportNum = ko.observable(0)
  self.userId = ko.observable(null)
  self.pageNum = ko.computed(->
    pageNum = Math.ceil(self.reportNum() / NUMOFPAGE)
    pageNum = 1 if pageNum == 0
    pageNum)

  self.currentPage = ko.observable(1)

  self

# 初始化 ---------------------------------------------------------------

# 每页显示的日报条数
NUMOFPAGE = 4

getReports = (userId=null)->
  data = {page:reportvm.currentPage(), numOfPage:NUMOFPAGE, userId:userId}
  ReportModel.getReports(data, (response)->
    return if response.state == 0
    reportvm.reports(response.data))

getReportNum = (userId=null)->
  ReportModel.getReportNum(userId, (response)->
    return if response.state == 0
    reportvm.reportNum(response.data))

window.initPageState = ->
  reportvm.reports([])
  reportvm.reportNum(0)
  reportvm.userId(null)


reportvm = new ShowReportsViewModel()
ko.applyBindings(reportvm)

window.getReports = getReports
window.getReportNum = getReportNum
window.reportvm = reportvm

#翻页组件---------------------------------------
$("div.pagination").on("click", "button.pageNext", ->
  gotoPage(reportvm.currentPage()+1)
  false)

$("div.pagination").on("click", "button.pagePre", ->
  gotoPage(reportvm.currentPage()-1)
  false)

window.gotoPage = (page)->
  reportvm.currentPage(page)
  getReports(reportvm.userId())
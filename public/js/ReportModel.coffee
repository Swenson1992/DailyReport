# report model层，处理数据调用和解析 ---------------------------------------------------------------
class ReportModel

  @createReport: (data, callback)->
    $.post("/write", data, (response)->
      callback(response)
    , "json")

  @deleteReport: (data, callback)->
    $.post("/delete", data, (response)->
      callback(response)
    , "json")

  @getReportNum: (userId, callback)->
    $.post("/getreportnum", {userId:userId}, (response)->
      callback(response)
    , "json")

  @getSubordinateUserAndDepartment: (callback)->
    $.post("/getsubordinateuseranddepartment",(response)->
      callback(response)
    , "json")

  #返回数据格式为[ { date: '2013-4-30',cotent: '<p><br /></p>4.30 reports' },{ date: '2013-4-30',content: '4.30 reports' }]
  @getReports: (data, callback)->
    $.post("/getreports", data, (response)->
      callback(response)
    , "json")

window.ReportModel = ReportModel
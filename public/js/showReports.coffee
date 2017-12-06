
getReports()
getReportNum()

confirm = (reportId)->
  $("#dialog-confirm").dialog({
    dialogClass: "no-close",
    resizable: false,
    height:160,
    modal: true,
    buttons: {
      "删除": ->
        deleteReport(reportId)
        $(@).dialog("close")
      Cancel: ->
        $(this).dialog("close")}})

$("#reportList").on("click", "p.delete", ->
  reportId = $(this).attr("reportId")
  confirm(reportId))


deleteReport = (reportId)->
  ReportModel.deleteReport({reportId:reportId}, (response)->
    return if response.state == 0

    reportvm.reportNum(reportvm.reportNum()-1)
    page = reportvm.currentPage()
    if (reportvm.reports().length == 1 &&  reportvm.currentPage() > 1)
      page = reportvm.currentPage() - 1
    gotoPage(page))

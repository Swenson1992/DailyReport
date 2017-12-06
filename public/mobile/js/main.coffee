loginPageShowed = false
passwordPageShowed = false
writePageShowed = false
showPageShowed = false
subordinatePageShowed = false
showPageListenerHandlerInited = false
self = @

init = ->
  if window.mobileInitFinished
    return
  window.mobileInitFinished = true
  console.log "mobile init."

  $("body").on("pageshow","#logoutPage", (e)->
    Model.logout((response)->
      #console.log response
      return if response.state == 0
      #console.log "logout page."
      $.mobile.changePage("/m/login"))
  )

  $("body").on("pageshow","#loginPage", (e)->
    #console.log "login page show"

    #防止事件多次注册，导致事件函数执行多遍
    return if loginPageShowed
    loginPageShowed = true
    $("#loginSubmitBtn").on("click", ->
      if isValidLoginUser()
         data = {userName: $.trim($("#userName").val()), password: $.trim($("#password").val())}
         Model.login(data, (response)->
           return if response.state == 0
           if response.data == 0
             $.mobile.changePage("#loginErrorPage", { role: "dialog" })
           if response.data == 1
             $.mobile.changePage("write"))
      else
        $.mobile.changePage("#loginErrorPage", { role: "dialog" } )
    )
  )

  $("body").on("pageshow","#passwordPage", (e)->
    #console.log "password page show"

    #防止事件多次注册，导致事件函数执行多遍
    return if passwordPageShowed
    passwordPageShowed = true

    $("#passwordSubmitBtn").on("click", ->
      [isvalid, errorMessage] = isValidPassword()
      if isvalid
        oldPassword = $.trim($("#oldPassword").val())
        password = $.trim($("#password").val())
        data = {newPassword: password, oldPassword: oldPassword}
        Model.changePassword(data, (response)->
          return if response.state == 0

          if response.data == 1
            $.trim($("#oldPassword").val(""))
            $.trim($("#password").val(""))
            $.trim($("#repassword").val(""))
            showPasswordResultTip("恭喜，修改密码成功！")
          else
            $.trim($("#oldPassword").val(""))
            showPasswordResultTip("老密码输入错误，请重新输入老密码！")
          )
      else
        showPasswordResultTip(errorMessage)
    )
  )

  $("body").on("pageshow","#writePage",(e)->
    #console.log "write page show"
    #dateStr =  getDateStr(new Date())
    #$("#dateTxt").val(dateStr)
    #$("#content ").attr("value", dateStr)
    #alert $("#dateTxt").attr("value")
    #alert dateStr
    return if writePageShowed
    writePageShowed = true
    $("#reportSubmitBtn").on("click", ->
      if isValidDate()
        dateStr = $.trim($("#dateTxt").val())
        contentStr = $.trim($("#content").val())
        data = {date:dateStr, content:contentStr}
        Model.createReport(data, (response)->
          return if response.state == 0
          window.location.href = "/m/show")
      else
        $.mobile.changePage("#writeErrorPage", { role: "dialog" }))
  )

  initShowPageListenerHandler = ->
    unless self.showPageListenerHandlerInited
      self.showPageListenerHandlerInited = true
      $("#reportList").on("taphold","li",(e)->
        reportId = $(this).attr('reportId')
        $("#deleteReportBtn").attr("reportId", reportId)
        $("#deleteReportMenu").popup()
        $("#deleteReportMenu").popup('open')
        )

      $("#deleteReportMenu").on("click","#deleteReportBtn",(e)->
        reportId = $(this).attr('reportId')
        deleteReport(reportId)
        $("#deleteReportMenu").popup('close'))

      $("#deleteReportMenu").on("click","#cancelDeleteReportBtn",(e)->
        $("#deleteReportMenu").popup('close'))

      $("body").on("click","div.pageination div.pagePre",(e)->
        currentPage -= 1
        setPageState()
        getReports())

      $("body").on("click","div.pageination div.pageNext",(e)->
        console.log "pageNext"
        currentPage += 1
        setPageState()
        getReports())

  $("body").on("pageshow","#showPage",(e)->
    #console.log "show page show"
    initPageInfo()
    getReports()
    getReportNum()
    return if showPageShowed
    showPageShowed = true
    initShowPageListenerHandler()
  )

  $("body").on("pageshow","#subordinatePage",(e)->
    #console.log "subordinate page show"
    self.treeData = []
    $("#subordinatePage a.headerBack").css("display", "none")
    $("#subordinatePage h1").empty()
    $("#subordinatePage h1").append("下属日报")
    getSubordinateUserAndDepartment()

    return if subordinatePageShowed
    subordinatePageShowed = true
    initShowPageListenerHandler()
    $("#subordinatePage a.headerBack").click(->
      self.treeData.pop()
      renderSubordinate(self.treeData[self.treeData.length-1], "#subordinatePage div.subordinate")
      $("#subordinatePage h1").empty()
      $("#subordinatePage h1").append($(@).attr("nodeName"))
      if self.treeData.length == 1
        $("#subordinatePage a.headerBack").css("display", "none")
        $("#subordinatePage h1").empty()
        $("#subordinatePage h1").append("下属日报")
      )
    )


# Login ----------------------------------------------------------------
isValidLoginUser = ->
  un = $.trim($("#userName").val())
  pw = $.trim($("#password").val())
  un.length >= 2 and un.length<=25 and pw.length >= 7 and pw.length<=25

# change password ----------------------------------------------------------------
showPasswordResultTip = (message)->
  $("#passwordErrorPage p.content").empty()
  $("#passwordErrorPage p.content").append(message)
  $.mobile.changePage("#passwordErrorPage", { role: "dialog" } )

isValidPassword = ->
  result1 = true
  result2 = ""

  oldPassword = $.trim($("#oldPassword").val())
  password = $.trim($("#password").val())
  repassword = $.trim($("#repassword").val())

  if oldPassword.length < 7 or oldPassword.length > 25
    result1 = false
    result2 = "密码长度是7-25个字符"
    return [result1, result2]

  if password.length < 7 or  password.length > 25
    result1 = false
    result2 = "密码长度是7-25个字符"
    return [result1, result2]

  if password == oldPassword
    result1 = false
    result2 = "新密码和老密码相同，请输入一个不同的新密码"
    return [result1, result2]

  if password != repassword
    result1 = false
    result2 = "两次输入的新密码不一致"
    return [result1, result2]

  return [result1, result2]

# write -----------------------------------------------------------------
getDateStr = (date)->
  today = new Date()
  year = date.getFullYear()
  month = date.getMonth() + 1
  date = date.getDate()
  return "#{year}-#{month}-#{date}"

validator = new Validator()

isValidDate = ->
  dateStr = $.trim($("#dateTxt").val())
  contentStr = $.trim($("#content").val())
  try
    validator.check(contentStr).notEmpty()
    validator.check(dateStr).notEmpty()
    [year, months, date] = dateStr.split("-")
    #console.log "#{year}-#{months}-#{date}"
    validator.check(year).notNull().isNumeric().len(4,4)
    validator.check(months).notNull().isNumeric().len(1,2)
    validator.check(date).notNull().isNumeric().len(1,2)
    return true
  catch  error
    return false

# show -----------------------------------------------------------------
# 每页显示的日报条数
NUMOFPAGE = 6
reports = []
reportTotalNum = 0
pageNum = 0
currentPage = 1
reportUserId = null
isFirstGetReports = true

initPageInfo = ->
  reports = []
  reportTotalNum = 0
  pageNum = 0
  currentPage = 1
  reportUserId = null

getReports = ()->
  data = {page:currentPage, numOfPage:NUMOFPAGE, userId:reportUserId}
  Model.getReports(data, (response)->
    return if response.state == 0
    reports = []
    $("#reportList ul").empty()
    for report in response.data
      reports.push(report)
      reportHTML = "<li class='report' reportId='#{report.id}'><p class='date'><i class='icon-calendar'></i><span>#{report.date}</span></p>
                  <div class='content'>#{report.content}</div></li>"
      $("#reportList ul").append(reportHTML)
      setTimeout(showPageination, 1000))

showPageination = ->
  $("div.pageination").css("opacity", 1)

deleteReport = (reportId)->
  Model.deleteReport({reportId:reportId}, (response)->
    return if response.state == 0
    reportTotalNum -= 1
    if (reports.length == 1 &&  currentPage > 1)  #非第一页并且只有一条日报(这条日报被删了，嘿嘿)
      currentPage -= 1
    setPageState()
    getReports())

getReportNum = ()->
  Model.getReportNum(reportUserId, (response)->
    if response.state == 1
      reportTotalNum = response.data
      setPageState())

setPageState = ->
  pageNum = Math.ceil(reportTotalNum / NUMOFPAGE)
  pageNum = 1 if pageNum == 0
  $("div.pagetip").empty()
  $("div.pagetip").append("#{currentPage}/#{pageNum}")

  if pageNum == 1
    $("div.pageination").hide()
  else if currentPage == 1
    $("div.pageination").show()
    $("div.pagePre").hide()
    $("div.pageNext").show()
  else if currentPage == pageNum
    $("div.pageination").show()
    $("div.pagePre").show()
    $("div.pageNext").hide()
  else
    $("div.pageination").show()
    $("div.pagePre").show()
    $("div.pageNext").show()

# subordinate -----------------------------------------------------------------
subordinateUserAndDepartments = null
getSubordinateUserAndDepartment = ->
  Model.getSubordinateUserAndDepartment((response)->
    return if response.state == 0
    subordinateUserAndDepartments = response.data
    renderSubordinate(subordinateUserAndDepartments, "#subordinatePage div.subordinate", true))


self.treeData = []

renderSubordinate = (data, nodeContainer, pushStack=false)->
  $(nodeContainer).empty()
  $(nodeContainer).append("<ul class='root' data-role='listview' data-theme='b' data-inset='true' data-filter='true'></ul>")
  treeNodeData = []
  node = "#{nodeContainer} ul.root"
  for nodeData in data
    treeNodeData.push(nodeData)
    if nodeData.children
      $(node).append("<li id='#{nodeData.id}-node' nodeName='#{nodeData.label}' onclick='clickNode(event)'><a href='#'>#{nodeData.label}</a></li>")
    else
      $(node).append("<li id='#{nodeData.id}-node' nodeName='#{nodeData.label}' onclick='showUserReport(event)'><a href='#'>#{nodeData.label}</a></li>")
  treeData.push(treeNodeData) if pushStack
  $("#{nodeContainer} ul.root").listview()


window.clickNode = (event)->
  [id, _] = $(event.currentTarget).attr("id").split("-")
  nodeName = $(event.currentTarget).attr("nodeName")
  $("#subordinatePage a.headerBack").css("display", "inline")
  $("#subordinatePage a.headerBack").attr("nodeName", nodeName)
  $("#subordinatePage h1").empty()
  getChildNodeById(subordinateUserAndDepartments, id)

getChildNodeById = (dataSource, id)->
  for nodeData in dataSource
    if nodeData.id == id
      $("#subordinatePage h1").append(nodeData.label)
      renderSubordinate(nodeData.children, "#subordinatePage div.subordinate", true)
      return
    if nodeData.children
      getChildNodeById(nodeData.children, id)

window.showUserReport = (event)->
  [id, _] = $(event.currentTarget).attr("id").split("-")
  label = $(event.currentTarget).attr("nodeName")
  $("#subordinatePage div.subordinate").empty()
  $("#subordinatePage div.subordinate").append('<article id="reportList" >
                                                           <ul></ul>
                                                       </article>
                                                       <div class="ui-grid-d pageination" >
                                                           <div class="ui-block-a aligncenter" title="前一页"><div class="pagePre" ><button data-icon="arrow-l" data-iconpos="notext" data-inline="true"></button></div></div>
                                                           <div class="ui-block-b"></div>
                                                           <div class="ui-block-c pagetip">1/1</div>
                                                           <div class="ui-block-d"></div>
                                                           <div class="ui-block-e aligncenter" title="下一页"><div class="pageNext" ><button data-icon="arrow-r" data-iconpos="notext" data-inline="true"></button></div></div>
                                                       </div>')
  $("#subordinatePage h1").empty()
  $("#subordinatePage h1").append("#{label}的日报")
  $("#subordinatePage a.headerBack").css("display", "inline")
  $("#subordinatePage div.pagePre button").button()
  $("#subordinatePage div.pageNext button").button()
  treeData.push(label)
  initPageInfo()
  reportUserId = id
  getReports()
  getReportNum()

window.init = init
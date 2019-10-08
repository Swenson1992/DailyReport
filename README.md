## Daily Report 日报管理工具

写日报工具，该工具简单易用，包含网页和手机版。使用该日报工具可以随时随地使用手机或者电脑写和浏览日报.
提供小团队的日报工具,发现问题请提交issue,看到会第一时间回复修正~~共勉.

详细的说明,请参考[Daily Report安装说明](https://songjian925.github.io/DailyReport/)

### 目录说明
```
工程目录
├── README.md
├── ReportServe
├── app.js
├── changelog.md
├── changelog.sh
├── config.coffee
├── config.js
├── controlers
│   ├── adminCtr.coffee
│   ├── adminCtr.js
│   ├── departmentCtr.coffee
│   ├── departmentCtr.js
│   ├── installCtr.coffee
│   ├── installCtr.js
│   ├── reportCtr.coffee
│   ├── reportCtr.js
│   ├── userCtr.coffee
│   └── userCtr.js
├── dailyReportServer
├── models
│   ├── departmentsModel.coffee
│   ├── departmentsModel.js
│   ├── reportModel.coffee
│   ├── reportModel.js
│   ├── usersModel.coffee
│   └── usersModel.js
├── other&this
│   └── db-info.md
├── package.json
├── routes
│   ├── routeProfile.coffee
│   └── routeProfile.js
├── utils.coffee
├── utils.js
├── views
│   ├── admin
│   │   ├── admingroup.hbs
│   │   ├── department.hbs
│   │   └── users.hbs
│   ├── install.hbs
│   ├── login.hbs
│   ├── mobile
│   │   ├── layout.hbs
│   │   ├── login.hbs
│   │   ├── password.hbs
│   │   ├── show.hbs
│   │   ├── showsubordinate.hbs
│   │   └── write.hbs
│   ├── password.hbs
│   ├── show.hbs
│   ├── showsubordinate.hbs
│   └── write.hbs
└── vo
    ├── Response.coffee
    └── Response.js

```
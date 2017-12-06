安装redis数据库，安装完成后执行如下命令添加管理员账户：
redis 127.0.0.1:6379> incr next_user_id
(integer) 1
执行完该命令后表明 next_user_id 的值为1，然后执行如下命令（1:user_name和1:password中的1即为上一步执行incr next_user_id后的
next_user_id的值）
redis 127.0.0.1:6379> hmset users 1:user_name admin 1:password 20eabe5d64b0e216796e834f52d61f
OK
执行下面的命令将管理员admin的id添加到管理员集合中
redis 127.0.0.1:6379> sadd administrators 1
(integer) 1

执行完以上命令后我们新增加了一个管理员账户admin,密码为1234567。

下载源代码并解压缩到你的网站根目录，使用命令行工具进入该目录，然后输入
$ npm install
安装依赖的库文件(确保你有管理员权限可以安装库文件），安装完成后，打开根目录下的config.js文件设置数据库信息和网站端口号。
exports.db对象是数据库配置，exports.sessiondb是seesion数据库的数据库配置，seesion信息都存在redis数据库中，exports.app 对象中的
port属性表示网站端口号，默认是80端口。配置设置好后执行
$ node app.js
看到输出'Express server listening on port '80' 则表示服务器启动成功（这里的端口号80会和你在config.js中的exports.app.port保持一致）
进入网站主页你会看到登陆界面，输入管理员账户名 adminn,密码1234567则可以登陆成功。 进入管理后台设置部门，然后建立新用户，把建立好的用户名和密码告知
用户，用户使用用户名和密码登陆系统就可以写日报和查看日报了。

数据库字段说明：

用户数据：
next_user_id  (类型 string) 用户id值，每生成一个新用户该值通过incr方法递增1

users (类型 hash) 所有注册用户信息存储在此
 每个user包含如下key:value
 hmset("users", "#{userId}:user_name", userName, "#{userId}:password", password, "#{userId}:department_id", departmentId, "#{userId}:superior_id", superiorId)
 superiorId 为该用户直接上级用户的Id,如果没有直接上级，那么该 key 不存在

部门数据：
next_department_id  (类型 string) 部门id 的值，每生成一个新部门该值通过incr方法递增1

departments (类型 hash) 所有部门信息存储在此
 每个department包含如下key:value
 hset("departments", "#{departmentId}:name", departmentName, "#{departmentId}:pid", pid)
 pid 为该部门直接上级部门，如果没有直接上级部门，那么该 key 不存在

日报数据：
next_report_id  (类型 string) 日报id 的值，每生成一个新日报该值通过incr方法递增1

userid:#{userId}:reportIds (类型 sorted sets)
score 为日期数值 2004-04-09 转换为 20040409
member 为report id

userid:#{userId}:reports (类型 hash)
 #{reportId}:date为日报日期  #{reportId}:content为日报内容

管理员：
administrators (类型 set) 存储的是用户id,管理员用户的id都在该集合中
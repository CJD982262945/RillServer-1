# zServer
zServer是一套基于skynet的通用服务端框架，设计为符合房间型游戏的框架，如棋牌、xx大作战。

##【编译方法】
进入目录后make

##【目录介绍】
* config		游戏配置
* etc    		程序配置
* luaclib		c语言库
* lualib		lua库
* lualib-src	c语言库源码
* mod			游戏逻辑
* service		各个服务的逻辑
* run			保存运行信息
* skynet		skynet原程序（有改动）
* log			日志目录
* test		测试程序


##【运行和示例】
示例1 echo
	服务端./start.sh 即可运行服务端（单阶段）
	客户端 cd test ../skynet/3rd/lua/lua 1-echo.lua
示例2 name
	数据库保存测试
示例3 chat	
示例4 movegame	
	运行测试客户端 测试游戏 http://123.207.111.118/move/
示例5 读配置
示例6 日志
	1 修改config的log_level，测试日志级别
	2 请使用../start.sh -D，日志文件在userlog
	3 telnet 127.0.0.1 8701，logon/logoff address 记录一个服务所有的输入消息到log文件夹里
示例7 代码热更新，配置热更新
	改示例1和示例5的配置，热更，再试试
示例8 排行榜
	排行榜查询次数的排行榜，演示global保存数据
示例9 数据库断线重连
        使用示例1登录，关闭数据库，测试，重开数据库，测试
示例10 xx游戏
	
	
注意：
热更新模块修改了下列文件，若升级skynet，应该把这一部分抽出来
skynet/lualib/debug.lua
skynet/service/debug_console.lua
skynet/service/launcher.lua

【可以改进】
[优化]game改成agentpool那样的，按需开启
[优化]用配置require，参考skynet/lualib/debug.lua注释掉的reload.loadmod("reloadlist")
[优化]事件系统：login/loginout等
[优化]玩家存储：加一层redis
[优化]call和协议名都改为用点区分模块
[必须]关服功能
[必须]on服务端开启 on关闭等方法调用
[优化]gate login game dbproxy在同一节点内
性能测试



已经发现的注意点
bson：bson会把key都存为string，读取时要tonumber处理











# zServer
zServer是一套基于skynet的通用服务端框架，设计为符合房间型游戏的框架，如棋牌、xx大作战。

【编译方法】
进入目录后make

【目录介绍】
config		游戏配置
etc    		程序配置
luaclib		c语言库
lualib		lua库
lualib-src	c语言库源码
mod			游戏逻辑
service		各个服务的逻辑
run			保存运行信息
skynet		skynet原程序（有改动）
log			日志目录
test		测试程序


【运行和示例】
./start.sh 即可运行（单阶段）
运行测试客户端 测试游戏 http://123.207.111.118/move/



多节点配置






怎样显示图片？？




TODO


【agent】
改为game
【global数据存储】
【log】
基本有了
【玩家存储】
加一层redis
【性能测试】


注意：
热更新模块修改了下列文件，若升级skynet，应该把这一部分抽出来
skynet/lualib/debug.lua
skynet/service/debug_console.lua
skynet/service/launcher.lua

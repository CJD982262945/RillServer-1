local skynet = require "skynet"
local libcenter = require "libcenter"
local libmove = require "libmove"
local libqueryboard = require "libqueryboard"
local tool = require "tool"
local libsetup = require "libsetup"
local Player = require "game.player"
local runconf = require(skynet.getenv("runconfig"))

local faci = require "faci.module"
local module = faci.get_module("example")
local dispatch = module.dispatch
local forward = module.forward
local event = module.event

--示例1 echo
function forward.echo(player, msg)
	local cmd = msg._cmd
	local str = msg.str
	msg.str = msg.str.." echo hehe"
	skynet.error("game echo ! "..cmd.." "..str)
	return msg
end

--示例2 name
function forward.set_name(player, msg)
	local cmd = msg._cmd
	local str = msg.str

	skynet.error("name "..cmd.." "..(player.data.baseinfo.name or "none"))
	skynet.error("set_name "..cmd.." "..str)
	skynet.error("login_time "..cmd.." "..player.data.baseinfo.login_time)
	
	player.data.baseinfo.name = str
	return msg
end

--示例3 chat
function forward.chat(player, msg)
    local cmd = msg._cmd
	local str = msg.str
	libcenter.broadcast2client(msg)
	skynet.error("agent chat ! "..cmd.." "..str)
	return nil
end


--示例4 进入房间
function forward.enter_room(player, msg)
	--msg = {id=1,2,3}
	if player.room_id then
		skynet.error("enter room fail,already in room")
		msg.result = 1
		return msg
	end

	local data = {
		--game = skynet.self(),
		--node = node,
	}
	if libmove.enter(msg.id, player.uid, data) then
		msg.result = 0
		player.room_id = msg.id
		env.service["movegame"] = libmove.get_forward(player.room_id)
	else
		msg.result = 1
	end
	return msg
end

--示例4 离开房间
function forward.leave_room(player)
	if not player.room_id then
		return
	end
	env.service["movegame"] = nil

	if libmove.leave(player.room_id, player.uid) then
		player.room_id = nil
	end
end

--示例5 读配置
function forward.itemlist(player, msg)
	local cmd = msg._cmd
	--local item = libsetup.get("item", 1)
	--local item = libsetup.item[1]
	--msg.id = item.id
	--msg.desc = item.desc
	
	msg.items = {}
	log.info("read item")
	for k, v in pairs(libsetup.item) do
		log.info("key:%s  desc:%s", k ,v.desc)
		msg.items[k] = v.desc
	end
	return msg
end

--示例6 日志
function forward.log(player, msg)
	--1修 改config的log_level，测试日志级别
	--2 请使用../start.sh -D，日志文件在userlog
	--3 telnet 127.0.0.1 8701
	--       logon/logoff address 记录一个服务所有的输入消息到log文件夹里。
	local cmd = msg._cmd
	log.debug("log debug")
	log.info("log info")
	log.warn("log warn")
	log.error("log error")
	return msg
end

--示例7 热更配置
--测试热更新
local testud1 = 985					--热更后会替换
local testud2 = testud2 or testud1	--热更后会替换
testud3 = testud1					--热更后会替换
testud4 = testud4 or testud1		--不会替换
function dispatch.testupdate()		--热更后会替换
	log.info("this is 9")			
	log.info("testud1:"..testud1)
	log.info("testud2:"..testud2)
	log.info("testud3:"..testud3)
	log.info("testud4:"..testud4)
end

--示例8 留言板
function forward.queryboard(player, msg)
	return libqueryboard.query(player.uid)
end

--示例9 测试c模块
local luaclock = require "luaclock"
function forward.testluaclock(player, msg)
	log.debug("print time")
	log.debug(luaclock.time())
	log.debug("time now:"..luaclock.time())
	return msg
end

--示例12 http请求
local httpc = require "http.httpc"
function forward.testhttp(player, msg)
	local respheader = {}
	log.debug("start get http ")
	local status, body = httpc.get("baidu.com", "/", respheader)
	log.debug("http baidu: %s", body)
	--local status, body = httpc.get("pal5h.com", "/", respheader)
	--log.debug("http pal5h: %s", body)
	msg.str = body
	return msg
end





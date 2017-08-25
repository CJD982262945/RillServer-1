do return end

local skynet = require "skynet"
local log = require "log"
local env = require "env"
local libcenter = require "libcenter"
local cluster = require "skynet.cluster"

env.life = env.life or {}
env.dispatch.life = env.dispatch.life or {}
env.forward.life = env.forward.life or {}
env.life.ids = {}  --ids[uid] = room_id
env.life.rooms = {}

require "global.life.liferoom"
require "global.life.lifemgr"
require "global.life.map"
require "global.life.player"
require "global.life.player_building"

local ids = env.life.ids
local rooms = env.life.rooms
local D = env.dispatch.life
local F = env.forward.life
env.life.FRAME_RATE = 30 --服务端每秒跑30帧

--rooms[id] = {
	--top
	--last_sync_time 
	--map = {
--		每个格子40*40
--		0-空 1-地面 101金币 201小学 202大学 203培训
--		204仓库员 205销售员 206开挖掘机 207音乐家 208造火箭
--			[row] = {1,101,1,0,0,0,0,0}
--		}
--	}

--  id
--	players[uid]={game,node,x,y}
--}


local t1 = skynet.time() --进入一帧的开始时间
local t2 = 0 --一帧结束的时间 100表示1秒
local last_sec = 0 --统计打日志用的
local frame_count = 0 --统计打日志用的
local last_update_time = 0
function env.life.update()
	--优化，skynet的时钟精度只有1/100，最好改成一个1000的时钟，update功能最好也放在cpp里调用
	local deltaTime = skynet.time() - t1
	t1 = skynet.time()
	
	for id, room in pairs(rooms) do
		env.life.update_room(room, deltaTime)
	end
	
	t2 = skynet.time()
	local t = t2 - t1 --t永远等于0吧，一个时间片内，待测试
	
	--大帧检测
	local expect_rate = (1/env.life.FRAME_RATE)
	if t > expect_rate*1.2 then
		log.warn("life game, big frame %d > %d *1.2", t,  expect_rate)
	else
		--log.warn("life game, big frame %d ok %d *1.2", math.ceil(t),  math.ceil(expect_rate))
	end
	--下一帧
	--local waittime = expect_rate - t
	--waittime = waittime > 0 and waittime or 0
	local waittime = last_update_time + 2*expect_rate - skynet.time()
	if last_update_time == 0 then waittime = expect_rate end
	waittime = waittime > 0 and waittime or 0
	--log.info("update time:"..skynet.time().." waittime:"..waittime.." last_update_time:"..last_update_time.." time:"..skynet.time())
	last_update_time = skynet.time()
	frame_count = frame_count + 1
	if math.floor(skynet.time()) ~= last_sec then
		log.info("update one sec frame_count:"..frame_count)
		last_sec = math.floor(skynet.time()) 
		frame_count = 0
	end
	
	waittime = math.floor(waittime*100)
	

	skynet.timeout(waittime, env.life.update)
end

function env.init()
	env.life.update()
end

function D.broadcast(room, cmd, msg)
	for i,v in pairs(room.players) do
		if v.game then
			msg.cmd = cmd
			if v.node == skynet.getenv("nodename") then
				skynet.send(v.game, "lua", "send2client", i, msg)
			else 
				cluster.send(v.node, v.game, "send2client", i, msg)
			end
		else
			libcenter.send2client(i, {cmd="life.leave", uid=uid})
		end
	end
end
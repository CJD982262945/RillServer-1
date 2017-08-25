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
env.life.FRAME_RATE = 30 --�����ÿ����30֡

--rooms[id] = {
	--top
	--last_sync_time 
	--map = {
--		ÿ������40*40
--		0-�� 1-���� 101��� 201Сѧ 202��ѧ 203��ѵ
--		204�ֿ�Ա 205����Ա 206���ھ�� 207���ּ� 208����
--			[row] = {1,101,1,0,0,0,0,0}
--		}
--	}

--  id
--	players[uid]={game,node,x,y}
--}


local t1 = skynet.time() --����һ֡�Ŀ�ʼʱ��
local t2 = 0 --һ֡������ʱ�� 100��ʾ1��
local last_sec = 0 --ͳ�ƴ���־�õ�
local frame_count = 0 --ͳ�ƴ���־�õ�
local last_update_time = 0
function env.life.update()
	--�Ż���skynet��ʱ�Ӿ���ֻ��1/100����øĳ�һ��1000��ʱ�ӣ�update�������Ҳ����cpp�����
	local deltaTime = skynet.time() - t1
	t1 = skynet.time()
	
	for id, room in pairs(rooms) do
		env.life.update_room(room, deltaTime)
	end
	
	t2 = skynet.time()
	local t = t2 - t1 --t��Զ����0�ɣ�һ��ʱ��Ƭ�ڣ�������
	
	--��֡���
	local expect_rate = (1/env.life.FRAME_RATE)
	if t > expect_rate*1.2 then
		log.warn("life game, big frame %d > %d *1.2", t,  expect_rate)
	else
		--log.warn("life game, big frame %d ok %d *1.2", math.ceil(t),  math.ceil(expect_rate))
	end
	--��һ֡
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
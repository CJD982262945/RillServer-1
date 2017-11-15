local skynet = require "skynet"
local log = require "log"
local libcenter = require "libcenter"
local cluster = require "skynet.cluster"

local faci = require "faci.module"
local module, static = faci.get_module("life")
local dispatch = module.dispatch
local forward = module.forward
local event = module.event

static.ids = static.ids or {}  --ids[uid] = room_id
static.rooms = static.rooms or {}
local ids = static.ids
local rooms = static.rooms

static.FRAME_RATE = 30 --�����ÿ����30֡

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

local function update()
	--�Ż���skynet��ʱ�Ӿ���ֻ��1/100����øĳ�һ��1000��ʱ�ӣ�update�������Ҳ����cpp�����
	local deltaTime = skynet.time() - t1
	t1 = skynet.time()
	for id, room in pairs(rooms) do
		static.update_room(room, deltaTime)
	end
	
	t2 = skynet.time()
	local t = t2 - t1 --t��Զ����0�ɣ�һ��ʱ��Ƭ�ڣ�������
	
	--��֡���
	local expect_rate = (1/static.FRAME_RATE)
	if t > expect_rate*1.2 then
		log.warn("life game, big frame %f > %f *1.2", t,  expect_rate)
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
	

	skynet.timeout(waittime, update)
end

function event.awake()
	update()
end

function dispatch.broadcast(room, cmd, msg)
	for i,v in pairs(room.players) do
		if v.game then
			msg._cmd = cmd
			if v.node == skynet.getenv("nodename") then
				skynet.send(v.game, "lua", "game.send2client", i, msg)
			else 
				cluster.send(v.node, v.game, "game.send2client", i, msg)
			end
		else
			libcenter.send2client(i, {_cmd="life.leave", uid=uid})
		end
	end
end


function module.watch(acm)
	local ret = {room_num=0, player_num=0,detail={}}
	--ͳ�Ʒ���������������
	for i, v in pairs(rooms) do
		local player = 0
		local pstr = ""
		for _, p in pairs(v.players) do
			player = player + 1
			pstr = pstr..p.uid..","
		end
		ret.room_num = ret.room_num + 1
		ret.player_num = ret.player_num + player
		local str = string.format("room[%d], player_count:%d uids:{%s} ", i, player, pstr)
		ret.detail[i] = str
	end
	--��ͳ��
	acm.room_num = acm.room_num and acm.room_num + ret.room_num or ret.room_num
	acm.player_num = acm.player_num and acm.player_num + ret.player_num or ret.player_num
	
	return ret, acm
end
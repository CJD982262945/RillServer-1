local skynet = require "skynet"
local log = require "log"
local libcenter = require "libcenter"
local liblife = require "liblife"
local Player = require "global.life.player"

local faci = require "faci.module"
local module, static = faci.get_module("life")
local dispatch = module.dispatch
local forward = module.forward

static.ids = static.ids or {}
static.rooms = static.rooms or {}
local ids = static.ids
local rooms = static.rooms




function dispatch.create(id)
	local room = {
		id = id,
		players = {},
		map = {},
		top = 0,
		last_sync_time = 0,
		descent_speed = static.DEFAULT_SPEED
	}
	rooms[id] = room
	--初始化地图
	static.init_map(room)
end


function dispatch.delete(id)
	local room = rooms[id]
	if not room then
		log.debug("lifegame.delete fail, not room, room(%d)", id)
		return false
	end

	if next(room.players) then
		log.debug("lifegame.delete fail, has players, room(%d)", id)
		return false
	end
	
	rooms[id] = nil
	liblife.delete(id)
	return true
end

function dispatch.enter(id, uid, data)
	skynet.error("lifegame enter room "..uid.." "..id)
	local room = rooms[id]
	if not room then
		skynet.error("lifegame enter fail, not room "..id)
		return false
	end

	local y, x, face = static.born_point(room)
	--init player
	local player = Player.new()
	player.uid = uid
	player.game = data.game
	player.node = data.node
	player.room = room
	player.y = y
	player.x = x
	player.face = face
	
	room.players[uid] = player
	for i,v in pairs(room.players) do
		if i ~= uid then
			local msg = player:fulldata()
			msg._cmd = "life.add"
			libcenter.send2client(i, msg)
		end
	end
	ids[uid] = id
	return true
end




function dispatch.leave(id, uid)
	local id = ids[uid]
	
	local  room = rooms[id]
	if not room then
		skynet.error("lifegame leave not room "..id)
		return false
	end
	
	room.players[uid] = nil;
	ids[uid] = nil
	
	dispatch.broadcast(room, "life.leave", {uid=uid})

	log.info("lifegame leave room uid(%d)", uid)
	
	--delete
	local count = 0
	for i,v in pairs(room.players) do
		count = count +1
	end
	if count <= 0 then
		dispatch.delete(id)
	end
	
	return count
end

function forward.list(uid, msg)
	local id = ids[uid]
	local room = rooms[id]
	if not room then
		skynet.error("lifegame leave not room "..id)
		return
	end
	
	--msg={cmd="life.list"}
	msg.players = {}
	for uid, player in pairs(room.players) do
		local pd = player:fulldata()
		table.insert(msg.players, pd)
	end
	return msg
end

function forward.input(uid, msg)
	local id = ids[uid]
	local room = rooms[id]
	local player = room.players[uid]
	
	player:input(msg.x, msg.action)
end

function forward.update_map(uid, msg)
	local room_id = static.ids[uid]
	local room = static.rooms[room_id]

	if not room then
		log.error("life.update_map(F) fail, not room uid(%d) room_id(%d)", uid, room_id)
		return
	end
	local trow, _ = static.coor2map(room.top, 0)
	msg.rows = {}
	for i=trow, trow+30 do
		if not room.map[i] then
			break
		end
		msg.rows[tostring(i)] = room.map[i]
	end
	--防止json自动转为变成数组，导致key出错
	--msg.rows[trow + 10] = {0,0,0,0,0,0,0,0}
	msg.speed = room.descent_speed --地图速度
	msg.rate = static.FRAME_RATE
	
	msg.top = room.top
	return msg
end


local function sendsync(room)
	local msg = { _cmd = "life.sync", players = {}}
	for uid, player in pairs(room.players) do
		local pd = player:syncdata()
		table.insert(msg.players, pd)
	end
			
	dispatch.broadcast(room, "life.sync", msg)
end

function static.update_room(room, deltaTime)
	static.updatemap(room, deltaTime)
	for uid, player in pairs(room.players) do
		player:update(deltaTime)
	end
	--发送同步信息
	--if skynet.time() - room.last_sync_time > 0.1 then --0.1
		room.last_sync_time = skynet.time()
		sendsync(room)
	--end
end
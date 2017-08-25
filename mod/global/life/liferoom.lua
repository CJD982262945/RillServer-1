do return end


local skynet = require "skynet"
local log = require "log"
local env = require "env"
local libcenter = require "libcenter"
local Player = require "global.life.player"

local D = env.dispatch.life
local F = env.forward.life

local ids = env.life.ids
local rooms = env.life.rooms




function D.create(id)
	local room = {
		id = id,
		players = {},
		map = {},
		top = 0,
		last_sync_time = 0,
		descent_speed = env.life.DEFAULT_SPEED
	}
	rooms[id] = room
	--初始化地图
	env.life.init_map(room)
end


function D.delete(id)
	local room = room[id]
	if not room then
		log.debug("lifegame.delete fail, not room, room(%d)", id)
		return false
	end

	if next(room.players) then
		log.debug("lifegame.delete fail, has players, room(%d)", id)
		return false
	end
	
	room[id] = nil
	return true
end

function D.enter(id, uid, data)
	skynet.error("lifegame enter room "..uid.." "..id)
	local  room = rooms[id]
	if not room then
		skynet.error("lifegame enter not room "..id)
		return false
	end

	local y, x, face = env.life.born_point(room)
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
			msg.cmd = "life.add"
			libcenter.send2client(i, msg)
		end
	end
	ids[uid] = id
	return true
end




function D.leave(id, uid)
	local id = ids[uid]
	
	local  room = rooms[id]
	if not room then
		skynet.error("lifegame leave not room "..id)
		return false
	end
	
	room.players[uid] = nil;
	ids[uid] = nil
	
	D.broadcast(room, "life.leave", {uid=uid})

	log.info("lifegame leave room uid(%d)", uid)
	return true
end

function F.list(uid, msg)
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

function F.input(uid, msg)
	local id = ids[uid]
	local room = rooms[id]
	local player = room.players[uid]
	
	player:input(msg.x, msg.action)
end

function F.update_map(uid, msg)
	local room_id = env.life.ids[uid]
	local room = env.life.rooms[room_id]

	if not room then
		log.error("life.update_map(F) fail, not room uid(%d) room_id(%d)", uid, room_id)
		return
	end
	local trow, _ = env.life.coor2map(room.top, 0)
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
	msg.rate = env.life.FRAME_RATE
	
	msg.top = room.top
	return msg
end


local function sendsync(room)
	local msg = { cmd = "life.list", players = {}}
	for uid, player in pairs(room.players) do
		local pd = player:syncdata()
		table.insert(msg.players, pd)
	end
	D.broadcast(room, "life.sync", msg)
end

function env.life.update_room(room, deltaTime)
	env.life.updatemap(room, deltaTime)
	for uid, player in pairs(room.players) do
		player:update(deltaTime)
	end
	--发送同步信息
	--if skynet.time() - room.last_sync_time > 0.1 then --0.1
		room.last_sync_time = skynet.time()
		sendsync(room)
	--end
end
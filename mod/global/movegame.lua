local skynet = require "skynet"
local libcenter = require "libcenter"

local faci = require "faci.module"
local module = faci.get_module("movegame")
local dispatch = module.dispatch
local forward = module.forward
local event = module.event

--移动游戏

local rooms = {}
local ids = {} 
--rooms[id] = {
--  id
--	players[uid]={game,node,x,y}
--}
--ids[uid] = room_id

function dispatch.create(id)
	local room = {
		id = id,
		players = {},
	}
	rooms[id] = room
end

function dispatch.enter(id, uid, data)
	skynet.error("movegame enter room "..uid.." "..id)
	local  room = rooms[id]
	if not room then
		skynet.error("movegame enter not room "..id)
		return false
	end
	local x = math.random(0,400)
	local y = math.random(0,700)
	local player = {
		--game = data.agent,
		--node = data.node,
		x = x,
		y = y,
	};
	room.players[uid] = player
	for i,v in pairs(room.players) do
		if i ~= uid then
			--优化方法，记录game和node，然后发送
			local msg = {cmd="movegame.add", uid=uid, x=x, y=y}
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
		skynet.error("movegame leave not room "..id)
		return false
	end
	
	room.players[uid] = nil;
	ids[uid] = nil
	
	for i,v in pairs(room.players) do
		libcenter.send2client(i, {cmd="movegame.leave", uid=uid})
	end
	skynet.error("movegame leave room "..uid)
	return true
end

function forward.list(uid, msg)
	local id = ids[uid]
	local  room = rooms[id]
	if not room then
		skynet.error("movegame leave not room "..id)
		return
	end
	
	msg={cmd="movegame.list",t=1}
	msg.players = {}
	for i,v in pairs(room.players) do
		table.insert(msg.players,{x=v.x,y=v.y,uid=i})
	end
	return msg
end

function forward.move(uid, data)
	local id = ids[uid]
	local  room = rooms[id]
	if not room then
		skynet.error("movegame move not room "..id)
		return
	end
	local x = data.x
	local y = data.y
	skynet.error("movegame move "..uid.." "..x.." "..y)
	local player = room.players[uid]
	player.x = player.x + x
	player.y = player.y + y
	for i,v in pairs(room.players) do
		libcenter.send2client(i, {cmd="movegame.move", uid=uid, x=player.x, y=player.y})
	end
end
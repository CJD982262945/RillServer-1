local skynet = require "skynet"
local log = require "log"

local libcenter = require "libcenter"
local liblife = require "liblife"
local libqueryboard = require "libqueryboard"
local tool = require "tool"
local libsetup = require "libsetup"
local Player = require "game.player"
local runconf = require(skynet.getenv("runconfig"))
local node = skynet.getenv("nodename")

env.dispatch.life = env.dispatch.life or {}
env.forward.life = env.forward.life or {}
local D = env.dispatch.life
local F = env.forward.life


--进入房间
function F.enter_room(player, msg)
	--msg = {id=1,2,3}
	player.life = player.life or {}
	if player.life.room_id then
		skynet.error("enter room fail,already in room")
		msg.result = 1
		return msg
	end

	local data = {
		game = skynet.self(),
		node = node,
	}
	local ret, id = liblife.enter(player.uid, data)
	if ret then
		msg.result = 0
		player.life.room_id = id
		player.romote.life = liblife.get_forward(id)
	else
		msg.result = 1
	end
	return msg
end

--离开房间
function F.leave_room(player, msg)
	D.leave_room(player)
	return
end

--离开房间
function D.leave_room(player)
	if not player.life then
		return
	end
	
	local id = player.life.room_id
	if not id then
		return
	end
	
	if liblife.leave(id, player.uid) then
		player.romote.life = nil
		player.life = nil
	end
end

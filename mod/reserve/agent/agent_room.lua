local skynet = require "skynet"
local log = require "log"
local env = require "env"
local libcenter = require "libcenter"
local libmove = require "libmove"

local M = env.dispatch
local room_id = nil --movegame的房间id

function M.enter_room(msg)
	skynet.error("xxxxxxxx1")
	--msg = {id=1,2,3}
	if room_id then
		skynet.error("enter room fail,already in room")
		msg.result = 1
		return msg
	end
	local uid = env.get_player().uid
	local data = {
		uid=env.get_player().uid,
		agent = skynet.self(),
		node = node,
	}
	if libmove.enter(msg.id, uid, data) then
		msg.result = 0
		room_id = msg.id
		env.service["movegame"] = libmove.get_forward(room_id)
	else
		msg.result = 1
	end
	return msg
end

function M.leave_room(msg)
	if not room_id then
		return
	end
	env.service["movegame"] = nil
	local uid = env.get_player().uid
    if libmove.leave(room_id, uid) then
		room_id = nil
	end
	return msg
end


--示例1 echo
function M.echo(msg)
    local cmd = msg.cmd
	local str = msg.str
	skynet.error("agent echo ! "..cmd.." "..str)
	return msg
end

--示例2 name
function M.set_name(msg)
    local cmd = msg.cmd
	local str = msg.str
	local playerdata = env.get_playerdata()
	
	skynet.error("name "..cmd.." "..(playerdata.player.name or "none"))
	skynet.error("set_name "..cmd.." "..str)
	skynet.error("login_time "..cmd.." "..playerdata.player.login_time)
	
	playerdata.player.name = str
	
	--msg.str="succ"
	return msg
end

	
	
--示例3 chat
function M.chat(msg)
    local cmd = msg.cmd
	local str = msg.str
	libcenter.broadcast(env.get_player().uid, "broadcast_msg", msg)
	skynet.error("agent chat 999! "..cmd.." "..str)
	
	
	return nil
end

--示例4 测试热更
local reload = require "reload"

function M.chatreload(msg)
    local cmd = msg.cmd
	local str = msg.str
	--注意agent_init中require的形式
	--这种热更只能更新本服
	reload.loadmod("agent.agent_room")
	return nil
end

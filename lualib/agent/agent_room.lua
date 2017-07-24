local skynet = require "skynet"
local log = require "log"
local env = require "env"
local libcenter = require "libcenter"

local M = env.dispatch

function M.enter_room(msg)
	--{id=1,2,3}
    local service = skynet.call(".room_mgr", "lua", "enter", msg)
    env.service["room"] = service  
end

function M.leave_room(msg)
    env.service["room"] = nil
end




--ʾ��1 echo
function M.echo(msg)
    local cmd = msg.cmd
	local str = msg.str
	skynet.error("agent echo ! "..cmd.." "..str)
	return msg
end

--ʾ��2 name
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

	
local count = 0
	
--ʾ��3 chat
function M.chat(msg)
    local cmd = msg.cmd
	local str = msg.str
	libcenter.broadcast(env.get_player().uid, "broadcast_msg", msg)
	skynet.error("agent chat 1111999! "..cmd.." "..str)
	
    count = count + 1
    skynet.error("count === " .. count)
	
	return nil
end

--ʾ��4 �����ȸ�
local reload = require "reload"

function M.chatreload(msg)
    local cmd = msg.cmd
	local str = msg.str
	--ע��agent_init��require����ʽ
	--�����ȸ�ֻ�ܸ��±���
	reload.loadmod("agent.agent_room")
	return nil
end

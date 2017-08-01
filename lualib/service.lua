local skynet = require "skynet"
local log = require "log"
local env = require "env"
local M = env.dispatch
local protopack = require "protopack"
require "libstring"
local websocket = require "websocket"
local tool = require "tool"

local function traceback(err)
	log.error(tostring(err))
	log.error(debug.traceback())
end

skynet.start(function()
    skynet.dispatch("lua", function(session, addr, cmd, ...)

        local function ret(ok, ...)
            if not ok then
                skynet.ret()
            else
                skynet.retpack(...)
            end
        end

        local f = env.dispatch[cmd]
        if not f then
            log.error("cmd(%s) is not found, %s", cmd, debug.traceback())
            return
        end

        ret(xpcall(f, traceback, ...))
    end)
	
    if env.init then
        env.init()
    end
end)


function M.client_forward(cmd, id, msg)
	local f = env.forward[cmd]
	if not f then
		log.error("cmd(%s) is not found, %s", cmd, debug.traceback())
		return
	end
	return f(id, msg)
end

local function get_v(fd)
	if env.fds[fd] then
		return  env.players[env.fds[fd]]
	else
		return  fd
	end
end

function service_dispatch(service_name, cmd, fd, msg, source)
    local adress = env.service[service_name]
    if not adress then
        log.error("service name(%s) is not exist, cmd = %s", service_name, cmd)
        return
    end

    local ret = skynet.call(adress, "lua", "client_forward", cmd, get_v(fd).uid, msg)
    return ret 
end

function default_dispatch(cmd, fd, msg, source)
    local cb = env.forward[cmd]
    if type(cb) ~= "function" then
        log.error("cb is not function, cmd = %s, str = %s", cmd, tool.dump(msg))
        return
    end
	
    local isok, ret = pcall(cb, get_v(fd), msg, source)
    if not isok then
        log.error("handle msg error, cmd = %s, str = %s, err=%s", cmd, str, ret)
        return
    end
    return ret 
end


function dispatch(session, source, str)
	--特殊用法，将session用作fd，减少再次转发给gate
	local fd = session
	local cmd, msg = protopack.unpack(str)
	local cmdlist = string.split(cmd, ".")
	local length = #cmdlist
	local ret
	if length == 1 then
		ret = default_dispatch(cmd, fd, msg, source)
	elseif length == 2 then
		ret = service_dispatch(cmdlist[1], cmdlist[2], fd, msg, source)
	end
	if ret then
		local data = protopack.pack(msg.cmd, ret)
		websocket:send_text(fd,data)
	end
end

skynet.register_protocol{
	name = "client",
	id = skynet.PTYPE_CLIENT,
	unpack = skynet.tostring,
	dispatch = dispatch, 
}









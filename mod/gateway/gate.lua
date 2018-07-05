local skynet = require "skynet"
local log = require "log"
local tool = require "tool"

local liblogin = require "liblogin"
local libcenter = require "libcenter"

local runconf = require(skynet.getenv("runconfig"))
local servconf = runconf.service

local env = require "faci.env"
local gate_id = tonumber(env.gateway_id)
local gate_conf = servconf.gateway[gate_id]

local prototype = gate_conf.prototype or runconf.prototype
local protopacktype = gate_conf.protopack or runconf.protopack

local libsocket = require ("libsocket_"..prototype)
local protopack = require ("protopack_"..protopacktype)
local gateserver = require("faci.gateserver_"..prototype)

local connection = {}	-- fd -> { fd , ip, playerid（登录后有）game（登录后有）key（登录后有）}
local fds = {} --playerid->fd
local name = "" --gated1

skynet.register_protocol {
	name = "client",
	id = skynet.PTYPE_CLIENT,
}

local handler = {}

function handler.open(source, conf)
	log.info("start listen port: %d", conf.port)
	name = conf.name
end

function handler.connect(fd, addr)
	local c = {
		fd = fd,
		ip = addr,
		playerid = nil,
		game = nil,
	}
	connection[fd] = c
	gateserver.openclient(fd)
	log.info("New client from : %s fd:%d", addr, fd)
end

function handler.message(fd, msg, sz)
	local c = connection[fd]
	local playerid = c.playerid
	local source = skynet.self()
    local str = skynet.tostring(msg, sz)
	local cmd, check, msg = protopack.unpack(str)
    if not cmd then
        CMD.kick(source, fd)
        return
    end

	if playerid then
		skynet.redirect(c.game, source, "client", 0, skynet.pack(fd, cmd, check, msg))
	else
		local login = liblogin.fetch_login()
		skynet.redirect(login, source, "client", 0, skynet.pack(fd, cmd, check, msg))
	end
end

local CMD = {}

function CMD.get_addr(source, fd)
    local c = connection[fd]
    if not c then
        return false
    end
    if not c.ip then
        return false
    end
    return true, c.ip
end

--true/false
function CMD.register(source, data)
	local c = connection[data.fd]
    
	if not c then
		return false
	end
	
	c.playerid = data.playerid
	c.game = data.game
	c.key = data.key
	fds[data.playerid] = data.fd
	return true
end

function CMD.send(source, fd, msg)
    local cmd = msg._cmd
	local check = msg._check or 0
	msg._cmd = nil
	msg._check = nil
	local data = protopack.pack(cmd, check, msg)
	libsocket.send(fd, data)
end

--true/false
function CMD.kick(source, fd)
	log.debug("cmd.kick %d", fd)
	local c = connection[fd]
	
	if not c then
		return true
	end
	
	if c.playerid then
		fds[c.playerid] = nil
	end
	connection[fd] = nil
	gateserver.closeclient(fd)
	return true
end

CMD["faci.stop"] = function ()
    for k, v in pairs(connection) do
        handler.disconnect(k)
    end
end

CMD["faci.exit"] = function ()
    skynet.exit()
end

function handler.disconnect(fd)
	log.debug("handler.disconnect %d", fd)
	local c = connection[fd]
	if not c then
		return
	end
	local playerid = c.playerid
	if playerid then
		log.debug("handler.disconnect playerid:%d", playerid)
		libcenter.logout(playerid, c.key)
	end
	connection[fd] = nil
	gateserver.closeclient(fd)
end

function handler.error(fd, msg)
	log.debug("handler.error %s", msg)
	handler.disconnect(fd)
end

function handler.warning(fd, size)
	log.debug("handler.warning %d", size)
end

function handler.command(cmd, source, ...)
    log.debug("cmd: " .. cmd)
	local f = assert(CMD[cmd])
	return f(source, ...)
end

gateserver.start(handler)

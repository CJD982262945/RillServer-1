

local skynet = require "skynet"
local log = require "log"

local liblogin = require "liblogin"
local libcenter = require "libcenter"

local gateserver = require "faci.gateserver"   --pb协议

local connection = {}	-- fd -> { fd , ip, uid（登录后有）game（登录后有）key（登录后有）}
local fds = {} --uid->fd
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
		uid = nil,
		game = nil,
	}
	connection[fd] = c
	gateserver.openclient(fd)
	log.info("New client from : %s fd:%d", addr, fd)
end

function handler.message(fd, msg, sz)
	local c = connection[fd]
	local uid = c.uid
	local source = skynet.self()
	if uid then
		--fd为session，特殊用法
		skynet.redirect(c.game, source, "client", fd, msg, sz)
	else
		local login = liblogin.fetch_login()
		--fd为session，特殊用法
		skynet.redirect(login, source, "client", fd, msg, sz)
	end
end

local CMD = {}

--true/false
function CMD.register(source, data)
	local c = connection[data.fd]
    
	if not c then
		return false
	end
	
	c.uid = data.uid
	c.game = data.game
	c.key = data.key
	fds[data.uid] = data.fd
	return true
end

--true/false
function CMD.kick(source, fd)
	log.debug("cmd.kick %d", fd)
	local c = connection[fd]
	
	if not c then
		return true
	end
	
	if c.uid then
		fds[c.uid] = nil
	end

	return true
end

function handler.disconnect(fd)
	log.debug("handler.disconnect %d", fd)
	local c = connection[fd]
	if not c then
		return
	end
	local uid = c.uid
	if uid then
		log.debug("handler.disconnect uid:%d", uid)
		libcenter.logout(uid, c.key)
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
	local f = assert(CMD[cmd])
	return f(source, ...)
end

gateserver.start(handler)
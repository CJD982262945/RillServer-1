local skynet = require "skynet"
local libdb = require "libdbproxy"
local libcenter = require "libcenter"
local libgame = require "libgame"
local tool = require "tool"
local faci = require "faci.module"
local runconf = require(skynet.getenv("runconfig"))

local key_seq = 1

local module, static = faci.get_module("Login")
local dispatch = module.dispatch
local forward = module.forward
local event = module.event

local login_mode = runconf.service.login_common.mode

env.login_accounts = env.login_accounts or {} 

function static.check_pw(msg)
    local func_name = string.format("check_pw_%s", login_mode)
    local cb = static[func_name]
    if type(cb) == "function" then
        return cb(msg)
    end

    assert(false)
end

local function login_help(fd, msg, source)
    local account = msg.Account
	--key
	key_seq = key_seq + 1
	local key = env.id*10000 + key_seq
    --check_pw
	local isok, playerid = static.check_pw(msg)
	if not isok then
		log.debug("%s login fail, ", account)
        msg.Result = 601
		return msg
	end
    --get ip information from gate
    local isok, addr = skynet.call(source, "lua", "get_addr", fd)
    if not isok then
        log.debug("%d login fail, gate get ip err ", playerid)
        msg.Result = 603
        return msg
    end

	--center
	local data = {
		node = skynet.getenv("nodename"),
		fd = fd,
		gate = source,
		key = key,
	}
	if not libcenter.login(playerid, data) then
		log.debug("%d login fail, center login fail ", playerid)
		msg.Result = 602
		return msg
	end
	--game
	data = {
        playerid = playerid,
		fd = fd,
        addr = addr,
        gate = source,
        client_info = {
            os_info = msg.OsInfo,
            device_id = msg.DeviceId,
            device_name = msg.DeviceName,
            screen = msg.Screen,
            mno = msg.MNO,
            nm = msg.NM,
            game_version = msg.GameVersion,
            account = account,
            platform = msg.Platform,
        },
	}
    log.debug("login_forward addr = %s", addr)
	local ret, game = libgame.login(playerid, data)
	if not ret then
		libcenter.logout(playerid, key)
		log.debug("%d login fail, load data err ", playerid)
		msg.Result = 603
		return msg
	end
	--center
	local data = {
		game = game,
		key = key,
	}
	if not libcenter.register(playerid, data) then
		libcenter.logout(playerid, key)
		log.debug("%d login fail, register center fail ", playerid)
        msg.Result = 604
		return msg
	end
	--gate
	local data = {
		playerid = playerid,
		fd = fd,
		game = game,
		key = key
	}
	if not skynet.call(source, "lua", "register", data) then
		libcenter.logout(playerid, key)
		log.debug("%d login fail, register gate fail ", playerid)
        msg.Result = 605
		return msg
	end
	log.debug("%d login success ", playerid)
	msg.PlayerId = playerid
    msg.Result = 0
	return msg
end

local function traceback(err)
	log.error(tostring(err))
	log.error(debug.traceback())
end

--µÇÂ¼
function forward.MsgLogin(fd, msg, source)
    local account = msg.Account
    if env.login_accounts[account] then
        msg.Result = 100
	    return msg
    end

    env.login_accounts[account] = true
    local isok, ret = xpcall(login_help, traceback, fd, msg, source)
    if not isok then
        env.login_accounts[account] = nil
        msg.Result = 101
        return msg
    end
    env.login_accounts[account] = nil
    return ret
end


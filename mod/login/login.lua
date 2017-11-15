local skynet = require "skynet"
local libdb = require "libdbproxy"
local libcenter = require "libcenter"
local libgame = require "libgame"
local tool = require "tool"
local faci = require "faci.module"

local key_seq = 1

local module = faci.get_module("login")
local dispatch = module.dispatch
local forward = module.forward
local event = module.event



--·µ»Øtrue,uid/false 
local function register(account, password)
	if not account then
		log.debug("register not account" )
        return false
	end
    local ret = libdb.get_accountdata(account)
    if ret then
        return false
    end
    local uid = libdb.inc_uid() 
    local data = {
        uid = uid,
        account = account,
        password = password
    }
    local ret = libdb.set_accountdata(account, data) 
	log.debug("register succ account:%s uid:%d", account, uid)
    return true, uid
end

--·µ»Øtrue,uid/false 
local function check_pw(account, password)
	if not account then
		log.debug("check_pw not account")
        return false
	end

    local ret = libdb.get_accountdata(account)
	--µÇÂ¼
	if ret and ret.password == password then
		log.info("check_pw succ account:%s then login uid:%d", account, ret.uid)
		return true, ret.uid
	end
	--×¢²á
	log.info("check_pw fail account:%s then register",  account)
	local ret, uid = register(account, password)
	if ret then
		return true, uid
	end

	return false
end

--µÇÂ¼Ð­Òé
function forward.Login(fd, msg, source)
    local account = msg.account
	local password = msg.password
	--key
	key_seq = key_seq + 1
	local key = env.id*10000 + key_seq
	--ÕËºÅÐ£Ñé
	local isok, uid = check_pw(account, password)
	if not isok then
		log.debug("%s login fail, wrong password ", account)
		msg.error = "login fail, wrong password"
		return msg
	end
	--center
	local data = {
		node = skynet.getenv("nodename"),
		fd = fd,
		gate = source,
		key = key,
	}
	if not libcenter.login(uid, data) then
		log.debug("%d login fail, center login fail ", uid)
		msg.error = "login fail, center login fail"
		return msg
	end
	--game
	data = {
		fd = fd
	}
	local ret, game = libgame.login(uid, data)
	if not ret then
		libcenter.logout(uid, key)
		log.debug("%d login fail, load data err ", uid)
		msg.error = "login fail, load data err"
		return msg
	end
	--center
	local data = {
		game = game,
		key = key,
	}
	if not libcenter.register(uid, data) then
		libcenter.logout(uid, key)
		log.debug("%d login fail, register center fail ", uid)
		msg.error = "login fail, register center fail"
		return msg
	end
	--gate
	local data = {
		uid = uid,
		fd = fd,
		game = game,
		key = key
	}
	if not skynet.call(source, "lua", "register", data) then
		libcenter.logout(uid, key)
		log.debug("%d login fail, register gate fail ", uid)
		msg.error = "login fail, register gate fail"
		return msg
	end
	log.debug("%d login success ", uid)
	msg.uid = uid
	msg.error = "login success"
	return msg
end
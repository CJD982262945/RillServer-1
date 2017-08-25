local skynet = require "skynet"
local cluster = require "skynet.cluster"

local faci = require "faci.module"
local module = faci.get_module("login")
local dispatch = module.dispatch
local forward = module.forward
local event = module.event


env.users = env.users or {} 
--users[uid]={
	--node = skynet.getenv("nodename"),
	--fd = fd,
	--gate = source,
	--game = game的source （register后才有）
	--key = key --登录时的key，验证登录服的唯一性
--}

--true/false
function dispatch.login(uid, data)
	local user = env.users[uid]
	--正常登录
	if not user then
		env.users[uid] = data
		log.debug("center login: %d", uid)
		return true
	end
	--登录过程中
	if not user.game then
		log.debug("center %d login fail not user.game", uid)
		return false
	end
	--踢下线
	if not dispatch.logout(uid, user.key, "login in other place") then
		log.debug("center %d login fail not not D.logout", uid)
		return false
	end
	user = env.users[uid]
	if user then
		log.debug("have login uid: " .. uid)
		return false
	end
	env.users[uid] = data
	log.debug("center login: %d", uid)
	return true
end

--true/false
function dispatch.register(uid, data)
	local user = env.users[uid]
	if not user then
		log.debug("center %d register fail, not user", uid)
		return false
	end
	
	if user.key ~= data.key then
		log.debug("center %d register fail, key err", uid)
		return false
	end
	
	if user.game then
		log.debug("center %d register fail, has game", uid)
		return false
	end
	
	log.debug("center register: %d", uid)
	user.game = data.game
	return true
end

--true/false
function dispatch.logout(uid, key, season)
	local user = env.users[uid]
	if not user then
		return true
	end
	
	if user.key ~= key then
		log.debug("center logout key fail")
		return false
	end

	if user.game then
		--game
		local ret = cluster.call(user.node, user.game, "login.kick", uid, season)
		if not ret then
			log.debug("center logout call game fail")
			return false
		end
		--gate的
		local ret = cluster.call(user.node, user.gate, "kick", user.fd)
		if not ret then
			log.debug("center logout call gate fail")
			return false
		end
	end
	log.debug("center logout: %d", uid)
    env.users[uid] = nil
	return true
end



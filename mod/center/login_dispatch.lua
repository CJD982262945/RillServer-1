local skynet = require "skynet"
local cluster = require "skynet.cluster"

local faci = require "faci.module"
local module = faci.get_module("Login")
local dispatch = module.dispatch
local forward = module.forward
local event = module.event

env.users = env.users or {} 
--users[playerid]={
	--node = skynet.getenv("nodename"),
	--fd = fd,
	--gate = source,
	--game = game的source （register后才有）
	--key = key --登录时的key，验证登录服的唯一性
--}
env.logout_users = env.logout_users or {}

--true/false
function dispatch.login(playerid, data)
    -- 等待玩家下线, 做一些下线处理 
    if env.logout_users[playerid] then
		log.debug("waiting logout user: %d", playerid)
        return false
    end

	local user = env.users[playerid]
	--正常登录
	if not user then
		env.users[playerid] = data
		log.debug("center login: %d", playerid)
		return true
	end
	--登录过程中
	if not user.game then
		log.debug("center %d login fail not user.game", playerid)
		return false
	end
	--踢下线
	if not dispatch.logout(playerid, user.key, "login in other place") then
		log.debug("center %d login fail not not D.logout", playerid)
		return false
	end
	user = env.users[playerid]
	if user then
		log.debug("have login playerid: " .. playerid)
		return false
	end
	env.users[playerid] = data
	log.debug("center login: %d", playerid)
	return true
end

--true/false
function dispatch.register(playerid, data)
	local user = env.users[playerid]
	if not user then
		log.debug("center %d register fail, not user", playerid)
		return false
	end
	
	if user.key ~= data.key then
		log.debug("center %d register fail, key err", playerid)
		return false
	end
	
	if user.game then
		log.debug("center %d register fail, has game", playerid)
		return false
	end
	
	log.debug("center register: %d", playerid)
	user.game = data.game
	return true
end


local function logout_help(playerid, key, season)
	local user = env.users[playerid]
	if not user then
		return true
	end
	
	if user.key ~= key then
		log.debug("center logout key fail")
		return false
	end

	if user.game then
		--game
		local ret = cluster.call(user.node, user.game, "Login.kick", playerid, season)
		if not ret then
			log.debug("center logout call game fail")
			return false
		end
		--gate
		local ret = cluster.call(user.node, user.gate, "kick", user.fd)
		if not ret then
			log.debug("center logout call gate fail")
			return false
		end
	end
	log.debug("center logout: %d", playerid)
    env.users[playerid] = nil
	return true
end

local function traceback(err)
	log.error(tostring(err))
	log.error(debug.traceback())
end

--true/false
function dispatch.logout(playerid, key, season)
    if env.logout_users[playerid] then
        return false
    end
    env.logout_users[playerid] = true
    local isok, ret = xpcall(logout_help, traceback, playerid, key, season)
    if not isok then
        env.logout_users[playerid] = nil
        return false
    end
    env.logout_users[playerid] = nil
    return ret
end



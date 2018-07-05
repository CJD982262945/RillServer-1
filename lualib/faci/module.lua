local skynet = require "skynet"
local lfstool = require "lfstool"
local log = require "log"
local env = require "faci.env"
local event = require "faci.event"
local reload = require "reload"
local cluster = require "cluster"

local M = {}

function M.get_env(file)
	ok, result = reload.reload(file)
	return ok, result
end

function M.reload_module(file)
	ok, result = reload.reload(file)
	return ok, result
end

function M.reload_modules()
	local path = skynet.getenv("app_root").."mod/"..env.name
	lfstool.attrdir(path, function(file)
	local file = string.match(file, ".*mod/(.*)%.lua")
		if file then
			log.info(string.format("%s%d reload file:%s", env.name, env.id, file))
			ok, result = reload.reload(file)
		end
	end)
	return ok, result
end

local function require_modules()
	local path = skynet.getenv("app_root").."mod/"..env.name
	lfstool.attrdir(path, function(file)
	local file = string.match(file, ".*mod/(.*)%.lua")
		if file then
			log.info(string.format("%s%d require file:%s", env.name, env.id, file))
			require(file)
		end
	end)
end

local module = {}
function M.get_module(name)
	--模块处理函数
	env.module[name] = env.module[name] or {
		dispatch = {},
		forward = {},
		event = {},
		watch = nil,
	}
	--模块全局变量
	env.static[name] = env.static[name] or {
	}
	return env.module[name], env.static[name]
end

local local_nodename = skynet.getenv("nodename")

local event_cache = {}
function M.fire_event(name, ...)
	--获取列表
	local cache = event_cache[name]
	if not cache then
		event_cache[name] = {}
		for i, v in pairs(env.module) do
			if type(v.event[name]) == "function" then
				table.insert(event_cache[name], v.event[name])
			end
		end
	end
	cache = event_cache[name]
	--执行
	for _, fun in ipairs(cache) do
		log.info("fire event %s", name)
		xpcall(fun,  function(err) 
			log.error(tostring(err))
			log.error(debug.traceback())
		end, ...)
	end
    --远程事件
    local events = env.events[name]
    if not events then
        return
    end
    for nodename, nodes in pairs(events) do
        for service, keys in pairs(nodes) do
            if nodename == localname then
                skynet.send(service, name, keys, ...)
            else
                cluster.send(nodename, service, name, keys, ...)
            end
        end
    end
end


function M.subscribe_event(event, nodename, service, key)
    local local_service = skynet.self()
    if nodename == local_nodename then
        return skynet.call(service, "sys.subscribe_event", event, local_nodename, local_service, key)
    end

    return cluster.call(nodename, service, "sys.subscribe_event", event, local_nodename, local_service, key)
end

function M.unsubscribe_event(event, nodename, service, key)
    local local_service = skynet.self()
    if nodename == localnode then
        return skynet.call(service, "sys.unsubscribe_event", event, local_nodename, local_service, key)
    end

    return cluster.call(nodename, service, "sys.unsubscribe_event", event, local_nodename, local_service, key)
end

function M._subscribe_event(event, nodename, service, key)
    if not env.events[event] then
        env.events[event] = {} 
    end
    if not env.events[event][nodename] then
        env.events[event][nodename] = {} 
    end
    if not env.events[event][nodename][service] then
        env.events[event][nodename][service] = {}
    end
    if not env.events[event][nodename][service][key] then
        env.events[event][nodename][service][key] = {}
    end

    env.events[event][nodename][service][key] = true
end

function M._unsubscribe_event(event, nodename, service, key)
    if not env.events[event] or not env.events[event][nodename] then
        log.error(string.format("unsubscribe event %s %s %s", event, nodename, service))
        return
    end
    if not env.events[event][nodename][service][key] then
        log.error(string.format("unsubscribe event %s %s %s %s", event, nodename, service, key))
        return
    end

    env.events[event][nodename][service][key] = nil
end

function M.init_modules()
	require_modules()
end


return M

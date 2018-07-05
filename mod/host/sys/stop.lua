local skynet = require "skynet"
local cluster = require "skynet.cluster"
local tool = require "tool"

local faci = require "faci.module"
local module = faci.get_module("Sys")
local dispatch = module.dispatch
local forward = module.forward
local event = module.event

local runconf = require(skynet.getenv("runconfig"))
local local_nodename = skynet.getenv("nodename") 

local stop_order = {
    "gateway",
    "login",
    "center",
    "game",
    "scene",
    "global",
    "dbproxy",
}

--由其他host调用
function dispatch.host_stop(name)
	local services = skynet.call(".launcher", "lua", "LIST")
	for k, v in pairs(services) do
		local n = string.match(v, "snlua (%w+) *.*")
		if n == name then
			skynet.call(k, "lua", "faci.stop")
		end
	end

	for k, v in pairs(services) do
		local n = string.match(v, "snlua (%w+) *.*")
		if n == name then
			skynet.send(k, "lua", "faci.exit")
		end
	end

    return true
end

function dispatch.host_abort()
    skynet.abort()
end

local function stop(name)
    log.debug("===start stop, name: " .. name)
	for node, _ in pairs(runconf.cluster) do
        if node == local_nodename then
           skynet.call("host", "lua", "Sys.host_stop", name) 
        else
           cluster.call(node, "host", "Sys.host_stop", name)
        end
	end
    log.debug("===end stop, name: " .. name)
end

function dispatch.stop()
    for _, name in ipairs(stop_order) do
        stop(name) 
    end

	for node, _ in pairs(runconf.cluster) do
        if node ~= local_nodename then
           cluster.send(node, "host", "Sys.host_abort")
        end
	end

    skynet.call("host", "lua", "Sys.host_abort") 
    log.debug("stop service success~~")
    return true
end


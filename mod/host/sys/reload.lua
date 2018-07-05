local skynet = require "skynet"
local cluster = require "skynet.cluster"
local runconf = require(skynet.getenv("runconfig"))
local tool = require "tool"

local faci = require "faci.module"
local module = faci.get_module("Sys")
local dispatch = module.dispatch
local forward = module.forward
local event = module.event

local local_nodename = skynet.getenv("nodename")


function dispatch.host_reload_mod(mod)
	local service_name = mod.name
	local modname = mod.modname or "ALL"
	log.debug("start reload %s ...", mod)
	
	local list = {}
	local services = skynet.call(".launcher", "lua", "LIST")
    for k, v in pairs(services) do
        local cmd = string.match(v, "snlua (%w+) *.*")
        if cmd == service_name then
			log.debug("reload %s", cmd)
            local diff_time = skynet.call(k, "debug", "RELOAD", mod)
            list[skynet.address(k)] = string.format("%.2fs (%s)", diff_time, v)
        end
    end
	log.info("host_mod %s", tool.dump(list))
	return list
end


function dispatch.host_setup(tb_mod)
    local mod = tb_mod.mod 
	--全服
	if not mod then
		local ret = skynet.call("setup", "lua", "setup.update_all")
		return ret
	end
	--某个模块 eg:itemlist
	local ret = skynet.call("setup", "lua", "setup.update", mod)
    return ret
end

--
--
--
function dispatch.setup(name)
	for node, _ in pairs(runconf.cluster) do
        if node == local_nodename then
           skynet.call("host", "lua", "Sys.host_reload_setup", name) 
        else
           cluster.call(node, "host", "Sys.host_reload_setup", name)
        end
    end
    return true
end

function dispatch.reload_mod(mod)
	log.debug("start reload_mod %s ...", tool.dump(mod))
	for node, _ in pairs(runconf.cluster) do
        if node == local_nodename then
           skynet.call("host", "lua", "Sys.host_reload_mod", mod) 
        else
           cluster.call(node, "host", "Sys.host_reload_mod", mod)
        end
    end
    return true
end




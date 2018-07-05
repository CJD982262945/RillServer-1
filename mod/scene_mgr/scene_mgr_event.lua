local skynet = require "skynet"
local tool = require "tool"
local faci = require "faci.module"
local libsetup = require "libsetup"
local cluster = require "cluster"


local runconf = require(skynet.getenv("runconfig"))

local module, static = faci.get_module("SceneMgr")
local dispatch = module.dispatch
local forward = module.forward
local event = module.event

local servconf = runconf.service
local local_nodename = skynet.getenv("nodename")

local function get_node_name(scene_id)
  local scene_nodes = servconf.scene
  assert(type(scene_nodes) == "table")

  local scene_node_num = #servconf.scene
  local id = scene_id % scene_node_num + 1
  local node_name = scene_nodes[id]
  assert(type(node_name) == "string")

  return node_name
end

function event.start()

      local scene_conf = libsetup.scene  
      for i, v in pairs(scene_conf) do
        local node_name = get_node_name(i)
        local name = string.format("scene%d", i)
        if local_nodename == node_name then
            skynet.newservice("scene", "scene", i)
        else
            local proxy = cluster.proxy(node_name, name)
            skynet.name(name, proxy)
        end
      end

      log.debug("start scene mgr success~~")
      skynet.exit()

end




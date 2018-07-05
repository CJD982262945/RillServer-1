local skynet = require "skynet"
local tool = require "tool"

local libdbproxy = require "libdbproxy"

local runconf = require(skynet.getenv("runconfig"))
local dbconf = runconf.service.dbproxy_common

local faci = require "faci.module"
local module, static = faci.get_module("Dbproxy")
local dispatch = module.dispatch
local forward = module.forward
local event = module.event


env.db = env.db or {
	["account"] = nil,
	["game"] = nil,
	["global"] = nil,
	["log"] = nil,
}

local function init_db(conf)
    local db_type = conf.db_type
    local dbc = require(db_type)
	return dbc:start(conf)
end

function event.start()
    local db = env.db

	db.account = init_db(dbconf.accountdb)
    db.game = init_db(dbconf.gamedb)
	db.global = init_db(dbconf.globaldb)
	db.log = init_db(dbconf.logdb)
end

function event.exit()
end




local skynet = require "skynet"
local tool = require "tool"

local runconf = require(skynet.getenv("runconfig"))
local dbconf = runconf.service.dbproxy_common

local faci = require "faci.module"
local module = faci.get_module("Dbproxy")
local dispatch = module.dispatch
local forward = module.forward
local event = module.event


function dispatch.get(dbname, tb_cname, select)  --cname -> collection name
    local db = env.db
	return db[dbname]:findOne(tb_cname, select)
end

function dispatch.set(dbname, tb_cname, select, tb_update)
    local db = env.db
	return db[dbname]:update(tb_cname, select, tb_update, true)
end

function dispatch.insert(dbname, tb_cname, tb_data)
    local db = env.db
	return db[dbname]:insert(tb_cname, tb_data)
end




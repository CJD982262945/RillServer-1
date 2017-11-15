local skynet = require "skynet"
local tool = require "tool"

local runconf = require(skynet.getenv("runconfig"))
local dbconf = runconf.service.dbproxy_common

local faci = require "faci.module"
local module = faci.get_module("dbproxy")
local dispatch = module.dispatch
local forward = module.forward
local event = module.event

local db = {
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

function event.awake()
	db.account = init_db(dbconf.accountdb)
    db.game = init_db(dbconf.gamedb)
	db.global = init_db(dbconf.globaldb)
	db.log = init_db(dbconf.logdb)
end

function dispatch.get(dbname, cname, select)  --cname -> collection name
	return db[dbname]:findOne(cname, select)
end

function dispatch.set(dbname, cname, select, update)
	return db[dbname]:update(cname, select, update, true)
	
end

function dispatch.insert(dbname, cname, data)
	db[dbname]:insert(cname, data)
end




--发号器  临时方案
local maxuid = 0
function event.start()
	local ret =  db["account"]:findOne("tb_key", {key="account"})
	if ret then
        maxuid = ret.uuid
    end
end

function event.exit()
	db["account"]:update("tb_key", {key="account"}, {key="account", uuid=maxuid}, true)
end

--原来方案有数据竞争问题，协程中调用数据库，协程会被挂起
--中途会执行其他协程
function dispatch.incr(dbname, cname)
    --return db[dbname]:incr(cname)
	
	--这一行存储只是防止停服，也会有竞争问题
	db["account"]:update("tb_key", {key="account"}, {key="account", uuid=maxuid+1}, true)
	maxuid = maxuid + 1
	return maxuid
end

--[[
local db
function dispatch.start(conf)
    local db_type = conf.db_type
    db = require(db_type) 
    db.start(conf)
end

function dispatch.findOne(cname, selector, field_selector)
    return db.findOne(cname, selector, field_selector)
end

function dispatch.find(cname, selector, field_selector)
    return db.find(cname, selector, field_selector)
end

function dispatch.update(cname, selector, update, upsert)
    return db.update(cname, selector, update, upsert)
end

function dispatch.insert(cname, data)
    return db.insert(cname, data)
end

function dispatch.delete(cname, selector)
    return db.delete(cname, selector)
end

function dispatch.incr(key)
    return db.incr(key)
end
--]]

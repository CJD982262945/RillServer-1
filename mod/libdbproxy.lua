local skynet = require "skynet"
local log = require "log"

local runconf = require(skynet.getenv("runconfig"))
local servconf = runconf.service
local MAX_DBPROXY_COUNT = #servconf.dbproxy

local M = {}
local dbproxy = {}

local function init()
    log.debug("init libdbproxy")
    for i = 1, MAX_DBPROXY_COUNT do
        dbproxy[i] = string.format("dbproxy%d", i) 
    end
end

local next_id = 1
local function next_dbproxy()
    next_id = next_id + 1
    next_id = next_id % MAX_DBPROXY_COUNT + 1
    return dbproxy[next_id]
end

local function fetch_dbproxy(key)
    if type(key) == "number" then
        local id = key % MAX_DBPROXY_COUNT + 1 
        return dbproxy[id]
    else
        return next_dbproxy()
    end
end

function M.get_accountdata(account)
    local db = fetch_dbproxy(account)
    assert(db)
    return skynet.call(db, "lua", "dbproxy.get", "account", "account", {account=account})
end

function M.set_accountdata(account, update)
    local db = fetch_dbproxy(uid)
    assert(db)
    return skynet.call(db, "lua", "dbproxy.set", "account", "account", {account=account}, update)
end

function M.get_playerdata(cname, uid)
    local db = fetch_dbproxy(uid)
    assert(db)
    return skynet.call(db, "lua", "dbproxy.get", "game", cname, {uid=uid})
end

function M.set_playerdata(cname, uid, update)
    local db = fetch_dbproxy(uid)
    assert(db)
    return skynet.call(db, "lua", "dbproxy.set", "game", cname, {uid=uid}, update)
end

function M.get_globaldata(cname, key)
    local db = fetch_dbproxy(uid)
    assert(db)
    return skynet.call(db, "lua", "dbproxy.get", "global", cname, {name=key})
end

function M.set_globaldata(cname, key, update)
    local db = fetch_dbproxy(uid)
    assert(db)
    return skynet.call(db, "lua", "dbproxy.set", "global", cname, {name=key}, update)
end

function M.add_dblog(cname, data)
    local db = fetch_dbproxy(uid)
    assert(db)
    return skynet.call(db, "lua", "dbproxy.insert", "log", cname, data)
end

function M.inc_uid()
    local db = fetch_dbproxy(1)
    assert(db)
    return skynet.call(db, "lua", "dbproxy.incr", "account", "account")
end

--[[
function M.findOne(key, cname, selector, field_selector)
    local db = fetch_dbproxy(key)
    assert(db)
    return skynet.call(db, "lua", "dbproxy.findOne", cname, selector, field_selector)
end

function M.find(key, cname, selector, field_selector)
    local db = fetch_dbproxy(key)
    assert(db)
    return skynet.call(db, "lua", "dbproxy.find", cname, selector, field_selector)
end

function M.update(key, cname, selector, update, upsert)
    local db = fetch_dbproxy(key)
    assert(db)
    return skynet.call(db, "lua", "dbproxy.update", cname, selector, update, upsert)
end

function M.insert(key, cname, data)
    local db = fetch_dbproxy(key)
    assert(db)
    return skynet.call(db, "lua", "dbproxy.insert", cname, data)
end

function M.delete(key, cname, selector)
    local db = fetch_dbproxy(key)
    assert(db)
    return skynet.call(db, "lua", "dbproxy.delete", cname, selector)
end


--]]

skynet.init(init)

return M



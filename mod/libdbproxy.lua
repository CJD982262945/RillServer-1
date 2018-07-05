local skynet = require "skynet"
local log = require "log"
local crc32 = require "crc32" 

local runconf = require(skynet.getenv("runconfig"))
local servconf = runconf.service
local MAX_DBPROXY_COUNT = #servconf.dbproxy

local M = {}
local dbproxy = {}

local function init()
    log.debug("init libDbproxy")
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
    end

    if type(key) == "string" then
		local code = crc32.hash(key)
        local id = code % MAX_DBPROXY_COUNT + 1 
        return dbproxy[id]
    end

    return next_dbproxy()
end

function M.get_accountdata(account)
    local db = fetch_dbproxy(account)
    assert(db)
    local ret = skynet.call(db, "lua", "Dbproxy.get", "account", 
                                                            {account=true}, 
                                                            {account=account}
                                                            )
    return ret.account
end

function M.set_accountdata(account, update)
    local db = fetch_dbproxy(playerid)
    assert(db)
    local ret = skynet.call(db, "lua", "Dbproxy.set", "account", 
                                                            {account=account},
                                                            {account=update})
    return table.unpack(ret.account)
end



function M.get_playerdata(tb_cname, playerid)
    local db = fetch_dbproxy(playerid)
    assert(db)
    return skynet.call(db, "lua", "Dbproxy.get", "game", tb_cname, {playerid=playerid})
end

function M.set_playerdata(playerid, update)
    local db = fetch_dbproxy(playerid)
    assert(db)
    return skynet.call(db, "lua", "Dbproxy.set", "game", {playerid=playerid}, update)
end


function M.get_globaldata(tb_cname, key)
    local db = fetch_dbproxy(key)
    assert(db)
    return skynet.call(db, "lua", "Dbproxy.get", "global", tb_cname, {name=key})
end

function M.set_globaldata(tb_cname, key, update)
    local db = fetch_dbproxy(key)
    assert(db)
    return skynet.call(db, "lua", "Dbproxy.set", "global", {name=key}, update)
end


skynet.init(init)

return M



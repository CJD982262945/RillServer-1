local skynet = require "skynet"
local mongo = require "mongo"
local bson = require "bson" 
local log = require "log"
local tool = require "tool"


local mongodb = {}
mongodb.__index = mongodb


local function db_help(db, cmd, cname, ...)
    local c = db[cname]
    c[cmd](c, ...)
    local r = db:runCommand('getLastError')
    local ok = r and r.ok == 1 and r.err == bson.null
    if not ok then
        skynet.error(v.." failed: ", r.err, tname, ...)
    end
    return ok, r.err   
end

function mongodb:start(conf)
    local host = conf.host
    local db_name = conf.db_name
    local db_client = mongo.client({host = host})
    local db = db_client[db_name]
	
	local o = {db = db}
	setmetatable(o, mongodb)
	return o
end

function mongodb:findOne(tb_cname, selector, tb_field_selector)
	local db = self.db

    tb_cname = tb_cname or {}
    tb_field_selector = tb_field_selector or {}

    local rets = {}
    for k, v in pairs(tb_cname) do
        local cname = k
        local field_selector = tb_field_selector[k]
        local ret = db[cname]:findOne(selector, field_selector)
        rets[k] = ret 
    end
    return rets
end

function mongodb:update_help(cname, selector, update, upsert)
	local db = self.db
	local collection = db[cname]
	
	collection:update(selector, update, upsert)
	local r = db:runCommand("getLastError")
	if r.err ~= bson.null then
        skynet.error("update err: " .. r.err)
		return false, r.err
	end

	if r.n <= 0 then
		skynet.error("mongodb update "..cname.." failed")
	end
	 skynet.error("update finish "..r.n)
	return true, r.err
end

function mongodb:update(selector, tb_update, upsert)
    tb_update = tb_update or {}

    local ret = {}
    for k, v in pairs(tb_update) do
        local cname = k
        local update = v
        --log.debug("==update, cname: " .. cname .. tool.dump(update))
        --log.debug("==update, selector: " .. tool.dump(selector))
        local ok, err = self:update_help(cname, selector, update, upsert)
        ret[k] = { ok, err }
    end
    return ret
end

function mongodb:insert(tb_cname, tb_data)
	local db = self.db
    
    local ret = {}
    for k, v in pairs(tb_cname) do
        local cname = k
        local data = tb_data[k]
        local ok, err = db_help(db, "safe_insert", cname, data)
        ret[k] = {ok, err}
    end

    return ret
end

function mongodb:delete(tb_cname, selector)
	local db = self.db

    local ret = {}
    for k, v in pairs(tb_cname) do
        local cname = k
        local ok, err = db_help(db, "delete", cname, selector)
        ret[k] = {ok, err}
    end
    return ret
end

return mongodb


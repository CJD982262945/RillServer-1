
local genid = {}
local id = 1

function genid.new_id()
    id = id + 1
    return id
end

return genid

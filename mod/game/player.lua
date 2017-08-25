
local Player = {}

Player.__index = Player

function Player.new(o)
    local o = o or {
		uid = -1,
		fd	= -1,
		romote = {}, --记录的forward路由
		data = {
			--baseinfo = {name,register_time,login_time}
		}
	}
    setmetatable(o, Player)
    return o
end

return Player


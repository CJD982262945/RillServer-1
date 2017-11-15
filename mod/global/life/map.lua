local skynet = require "skynet"
local log = require "log"
local libcenter = require "libcenter"
local tool = require "tool"


local faci = require "faci.module"
local module, static = faci.get_module("life")
local dispatch = module.dispatch
local forward = module.forward

static.MAP_HEIGHT = 568 + 40 --40Ϊ�½�����
static.DEFAULT_SPEED = 40 --40.0ÿ�����,40Ϊһ������

static.buildcfg = {
	[201] = {"Сѧxxxx"},
	[202] = {"Сѧxxxx"},
	[203] = {"Сѧxxxx"},
	[204] = {"Сѧxxxx"},
	[205] = {"Сѧxxxx"},
	[206] = {"Сѧxxxx"},
	[207] = {"Сѧxxxx"},
	[208] = {"Сѧxxxx"},
}

--map = {
--		ÿ������40*40
--		0-�� 1-���� 101��� 201Сѧ 202��ѧ 203��ѵ
--		204�ֿ�Ա 205����Ա 206���ھ�� 207���ּ� 208����
--			[row] = {1,101,1,0,0,0,0,0}
--		}


local buildingmaping --[1] = 201  [2] = 202
local buildinglen
local function get_random_building()
	--maping
	if not buildingmaping then
		buildingmaping = {}
		buildinglen = 0
		for i, v in pairs(static.buildcfg) do
			table.insert(buildingmaping, i)
		end
		buildinglen = #buildingmaping
	end
	--
	local index = math.random(1,buildinglen)
	return buildingmaping[index]
end

--���������ɵ�rowid {}
local function generate_row(room, row_id)
	local map = room.map
	--���ɵ��� mod 1�� 2�� 3�п�1 4�п�2
	local mod = math.random(1, 4)
	local row = {0,0,0,0,0,0,0,0}
	local blocknum = 0
	if mod == 1 then
		local pos = math.random(2, 6)
		for i = 1, pos do row[i] = 1 end
		blocknum = pos
	elseif mod == 2 then
		local pos = math.random(3, 7)
		for i = pos, 8 do row[i] = 1 end
		blocknum = 8 - pos
	elseif mod == 3 then
		local pos = math.random(2, 7)
		for i = 1, pos-1 do row[i] = 1 end
		for i = pos+1, 8 do row[i] = 1 end
		blocknum = 7
	elseif mod == 4 then
		local pos = math.random(2, 6)
		for i = 1, pos-1 do row[i] = 1 end
		for i = pos+2, 8 do row[i] = 1 end
		blocknum = 6
	end
	map[row_id+3] = row
	--���ɽ���
	local row2 = {0,0,0,0,0,0,0,0}
	local num = math.random(0, math.ceil(blocknum/4))
	for i = 1, num do
		for times=1,4 do  --�����ɼ���break��continue�� ����ೢ��4��
			local pos = math.random(1, blocknum)
			if row[pos] == 1 and row2[pos] == 0 then
				row2[pos] = get_random_building()
				break
			end
		end
	end
	--���ɽ��
	for i = 1, 8 do
		if row[i] == 1 and row2[i] == 0 and math.random(1,100) < 30 then
			row2[i] = 101
		end
	end
	map[row_id+2] = row2
	--������
	map[row_id+1] = {0,0,0,0,0,0,0,0}
	return {row_id+1, row_id+2, row_id+3}
end

--����row,index
function static.coor2map(y, x)
	local row = math.floor(y/40) + 1 
	local index = math.floor(x/40) + 1 
	return row, index
end

function static.updatemap(room, deltaTime)
	--���������
	room.top = room.top + room.descent_speed*deltaTime
	--log.debug("updatemap top="..room.top.. "  \t\t"..deltaTime)
	local bottom = room.top + 15*40
	--�����µ�
	local brow, _ = static.coor2map(bottom, 0) --bottom_row
	local newrows = nil
	if not room.map[brow+1] then
		newrows = generate_row(room, brow)
		--log.debug("generate_row room(%d) row(%d)", room.id, brow)
	end
	--�㲥�µ�
	if newrows then
		local msg = {top=room.top, rows={}}
		for _, row in pairs(newrows) do
			msg.rows[row] = room.map[row]
		end
		dispatch.broadcast(room, "life.update_map", msg)
	end
	--ɾ���ɵ�
	local trow, _ = static.coor2map(room.top, 0) --top_row
	for i=trow-1, 1, -1 do
		if room[trow] then
			room[trow] = nil
		else
			break
		end
	end
end

function static.init_map(room)
	for i = 1,16,3 do
		generate_row(room, i-1)
	end
end

--0-zero 1-floor 2-other
function static.rowtype(row)
	local zerocount = 0
	for i=1, #row do
		if row[i] == 0 then zerocount = zerocount + 1
		elseif row[i] > 1  then return 2 end
	end
	
	if zerocount == #row then return 0
	else return 1 end
end
function static.born_point(room)
	--row ���м��ѡȡ�յ�һ��
	local y = 0
	local row = 0
	local trow, _ = static.coor2map(room.top, 0)
	for i=trow+6, trow+13 do
		if static.rowtype(room.map[i]) == 0 then
			row = i
			y = (i-1)*40
			break
		end
	end
	--x
	local x = math.random(0+30, 320-30)
	--face
	local f = 1
	if x <= 160 then f = -1 else f = 1 end
	return y, x, f
end
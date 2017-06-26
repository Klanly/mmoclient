---------------------------------------------------
-- auth： panyinglong
-- date： 2016/12/6
-- desc： 场景分线管理
---------------------------------------------------
require "Common/basic/LuaObject"
local constant = require "Common/constant"
local parameterTable = GetConfig('common_parameter_formula')
local log = require "basic/log"
local maxNum = parameterTable.Parameter[32].Parameter

local getLineStatus = function(num)
	local crowdedness = num / maxNum * 100
	local status = 999
	for k, v in pairs(parameterTable.LineStatus) do
		if crowdedness >= v.Crowdedness and status > v.ID then
			status = v.ID
		end
	end
	if status == 999 then
		error('没有找到当前的 line status num=' .. num)
	end
	return status
end

local function CreateSceneLineManager()
	local self = CreateObject()
	self.curLineId = 0
	self.curLines = {}

	local event = CreateEvent()

	self.OnUpdateGameLineRet = function(data)
		print('update curr game line gameid=' .. data.game_id)
		self.curLineId = data.game_id
		event.Brocast('__OnLineInfoChange', 'current')
		ConnectionManager.SyncMainTime()
	end

	self.QuerySceneLines = function()
		local data = {}
		data.func_name = 'on_query_scene_lines'
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)	
	end
	self.OnQuerySceneLinesRet = function(data)
		table.print(data, 'lines data')
		self.curLines = {}
		for k, v in pairs(data.lines) do
			self.curLines[v.key] = getLineStatus(v.value)
		end
		event.Brocast('__OnLineInfoChange', 'all')
	end


	self.ChangeGameLine = function(game_id,follow)
		if SceneManager.IsOnFightServer() then
			print('战斗场景不能切分线')
			return
		end
		if tostring(self.curLineId) == tostring(game_id) then
			print('当前已经在该分线了')
			return
		end
		print('请求切分线 id=' .. game_id)
		local data = {}
		data.func_name = 'on_change_game_line'
		data.game_id = game_id
		data.follow = follow
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)		
	end
	self.OnChangeGameLineRet = function(data)
		print('切分线反馈')
	end

	local init = function()
		MessageRPCManager.AddUser(self, 'OnUpdateGameLineRet') 
		MessageRPCManager.AddUser(self, 'OnQuerySceneLinesRet') 
		MessageRPCManager.AddUser(self, 'OnChangeGameLineRet') 
	end

	self.clear = function()
		MessageRPCManager.RemoveUser(self, 'OnUpdateGameLineRet') 
		MessageRPCManager.RemoveUser(self, 'OnUpdateGameLineRet') 
		MessageRPCManager.RemoveUser(self, 'OnUpdateGameLineRet') 
	end
	
	self.AddListener = function(func)
		event.AddListener('__OnLineInfoChange', func)
	end
	self.RemoveListener = function(func)
		event.RemoveListener('__OnLineInfoChange', func)
	end
	init()

	return self
end

SceneLineManager = SceneLineManager or CreateSceneLineManager()
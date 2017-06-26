---------------------------------------------------
-- auth： panyinglong
-- date： 2016/9/20
-- desc： 任务副本管理
---------------------------------------------------
require "Common/basic/LuaObject"
require "Network/MessageManager"
require "Logic/SceneManager"
local CreateDungeonManager = require "Logic/DungeonManager"
local log = require "basic/log"

function CreateTaskDungeonManager()
	local self = CreateDungeonManager()
	self.isDungeonFinished = true
	-- self.currentDungeonTaskData = nil
	self.taskId = nil
	self.taskDungeonId = nil

	local enterDungeonCallback = nil
	self.RequestEnterTaskDungeon = function(taskData, callback)
		local data = {}
		data.task_id = taskData.id
		data.func_name = 'on_enter_task_dungeon'
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
		log('task', '请求进入任务副本　send on_receive_daily_cycle_task ')
		enterDungeonCallback = callback

		-- self.currentDungeonTaskData = taskData
	end	
	self.EnterTaskDungeonRet = function(data)
		log('task', '进入任务副本反馈')
   		self.taskId = data.task_id
   		if enterDungeonCallback then
   			enterDungeonCallback()
   		end
   		enterDungeonCallback = nil
	end
	self.ConnectTaskDungeonServerReply = function(data)
		log('task', '成功连接战斗服务推送')
	end
	self.PlayerLeaveTaskDungeonScene = function(data)
		log('task', '离开任务副本推送')
		self.taskDungeonId = nil
	end
	-- 副本结束
	self.TaskDungeonEndRet = function(data) 
		log('task', '任务副本结束推送')
		-- self.taskId = nil
		local delay = GetConfig('challenge_main_dungeon').Parameter[18].Value[1]/1000
		Timer.Delay(delay, function()
			if SceneManager.IsOnDungeonScene() then
                UIManager.GetCtrl(ViewAssets.MainLandUI).hide()
				UIManager.PushView(ViewAssets.ChallengeOverUI,nil,data)
			end
		end)	
		self.isDungeonFinished = true	
	end	
	-- 请求退出战斗副本
	self.RequestLevelTaskDungeon = function()
		local data = {}
		-- data.task_id = self.taskId
		data.func_name = 'on_leave_task_dungeon'
		MessageManager.RequestLua(constant.CD_MESSAGE_LUA_GAME_RPC, data)
		log('task', '请求离开任务副本　send on_leave_task_dungeon ')
	end
	-- 正在打副本
	self.IsOnDungeoning = function()
		return (
			SceneManager.currentSceneType == constant.SCENE_TYPE.TASK_DUNGEON and
			SceneManager.currentFightType == constant.FIGHT_SERVER_TYPE.TASK_DUNGEON)
	end
	self.OnEnterFightScene = function(dungeonId)
		self.isDungeonFinished = false
		self.taskDungeonId = dungeonId
	end

	local init = function()		
		-- 任务副本　
		MessageRPCManager.AddUser(self, 'EnterTaskDungeonRet') 
		MessageRPCManager.AddUser(self, 'ConnectTaskDungeonServerReply')
		MessageRPCManager.AddUser(self, 'PlayerLeaveTaskDungeonScene')
		MessageRPCManager.AddUser(self, 'TaskDungeonEndRet')
		MessageRPCManager.AddUser(self, 'UpdateDungeonMark')
	end
	self.UpdateDungeonMark = function(data)
        self.markData = {}
		self.markData.mark = data.mark
		self.markData.start_time = data.start_time
		self.markData.current_wave = data.current_wave
		self.isDungeonFinished = data.over
	end
	init()
	return self
end

TaskDungeonManager = TaskDungeonManager or CreateTaskDungeonManager()
---------------------------------------------------
-- auth： panyinglong
-- date： 2017/3/7
-- desc： 任务管理
---------------------------------------------------

require "Common/basic/LuaObject"
require "Logic/Task/talkTaskData"

local taskConfig = GetConfig('system_task')
local const = require "Common/constant"
local log = require "basic/log"

require 'Logic/TaskDungeonManager'

require "Logic/Task/collectTaskData"
require "Logic/Task/dailyActivityTaskData"
require "Logic/Task/escortTaskData"
require "Logic/Task/fightPowerTaskData"
require "Logic/Task/gatherTaskData"
require "Logic/Task/killMonsterTaskData"
require "Logic/Task/killPlayerTaskData"
require "Logic/Task/levelTaskData"
require "Logic/Task/mainDungeonTaskData"
require "Logic/Task/systemOperationTaskData"
require "Logic/Task/talkBackTaskData"
require "Logic/Task/talkTaskData"
require "Logic/Task/teamDungeonTaskData"
require "Logic/Task/triggerMechanismTaskData"
require "Logic/Task/useItemTaskData"
require "Logic/Task/expressTaskData"
require "Logic/Task/taskDungeonTaskData"

local function _CreateTaskData(config)
	if config.TaskType == const.TASK_TYPE.collect then 			--收集/快递任务
		if config.CompleteTaskParameter2 == nil or config.CompleteTaskParameter2 == '' then -- 有没有杂货铺UI参数
			return CreateExpressTaskData(config)
		else
			return CreateCollectTaskData(config)
		end
	elseif config.TaskType == const.TASK_TYPE.escort then 		--护送任务
		return CreateEscortTaskData(config)
	elseif config.TaskType == const.TASK_TYPE.talk then   		--定点对话任务
		return CreateTalkTaskData(config)
	elseif config.TaskType == const.TASK_TYPE.use_item then  	--定点使用道具
		return CreateUseItemTaskData(config)
	elseif config.TaskType == const.TASK_TYPE.trigger_mechanism then --定点触发机关
		return CreateTriggerMechanismTaskData(config)
	elseif config.TaskType == const.TASK_TYPE.kill_monster then  --杀怪任务
		return CreateKillMonsterTaskData(config)
	elseif config.TaskType == const.TASK_TYPE.kill_player then   --击杀玩家
		return CreateKillPlayerTaskData(config)
	elseif config.TaskType == const.TASK_TYPE.daily_activity then --日常活动挑战
		return CreateDailyActivityTaskData(config)
	elseif config.TaskType == const.TASK_TYPE.main_dungeon then  --主线关卡挑战
		return CreateMainDungeonTaskData(config)
	elseif config.TaskType == const.TASK_TYPE.team_dungeon then  --组队副本挑战
		return CreateTeamDungeonTaskData(config)
	elseif config.TaskType == const.TASK_TYPE.level then  		--等级指标
		return CreateLevelTaskData(config)
	elseif config.TaskType == const.TASK_TYPE.fight_power then   --战斗力指标
		return CreateFightPowerTaskData(config)
	elseif config.TaskType == const.TASK_TYPE.gather then   		--采集
		return CreateGatherTaskData(config)
	elseif config.TaskType == const.TASK_TYPE.system_operation then  --系统操作
		return CreateSystemOperationTaskData(config)
	elseif config.TaskType == const.TASK_TYPE.talk_back then   	--对话并返回
		return CreateTalkBackTaskData(config)
	elseif config.TaskType == const.TASK_TYPE.task_dungeon then -- 任务副本
		return CreateTaskDungeonTaskData(config)
	else
		error('未知的任务类型 taskType=' .. config.TaskType)
	end		
end

local function CreateTaskManager()
	local self = CreateObject()
	self.isReady = false
	self.countryTaskConfig = nil
	self.countryTaskStartId = nil
	local taskDatas = {}

	self.mainTaskId = nil
	-- 环任务
	self.cycleTaskCount = 0
	self.cycleTaskMaxCount = taskConfig.Parameter[4].Value
	self.cycleTaskLevel = taskConfig.Parameter[5].Value
	self.cycleTaskMemNum = taskConfig.Parameter[6].Value
	-- 阵营任务
	self.countryTaskCurrentCount = 0
	self.countryTaskCurrentTurn = 0  
	self.countryTaskRoundCount = taskConfig.Parameter[7].Value -- 每环多少次
	self.countryTaskMaxRewardCount = taskConfig.Parameter[8].Value -- 每天奖励最多多少次

	-- 事件监听
	local event = CreateEvent()
	local eventKey = 'OnTaskDataUpdate'
	self.AddListener = function(func)
		event.AddListener(eventKey, func)
	end
	self.RemoveListener = function(func)
		event.RemoveListener(eventKey, func)
	end
	----------------------
	self.GetDoingAndDoneTaskData = function()
		local datas = {}
		table.sort(taskDatas, function(a, b)
			return a.id < b.id
		end)
		for _, v in ipairs(taskDatas) do
			if v.isActive then
				table.insert(datas, v)
			else
				if v.taskSort == const.TASK_SORT.main and v.id <= self.mainTaskId then
					table.insert(datas, v)
				end
			end
		end
		table.sort(datas, function(a, b)
			return a.id < b.id
		end)
		return datas
	end
	-- 只限主线任务, 其他任务没有chapterId
	self.IsChapterDone = function(chapterId)
		for _, v in ipairs(taskDatas) do
			if v.chapter and v.chapter == chapterId then
				if v.state < const.TASK_STATE.done then
					return false
				end
			end
		end
		return true
	end
	self.GetActiveTaskData = function()
		local activeDatas = {}
		for k, v in ipairs(taskDatas) do
			if v.isActive then
				table.insert(activeDatas, v)
			end
		end
		return activeDatas
	end
	self.GetActiveTaskDataOfSort = function(taskSort)
		local activeDatas = {}
		for k, v in ipairs(taskDatas) do
			if v.isActive and v.taskSort == taskSort then
				table.insert(activeDatas, v)
			end
		end
		return activeDatas
	end

	self.GetNpcTaskData = function(npcscenetype, npcsceneid, npcid) -- 场景元素id
		local matchTaskdatas = {}
		for k, v in ipairs(taskDatas) do	
			if v.isTargetNPC(npcscenetype, npcsceneid, npcid) then
				table.insert(matchTaskdatas, v)
			end
		end
		return matchTaskdatas
	end

	self.GetTaskData = function(taskid)
		for k, v in ipairs(taskDatas) do
			if v.id == taskid then
				return v
			end
		end
		return nil
	end
	-- rpc
	self.GetTaskInfoRet = function(data)
		self.mainTaskId = data.task.main_task_id
		self.cycleTaskCount = data.task.daily_cycle_task_current_count
        
		self.countryTaskCurrentCount = data.task.country_task_current_count
		self.countryTaskCurrentTurn = data.task.country_task_current_turn

		log('task', table.toString(data, 'GetTaskInfoRet'))

		for k, v in ipairs(taskDatas) do
			v.isActive = false
			if v.taskSort == const.TASK_SORT.main then
				if v.id < self.mainTaskId then -- 主线任务小于mainTaskId, 都是已经完成的
					v.state = const.TASK_STATE.done
				else
					v.state = const.TASK_STATE.unknown
				end
			end
		end
		if data.task and data.task.task_list then
			for taskid, task in pairs(data.task.task_list) do
				local taskdata = self.GetTaskData(taskid)
				if taskdata then
					taskdata.isActive = true
					taskdata.Updata(task)
				else
					log('task', '没有找到task id=' .. taskid)
				end
			end
		end
		event.Brocast(eventKey, self.GetActiveTaskData(), 'update')		
	end
	self.UpdateTaskInfo = function()
		log('task', 'send on_get_task_info')
		local data = {}
		data.func_name = 'on_get_task_info'
		data.task_id = taskData.id
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
	end


	-- task event handle
	local endTalkCallback = nil
	self.EndTalk = function(taskData, callback)
		if taskData.taskType == const.TASK_TYPE.talk then
			local data = {}
			data.func_name = 'on_task_talk'
			data.task_id = taskData.id
			MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
			endTalkCallback = callback
			log('task', 'send on_task_talk taskid = ' .. taskData.id)
		end
	end
	self.TaskTalkRet = function(data)
		log('task', '任务说话通知回包')
		if data.result ~= 0 then
  			UIManager.ShowErrorMessage(data.result)
  			endTalkCallback = nil
   			return
   		end
   		if endTalkCallback then
	   		endTalkCallback()
	   	end
	   	endTalkCallback = nil
	end
	local endGatherCallback = nil
	self.EndGather = function(taskData, callback)
		if taskData.taskType == const.TASK_TYPE.gather then
			local data = {}
			data.func_name = 'on_task_gather'
			data.task_id = taskData.id
			MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
			endGatherCallback = callback
			log('task', 'send on_task_gather taskid = ' .. taskData.id)
		end
	end
	self.TaskGatherRet = function(data)
		log('task', '采集任务反馈')
		if data.result ~= 0 then
  			UIManager.ShowErrorMessage(data.result)
   			return
   		end
   		if endGatherCallback then
	   		endGatherCallback()
	   	end
	   	endGatherCallback = nil
	end
	self.EndUseItem = function(taskData)
		if taskData.taskType == const.TASK_TYPE.use_item then
			local data = {}
			data.func_name = 'on_task_use_item'
			data.task_id = taskData.id
			MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
			log('task', 'send on_task_use_item taskid = ' .. taskData.id)
		end
	end
	self.TaskUseItemRet = function(data)
		log('task', '使用任务物品')
		if data.result ~= 0 then
  			UIManager.ShowErrorMessage(data.result)
   			return
   		end
	end
	self.EndTriggerMechanism = function(taskData)
		if taskData.taskType == const.TASK_TYPE.trigger_mechanism then
			local data = {}
			data.func_name = 'on_task_trigger_mechanism'
			data.task_id = taskData.id
			MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
			log('task', 'send on_task_trigger_mechanism taskid = ' .. taskData.id)
		end
	end
	self.TaskTriggerMechanismRet = function(data)
		log('task', '触发机关反馈')
		if data.result ~= 0 then
  			UIManager.ShowErrorMessage(data.result)
   			return
   		end
	end

	-- 无回调 
	self.EndUpdateTaskOperation = function(taskData, type)
		log('task', 'send on_update_task_system_operation taskid = ' .. taskData.id)
		local data = {}
		data.func_name = 'on_update_task_system_operation'
		data.type = type
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
	end

	---------- 任务副本相关 ---------
	self.IsCycleTaskCountOK = function()
		return self.cycleTaskCount < self.cycleTaskMaxCount
	end
	self.IsCycleTaskLevelOK = function()
		local level = MyHeroManager.heroData.level
		return level >= self.cycleTaskLevel
	end
	self.isCycleTaskMemberOK = function()
		local actor_id = MyHeroManager.heroData.actor_id
		if TeamManager.InTeam(actor_id) and 
			TeamManager.IsCaptain(actor_id) and
			TeamManager.GetTeamMemberNum() >= self.cycleTaskMemNum then
			return true
		end
		return false
	end
	self.ReceiveCycleTask = function()
		local data = {}
		data.func_name = 'on_receive_daily_cycle_task'
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
		log('task', 'send 接受环任务 on_receive_daily_cycle_task ')
	end
	self.ReceiveDailyCycleTaskRet = function(data)
		log('task', '接受环任务反馈')
	end	 
	--------- 阵营任务相关 -------
	self.ReceiveCountryTask = function()
		local data = {}
		data.func_name = 'on_receive_country_task'
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
		log('task', 'send 接受阵营任务 on_receive_country_task ')
	end
	self.OnReceiveCountryTaskRet = function(data)
		log('task', '开始阵营任务反馈')
	end
	---------------------------------

	-- task operation
	-- 提交任务
	local submitCallback = nil
	-- local submitData = nil
	self.SubmitTask = function(taskData, callback)
		log('task', '请求提交任务 id=' .. taskData.id)
		local data = {}
		data.func_name = 'on_submit_task'
		data.task_id = taskData.id
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
		submitCallback = callback
		-- submitData = taskData
	end
	self.SubmitTaskRet = function(data) --
		log('task', '完成任务反馈')
		if data.result ~= 0 then
  			UIManager.ShowErrorMessage(data.result)
   			submitCallback = nil
   			return
   		end
   		if submitCallback then
   			submitCallback()
   		end
   		submitCallback = nil
   		local submitData = self.GetTaskData(data.task_id)
   		if not submitData then
   			error('没有找到taskdata id=' .. data.task_id)
   		end
   		submitData.state = const.TASK_STATE.done
		event.Brocast(eventKey, submitData.id, 'submit')
	end

	-- 接受任务
	local receiveCallback = nil
	self.ReceiveTask = function(taskData, callback)
		log('task', '请求接受任务 id=' .. taskData.id)
		local data = {}
		data.func_name = 'on_receive_task'
		data.task_id = taskData.id
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
		receiveCallback = callback
	end
	self.ReceiveTaskRet = function(data)
		log('task', '接受任务反馈')
		if data.result ~= 0 then
  			UIManager.ShowErrorMessage(data.result)
   			receiveCallback = nil
   			return
   		end
   		if receiveCallback then
   			receiveCallback(data)
   		end
   		receiveCallback = nil
	end

	-- 放弃任务
	local giveupCallback = nil
	local giveupData = nil
	self.GiveUpTask = function(taskData, callback)
		log('task', '请求放弃任务 id=' .. taskData.id)
		local data = {}
		data.func_name = 'on_give_up_task'
		data.task_id = taskData.id
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
		giveupCallback = callback
		giveupData = taskData
	end
	self.GiveUpTaskRet = function(data)
		log('task', '放弃任务反馈')
		if data.result ~= 0 then
  			UIManager.ShowErrorMessage(data.result)
  			giveupCallback = nil
   			return
   		end
		giveupData.state = const.TASK_STATE.unknown
		giveupData.lastState = nil
		event.Brocast(eventKey, giveupData.id, 'giveup')
		giveupData = nil
			
   		if giveupCallback then
   			giveupCallback()
   		end
   		giveupCallback = nil
	end
	
	-- 收集任务链
	local initMainTaskData = function(country)
		local otherTaskConfig = nil
		local campTaskConfig = nil
		if country == 1 then -- 九黎
			self.countryTaskConfig = taskConfig.MainTask2
			self.countryTaskStartId = taskConfig.Parameter[2].Value
			otherTaskConfig = taskConfig.OtherTask
			campTaskConfig = taskConfig.CampTask			
		elseif country == 2 then -- 炎黄
			self.countryTaskConfig = taskConfig.MainTask1
			self.countryTaskStartId = taskConfig.Parameter[1].Value
			otherTaskConfig = taskConfig.OtherTask
			campTaskConfig = taskConfig.CampTask
		else
			error("invalid country")
		end
		taskDatas = {}
		for k, v in pairs(self.countryTaskConfig) do
			if v.TaskID >= self.countryTaskStartId then
				local taskdata = _CreateTaskData(v)
				table.insert(taskDatas, taskdata)
			end
		end
		for k, v in pairs(otherTaskConfig) do
			if country == 1 and v.Camp == 1 then-- 支线任务九黎
				local taskdata = _CreateTaskData(v)
				table.insert(taskDatas, taskdata)
			elseif country == 2 and v.Camp == 2 then-- 支线任务炎黄
				local taskdata = _CreateTaskData(v)
				table.insert(taskDatas, taskdata)
			end
		end
		for k, v in pairs(campTaskConfig) do
			if country == 1 and v.Camp == 1 then-- 阵营线任务九黎
				local taskdata = _CreateTaskData(v)
				table.insert(taskDatas, taskdata)
			elseif country == 2 and v.Camp == 2 then-- 阵营任务炎黄
				local taskdata = _CreateTaskData(v)
				table.insert(taskDatas, taskdata)
			end
		end

		table.sort(taskDatas, function(a, b)
			return a.id < b.id
		end)
	end

	local onLogin = function(data)
		initMainTaskData(data.login_data.country)
		self.isReady = false
	end
	
	local clear = function()
		MessageManager.UnregisterMessage(MSG.SC_MESSAGE_LUA_LOGIN, onLogin)	
		MessageRPCManager.RemoveUser(self, 'GetTaskInfoRet') 

		MessageRPCManager.RemoveUser(self, 'TaskGatherRet') 
		MessageRPCManager.RemoveUser(self, 'TaskUseItemRet') 
		MessageRPCManager.RemoveUser(self, 'TaskTriggerMechanismRet') 

		MessageRPCManager.RemoveUser(self, 'SubmitTaskRet') 
		MessageRPCManager.RemoveUser(self, 'ReceiveTaskRet') 
		MessageRPCManager.RemoveUser(self, 'GiveUpTaskRet') 

		-- 任务副本　
		MessageRPCManager.RemoveUser(self, 'ReceiveDailyCycleTaskRet')
	end
	local init = function()
		clear()

		MessageRPCManager.AddUser(self, 'GetTaskInfoRet') 

		MessageRPCManager.AddUser(self, 'TaskTalkRet') 
		MessageRPCManager.AddUser(self, 'TaskGatherRet') 
		MessageRPCManager.AddUser(self, 'TaskUseItemRet') 
		MessageRPCManager.AddUser(self, 'TaskTriggerMechanismRet') 
		
		MessageRPCManager.AddUser(self, 'SubmitTaskRet') 
		MessageRPCManager.AddUser(self, 'ReceiveTaskRet') 
		MessageRPCManager.AddUser(self, 'GiveUpTaskRet') 
		-- 任务副本　
		MessageRPCManager.AddUser(self, 'ReceiveDailyCycleTaskRet')		

		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_LOGIN, onLogin)
	end
	self.UpdateDungeonMark = function(data)
        self.markData = {}
		self.markData.mark = data.mark
		self.markData.start_time = data.start_time
		self.markData.current_wave = data.current_wave
	end
	init()
	return self
end

TaskManager = TaskManager or CreateTaskManager()
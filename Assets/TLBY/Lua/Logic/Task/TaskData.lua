---------------------------------------------------
-- auth： panyinglong
-- date： 2017/3/16
-- desc： 
---------------------------------------------------

local log = require "basic/log"
local const = require "Common/constant"
local gatherTime = GetConfig('system_task').Parameter[3].Value/1000 -- 采集时间

-- 去某个场景里找某个场景元素, 如果不在同一个场景,则先切换场景
local _moveToUnit = function(unitSceneId, sceneType, sceneId, onMoveto)
	if not SceneManager.IsOnCityOrWild() then
		-- UIManager.ShowNotice('需要先到主城或野外')
		return
	end
	local hero = SceneManager.GetEntityManager().hero
	if not hero or hero:IsDied() or hero:IsDestroy() then
    	log('task', 'hero is died or destroy')
    	return
    end
    hero:moveToUnit(unitSceneId, sceneType, sceneId, 3, onMoveto)
end
local _moveToScene = function(sceneType, sceneId, onMoveto)
	if not SceneManager.IsOnCityOrWild() then
		-- UIManager.ShowNotice('需要先到主城或野外')
		return
	end
	local hero = SceneManager.GetEntityManager().hero
	if not hero or hero:IsDied() or hero:IsDestroy() then
    	log('task', 'hero is died or destroy')
    	return
    end
    hero:moveToScene(sceneType, sceneId, function()
    	log('task', 'arrived to scene')
    	if onMoveto then
    		onMoveto()
    	end
    end)
end

-- 其中参数1，参数2，参数3可能为空，会根据不同的完成条件进行定义
-- 任务类别            param1              param2              param3
-- collect             当前物品数量        nil                 nil
-- talk                当前说话次数        nil                 nil
-- use_item            使用次数            nil                 nil
-- trigger_mechanism   触发次数            nil                 nil
-- kill_monster        已杀怪数量          nil                 nil
-- kill_player         已杀人数量          nil                 nil
-- main_dungeon        已通关次数          nil                 nil
-- team_dungeon        已胜利次数          nil                 nil
-- level               当前等级            nil                 nil
-- fight_power         当前战力            nil                 nil
-- gather              已采集次数          nil                 nil
-- system_operation    操作次数            nil                 nil
--------------- task data modle -----------------------
function CreateTaskData(config)
	local self = CreateObject()
	self.cfg = config
	self.isActive = false

	-- server data
	self.lastState = const.TASK_STATE.unknown
	self.state = const.TASK_STATE.unknown
	self.receiveTime = nil
	self.param1 = nil -- 意义见上
	self.param2 = nil
	self.param3 = nil

	-- config data
	self.id = self.cfg.TaskID 		-- 任务ID
	self.taskSort = self.cfg.TaskSort
	self.taskType = self.cfg.TaskType
	-- 接受任务的npc 3参数
	self.recvNPCPara1 = self.cfg.ReceiveTaskNPCParameter1
	self.recvNPCPara2 = self.cfg.ReceiveTaskNPCParameter2
	self.recvNPCPara3 = self.cfg.ReceiveTaskNPCParameter3 
	self.recvDialogue = self.cfg.TaskDialogue1

	-- 执行任务的参数
	self.excuTaskPara1 = self.cfg.CompleteTaskParameter1
	self.excuTaskPara2 = self.cfg.CompleteTaskParameter2
	self.excuTaskPara3 = self.cfg.CompleteTaskParameter3
	self.excuTaskPara4 = self.cfg.CompleteTaskParameter4

	-- 提交任务的npc
	self.submNPCPara1 = self.cfg.CompleteTaskNPCParameter1
	self.submNPCPara2 = self.cfg.CompleteTaskNPCParameter2
	self.submDialogue = self.cfg.CompleteDialogue1

    self.levelLimit = self.cfg.LevelLimit
    self.preTaskId = self.cfg.PrepositionTask
    self.chapter = self.cfg.TaskChapter
    self.chapterName = self.cfg.TaskChapterName1
    self.sectionName = self.cfg.TaskSectionName1
    if self.taskSort == const.TASK_SORT.main and self.chapter == 0 then
    	error('主线任务缺少 章号 taskid=' .. self.id)
    end

    self.taskName = self.cfg.TaskName1
    self.unrecvTaskName = self.cfg.UnreceivedTaskName1

    self.detailDesc = self.cfg.TaskDescription1
    self.briefDescDisrec = self.cfg.UnreceivedTaskDescription1 	-- 不可接受名
    self.briefDescRec = self.cfg.ReceivedTaskDescription1 		-- 可接受名
    self.briefDesc = self.cfg.TaskTraceDescription1 			-- 已接受名
    self.targetDesc = self.cfg.TaskTargetDescription1
    if not self.detailDesc or not self.briefDesc or not self.targetDesc then
    	error('缺少任务名字或目标描述 taskid=' .. self.id)
    end
    if self.cfg.AutoReceive == 0 then
    	self.autoRecv = true
    else
    	self.autoRecv = false
    end
    if self.cfg.Aandon == 0 then
    	self.canAbort = true
    else
    	self.canAbort = false
    end
	if self.cfg.AutoComplete == 1 then
		self.autoSubmit = true
	else
		self.autoSubmit = false
	end
	if self.cfg.AutoReceive == 1 then
		self.autoReceive = true
	else
		self.autoReceive = false
	end

	-- logic data
	self.Updata = function(data)
		if self.id == data.id then
			if data.task_sort then self.taskSort = data.task_sort end
			if data.state then self.state = data.state end
			if data.param1 then self.param1 = data.param1 end
			if data.param2 then self.param2 = data.param2 end
			if data.param3 then self.param3 = data.param3 end
			if data.receive_time then self.receiveTime = data.receive_time end

			if self.lastState ~= self.state then
				if self.state == const.TASK_STATE.acceptable then
					self.onAcceptable()
				elseif self.state == const.TASK_STATE.doing then
					self.onDoing()
				elseif self.state == const.TASK_STATE.submit then
					self.onSubmitable()
				end
				self.lastState = self.state
			end
			self.onUpdate()
		end
	end

	self.onUpdate = function()
	end

	-- 状态切换为可接受, 由服务器推送
	self.onAcceptable = function()	
		log('task', 'onAcceptable id=' .. self.id)
		if self.autoReceive then
			self.Excute()
		end
	end
	-- 状态切换为执行中, 由服务器推送
	self.onDoing = function()
		log('task', 'onDoing id=' .. self.id)
	end

	-- 状态切换为可提交, 由服务器推送
	self.onSubmitable = function()
		log('task', 'onSubmitable id=' .. self.id)
		if self.autoSubmit then
			self.Excute()
		end
	end
	-- 开始谈话事件
	self.onStartTalk = function()
		log('task', 'onStartTalk id=' .. self.id .. ' state=' .. self.state)
	
	end
	-- 谈完话事件
	self.onEndTalk = function()
		log('task', 'onEndTalk id=' .. self.id .. ' state=' .. self.state)
		if self.state == const.TASK_STATE.acceptable then
			TaskManager.ReceiveTask(self)
		elseif self.state == const.TASK_STATE.doing then
			self.excuteDoing()
		elseif self.state == const.TASK_STATE.submit then
			TaskManager.SubmitTask(self)
		else
			error('npc state error while end talk')
		end	
	end

	-- 接受任务
	self.excuteAccept = function(manual)
		log('task', 'excuteAccept id=' .. self.id)
		local recvData = self.getRecvNPCData()
		if not recvData then
			self.onEndTalk()
		else
			self.moveToUnit(recvData.npcId, recvData.sceneType, recvData.sceneId, function(npc)
				npc.behavior:InterAct() -- 打开npc对话
			end)
		end		
	end
	-- 继续执行任务
	self.excuteDoing = function(manual)
		log('task', 'excuteDoing id=' .. self.id)
	end
	-- 提交任务
	self.excuteSubmit = function(manual)
		log('task', 'excuteSubmit id=' .. self.id)
		local submData = self.getSubmNPCData()
		if not submData then
			self.onEndTalk()
		else
			self.moveToUnit(submData.npcId, submData.sceneType, submData.sceneId, function(npc)
				npc.behavior:InterAct() -- 打开npc对话
			end)
		end
	end

	-- 执行任务
	self.Excute = function(manual)
		if manual then
			TaskManager.isReady = true
		end
		if GlobalManager.isHook then
		   	local hookCombat = require "Logic/OnHookCombat"
		   	hookCombat.SetHook(false)
		end
		if not TaskManager.isReady then
			log('task', 'is not ready')
			return 
		end
    	if self.state == const.TASK_STATE.unknown or self.state == const.TASK_STATE.unacceptable then
    		UIManager.ShowNotice('当前任务不可接受!')
		elseif self.state == const.TASK_STATE.acceptable then
			self.excuteAccept(manual)
		elseif self.state == const.TASK_STATE.doing then
			self.excuteDoing(manual)
		elseif self.state == const.TASK_STATE.submit then
			self.excuteSubmit(manual)
		elseif self.state == const.TASK_STATE.done then
    		UIManager.ShowNotice('任务已经完成!')
		else
			error('没有此任务状态')
		end
	end

	self.moveToUnit = function(unitSceneId, sceneType, sceneId, onMoveto)
		if not TaskManager.isReady then 
			return
		end
		log('task', 'moveToUnit id=' .. self.id .. ' unitid=' .. unitSceneId .. ' sceneType=' .. sceneType .. ' sceneId=' .. sceneId)
		_moveToUnit(unitSceneId, sceneType, sceneId, onMoveto)
	end
	self.moveToScene = function(sceneType, sceneId, onMoveto)
		if not TaskManager.isReady then 
			return
		end
		log('task', 'moveToScene id=' .. self.id .. ' sceneType=' .. sceneType .. ' sceneId=' .. sceneId)
		_moveToScene(sceneType, sceneId, onMoveto)
	end
	self.gather = function(onCollectOver)
		if not TaskManager.isReady then 
			return
		end
		UIManager.ShowCollectUI(gatherTime, onCollectOver)
	end
	self.openUI = function(id)
		if not TaskManager.isReady then 
			return
		end
		UISwitchManager.OpenUI(id)
	end

	self.getRecvNPCData = function()
		if #self.recvNPCPara1 == 0 or #self.recvNPCPara2 == 0 then
			return nil
		end
		local d = {
			sceneType = self.recvNPCPara1[1],
			sceneId = self.recvNPCPara1[2],
			npcId = self.recvNPCPara2[1],
		}
		return d
	end
	self.getSubmNPCData = function()
		if #self.submNPCPara1 == 0 or #self.submNPCPara2 == 0 then
			return nil
		end
		local d = {
			sceneType = self.submNPCPara1[1],
			sceneId = self.submNPCPara1[2],
			npcId = self.submNPCPara2[1],
		}
		return d
	end
	self.getDialogueBtns = function()
		return nil
	end
	self.isTargetNPC = function(npcscenetype, npcsceneid, npcid)
		if not self.isActive then
			return false
		end
		if self.state == const.TASK_STATE.acceptable or self.state == const.TASK_STATE.doing then
			local rd = self.getRecvNPCData()
			return (rd and rd.sceneType == npcscenetype and rd.sceneId == npcsceneid and rd.npcId == npcid)
		elseif self.state == const.TASK_STATE.submit then
			local rd = self.getSubmNPCData()
			return (rd and rd.sceneType == npcscenetype and rd.sceneId == npcsceneid and rd.npcId == npcid)
		end
		return false
	end
	self.getNpcDialogue = function()
		if self.state == const.TASK_STATE.acceptable or self.state == const.TASK_STATE.doing then
			return self.recvDialogue
		elseif self.state == const.TASK_STATE.submit then
			return self.submDialogue
		end
	end

	self.getCurrentBriefDesc = function()
		if self.state == const.TASK_STATE.unknown or self.state == const.TASK_STATE.unacceptable then
			return self.briefDescDisrec
		elseif self.state == const.TASK_STATE.acceptable then
			return self.briefDescRec
		else
			return self.briefDesc
		end
	end
	self.getBriefDesc = function()
		return self.getCurrentBriefDesc()
	end
	self.getBriefTaskName = function()
		if self.taskSort == const.TASK_SORT.country then
			return self.taskName .. '(' .. TaskManager.countryTaskCurrentTurn .. '/' .. TaskManager.countryTaskRoundCount .. ')'
		else
			return self.taskName
		end
	end

	self.getRewards = function()
		local rewards = {}
		for i = 1, 4 do
			local r = self.cfg['TaskReward' .. i]
			if r and #r == 2 then
				local itemId = r[1]
				local itemNum = r[2]
				if not rewards[itemId] then
					rewards[itemId] = 0
				end
				rewards[itemId] = rewards[itemId] + itemNum
			end
		end
		return rewards
	end

	return self
end
		
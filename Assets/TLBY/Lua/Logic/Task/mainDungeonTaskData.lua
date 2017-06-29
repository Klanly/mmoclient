-- task: 主线关卡挑战
-- type: const.TASK_TYPE.main_dungeon = 9        
-- action: 打开挑战UI, 通关某个副本1次

require "Logic/Task/TaskData"
local const = require "Common/constant"
local log = require "basic/log"

function CreateMainDungeonTaskData(config)
	local self = CreateTaskData(config)

	local getDungeonId = function()
		if self.excuTaskPara1 then
			return self.excuTaskPara1[1]
		else
			error('没有找到主线副本ID')
		end
	end

	local getUIId = function()
		local uiid = 0
		if string.len(self.excuTaskPara2) > 0 then
			uiid = self.excuTaskPara2/1
			uiid = math.floor(uiid)
		end
		return uiid
	end

	local getOpenUIBtn = function(opertype)
		local uiid = getUIId()
		if uiid > 0 then
			local btnname = UISwitchManager.GetUIName(uiid)
			local btn = {}
			btn.text = btnname
			btn.event = function()
				-- do nothing
				UIManager.UnloadView(ViewAssets.NPCTalkUI)
				UISwitchManager.OpenUI(uiid, function(ctrl) 
					if not ctrl or ctrl.asset ~= ViewAssets.ChallengeUI then
						error('UI打开错误, 应该打开ViewAssets.ChallengeUI')
					end
					ctrl.selectDungeonById(getDungeonId())
				end)
			end
			return btn
		end	
		return nil
	end

	self.onDoing = function()
		log('task', 'onDoing id=' .. self.id)
		-- self.Excute()
	end
	-- 继续执行任务
	self.excuteDoing = function()
		log('task', 'excuteDoing id=' .. self.id)
		
		if SceneManager.currentSceneType == constant.SCENE_TYPE.WILD or SceneManager.currentSceneType == constant.SCENE_TYPE.CITY then
			local recvData = self.getRecvNPCData()
			self.moveToUnit(recvData.npcId, recvData.sceneType, recvData.sceneId, function(npc)
				npc.behavior:InterAct()
			end)
		else
			if MainDungeonManager.IsOnDungeoning() and MainDungeonManager.currentDungeonId == getDungeonId() then
				local hookCombat = require "Logic/OnHookCombat"
				hookCombat.SetHook(true)
			else
				UIManager.ShowNotice('必须先退出副本')
			end
		end
	end
	self.onEndTalk = function()
		log('task', 'onEndTalk id=' .. self.id .. ' state=' .. self.state)
		if self.state == const.TASK_STATE.acceptable then
			TaskManager.ReceiveTask(self)
		elseif self.state == const.TASK_STATE.doing then
			
		elseif self.state == const.TASK_STATE.submit then
			TaskManager.SubmitTask(self)
		else
			error('npc state error while end talk')
		end	
	end
	self.onSubmitable = function()
		log('task', 'onSubmitable id=' .. self.id)
		if self.autoSubmit then
			log('task', "current:", " currentSceneId:" .. SceneManager.currentSceneId, "currentSceneType:" .. SceneManager.currentSceneType)
			-- 从副本回到主城或野外
			-- local submData = self.getSubmNPCData()
			-- self.moveToUnit(submData.npcId, submData.sceneType, submData.sceneId, function(npc)
			-- 	npc.behavior:InterAct()
			-- end)
		end
	end

	self.getDialogueBtns = function()
		if self.state ~= const.TASK_STATE.acceptable and self.state ~= const.TASK_STATE.doing then
			return nil
		end
		local btns = {}
		local btn = getOpenUIBtn()
		if btn then
			table.insert(btns, btn)
		end
		return btns   
	end

	self.getBriefDesc = function()
		local str = self.getCurrentBriefDesc()
		if self.state >= const.TASK_STATE.doing then	
			local cur = (self.param1 or 0)
			local need = 1
			local numstr = '(' .. cur .. '/' .. need .. ')'
			local color = 'white'
			if cur >= need then
				color = 'green'
			end
			str = str .. "<color=" .. color .. ">".. numstr .. "</color>"
		end
		return str
	end
	return self
end
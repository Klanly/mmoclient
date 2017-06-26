-- task: 定点对话任务
-- type: const.TASK_TYPE.talk = 3
-- action: 寻找某个npc, 对话

require "Logic/Task/TaskData"
local const = require "Common/constant"
local log = require "basic/log"

function CreateTalkTaskData(config)
	local self = CreateTaskData(config)

	self.isTargetNPC = function(npcscenetype, npcsceneid, npcid)
		if not self.isActive then
			return false
		end
		if self.state == const.TASK_STATE.acceptable then
			local rd = self.getRecvNPCData()
			return (rd and rd.sceneType == npcscenetype and rd.sceneId == npcsceneid and rd.npcId == npcid)
		elseif self.state == const.TASK_STATE.submit or self.state == const.TASK_STATE.doing then
			local rd = self.getSubmNPCData()
			return (rd and rd.sceneType == npcscenetype and rd.sceneId == npcsceneid and rd.npcId == npcid)
		end
		return false
	end
	self.getNpcDialogue = function()
		if self.state == const.TASK_STATE.acceptable then
			return self.recvDialogue
		elseif self.state == const.TASK_STATE.submit or self.state == const.TASK_STATE.doing then
			return self.submDialogue
		end
	end
	-- 继续执行任务
	self.excuteDoing = function()
		log('task', 'excuteDoing id=' .. self.id)
		local subData = self.getSubmNPCData()
		if not subData then
			self.onEndTalk()
		else
			self.moveToUnit(subData.npcId, subData.sceneType, subData.sceneId, function(npc)
				npc.behavior:InterAct()
			end)
		end
	end
	self.onEndTalk = function()
		log('task', 'onEndTalk id=' .. self.id .. ' state=' .. self.state)
		if self.state == const.TASK_STATE.acceptable then
			TaskManager.ReceiveTask(self)
		elseif self.state == const.TASK_STATE.doing then
			TaskManager.EndTalk(self)
		elseif self.state == const.TASK_STATE.submit then
			TaskManager.SubmitTask(self)
		else
			error('npc state error while end talk')
		end	
	end
	self.onDoing = function()
		log('task', 'onDoing id=' .. self.id)
		self.Excute()
	end
	self.onSubmitable = function()
		log('task', 'onSubmitable id=' .. self.id)
		if self.autoSubmit then
			local subData = self.getSubmNPCData()
			if not subData then
				self.onEndTalk()
			else
				self.moveToUnit(subData.npcId, subData.sceneType, subData.sceneId, function(npc)
					self.onEndTalk()
				end)
			end
		end
	end

	return self
end
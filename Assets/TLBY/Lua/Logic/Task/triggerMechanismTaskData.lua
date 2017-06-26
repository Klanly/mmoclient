-- task: 定点触发机关
-- type: const.TASK_TYPE.trigger_mechanism = 5
-- action: 找到指定的场景元素(机关), 触发

require "Logic/Task/TaskData"
local const = require "Common/constant"
local log = require "basic/log"

function CreateTriggerMechanismTaskData(config)
	local self = CreateTaskData(config)
	local getTrickSceneData = function()
		local data = {}
		if self.excuTaskPara1 and #self.excuTaskPara1 == 2 then
			data.sceneType = self.excuTaskPara1[1]
			data.sceneId = self.excuTaskPara1[2]
			return data
		else
			error('场景数据有误')
		end
	end
	local getTrickId = function()
		if string.len(self.excuTaskPara2) > 0 then
			return math.floor(self.excuTaskPara2/1)
		end
		return nil
	end
	self.onDoing = function()
		log('task', 'onDoing id=' .. self.id)
		self.Excute()
	end
	-- 继续执行任务
	self.excuteDoing = function()
		log('task', 'excuteDoing id=' .. self.id)
		local sceneData = getTrickSceneData()
		local trickid = getTrickId()
		self.moveToUnit(trickid, sceneData.sceneType, sceneData.sceneId, function(trick)
			if not trick then
				error("机关对象没有找到")
			end
			if trick.entityType ~= EntityType.Trick then
				error('机关对象类型有误 entityType=' .. trick.entityType)
			end
			trick:OnTrigger()
			TaskManager.EndTriggerMechanism(self)
		end)
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
-- task: 战斗力指标
-- type: const.TASK_TYPE.fight_power = 12    
-- action: 战斗力达到num, 客户端接受任务, 等待服务器推送进度

require "Logic/Task/TaskData"
local const = require "Common/constant"


function CreateFightPowerTaskData(config)
	local self = CreateTaskData(config)
	-- 状态切换为可接受, 由服务器推送
	self.onAcceptable = function()	
		log('task', 'onAcceptable id=' .. self.id)
	end
	-- 状态切换为执行中, 由服务器推送
	self.onDoing = function()
		log('task', 'onDoing id=' .. self.id)
	end

	-- 状态切换为可提交, 由服务器推送
	self.onSubmitable = function()
		log('task', 'onSubmitable id=' .. self.id)
		if self.autoSubmit then
			TaskManager.SubmitTask(self)
		end
	end
	-- 开始谈话事件
	self.onStartTalk = function()
		log('task', 'onStartTalk id=' .. self.id .. ' state=' .. self.state)	
	end
	-- 谈完话事件
	self.onEndTalk = function()
		log('task', 'onEndTalk id=' .. self.id .. ' state=' .. self.state)
	end

	-- 接受任务
	self.excuteAccept = function(manual)
		log('task', 'excuteAccept id=' .. self.id)
		TaskManager.ReceiveTask(self)
	end
	-- 继续执行任务
	self.excuteDoing = function(manual)
		log('task', 'excuteDoing id=' .. self.id)
	end
	-- 提交任务
	self.excuteSubmit = function(manual)
		log('task', 'excuteSubmit id=' .. self.id)
		TaskManager.SubmitTask(self)
	end
	self.getBriefDesc = function()
		local str = self.getCurrentBriefDesc()
		if self.state >= const.TASK_STATE.doing then
			local cur = (self.param1 or 0)
			local need = self.excuTaskPara1[1]
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
-- task: 快递
-- type: const.TASK_TYPE.collect = 1      
-- action: 把npc1的东西送给npc2
-- finished

require "Logic/Task/TaskData"
local const = require "Common/constant"
local log = require "basic/log"


function CreateExpressTaskData(config)
	local self = CreateTaskData(config)
	
	self.onDoing = function()
		log('task', 'onDoing id=' .. self.id)
		self.excuteDoing()
	end
	return self
end
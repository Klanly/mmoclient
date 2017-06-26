-- task: 对话并返回
-- type: const.TASK_TYPE.talk_back = 15    
-- action: 

require "Logic/Task/TaskData"
local const = require "Common/constant"

function CreateTalkBackTaskData(config)
	local self = CreateTaskData(config)
	
	return self
end
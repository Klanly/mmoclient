-- task: 护送
-- type: const.TASK_TYPE.escort = 2   
-- action: 

require "Logic/Task/TaskData"
local const = require "Common/constant"


function CreateEscortTaskData(config)
	local self = CreateTaskData(config)
	
	return self
end
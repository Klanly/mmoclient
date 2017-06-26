-- task: 日常活动
-- type: const.TASK_TYPE.daily_activity = 8      
-- action: 打开活动UI, 完成某个活动num次

require "Logic/Task/TaskData"
local const = require "Common/constant"


function CreateDailyActivityTaskData(config)
	local self = CreateTaskData(config)
	
	return self
end
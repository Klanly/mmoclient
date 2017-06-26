-- task: 组队副本挑战
-- type: const.TASK_TYPE.team_dungeon = 10    
-- action: 打开组队副本UI, 完成组队副本num次

require "Logic/Task/TaskData"
local const = require "Common/constant"

function CreateTeamDungeonTaskData(config)
	local self = CreateTaskData(config)
	
	-- self.getBriefDesc = function()
	-- 	return self.briefDesc .. "(" .. (self.param1 or 0) .. "/" .. math.floor(self.excuTaskPara2) .. ")"
	-- end
	return self
end
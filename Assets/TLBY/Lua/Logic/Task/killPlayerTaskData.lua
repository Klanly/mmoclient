-- task: 击杀玩家
-- type: const.TASK_TYPE.kill_player = 7
-- action: 击杀num个玩家, 客户端接受任务, 等待服务器推送进度

require "Logic/Task/TaskData"
local const = require "Common/constant"

function CreateKillPlayerTaskData(config)
	local self = CreateTaskData(config)
	
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
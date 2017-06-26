-- task: 采集
-- type: const.TASK_TYPE.gather = 13    
-- action: 到某个position进行采集动作num次

require "Logic/Task/TaskData"
local const = require "Common/constant"
local log = require "basic/log"

local gatherDistance = 5


function CreateGatherTaskData(config)
	local self = CreateTaskData(config)
	local gatherNum = 0

	local onGatherOver = function()
		TaskManager.EndGather(self)
	end

	self.onDoing = function()
		log('task', 'onDoing id=' .. self.id)
		self.Excute()
	end
	self.onUpdate = function()
		if self.state == const.TASK_STATE.doing then
			local cur = (self.param1 or 0)
			if cur > 0 and not self.isCollectEnough() then
				self.excuteDoing()
			end
		end
	end
	-- 继续执行任务
	self.excuteDoing = function()
		log('task', 'excuteDoing id=' .. self.id)
		local sceneType = self.excuTaskPara1[1]
		local sceneId = self.excuTaskPara1[2]

		self.moveToScene(sceneType, sceneId, function()
			local hero = SceneManager.GetEntityManager().hero
			if not hero or hero:IsDied() or hero:IsDestroy() then
		    	log('task', 'hero is died or destroy')
		    	return
		    end
			local pos = self.getGatherPos()
			-- log("task", "gatherpos:", pos.x, pos.y, pos.z)
			if Vector3.Distance2D(hero:GetPosition(), pos) > gatherDistance then
			    hero:Moveto(pos, gatherDistance, function()
			    	self.gather(onGatherOver)
			    end)
			else
				self.gather(onGatherOver)
			end
		end)
	end

	self.isCollectEnough = function()
		local need = self.excuTaskPara3[1]
		local current = self.param1 or 0
		return current >= need
	end
	self.getBriefDesc = function()	
		local str = self.getCurrentBriefDesc()
		if self.state >= const.TASK_STATE.doing then
			local cur = (self.param1 or 0)
			local need = self.excuTaskPara3[1]
			local numstr = '(' .. cur .. '/' .. need .. ')'
			local color = 'white'
			if cur >= need then
				color = 'green'
			end
			str = str .. "<color=" .. color .. ">".. numstr .. "</color>"
		end
		return str
	end
	self.getGatherPos = function()
		local s = self.excuTaskPara2
		if string.len(self.excuTaskPara2) > 0 then
			local ss = string.split(s, '|')
			if #ss ~= 3 then
				error("格式错误")
			end
			local pos = Vector3.New(tonumber(ss[1]), tonumber(ss[2]), tonumber(ss[3]))
			return pos	
		else		
			error("没有采集坐标点")
		end		
	end

	return self
end
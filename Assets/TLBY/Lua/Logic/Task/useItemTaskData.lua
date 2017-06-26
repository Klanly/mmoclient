-- task: 定点使用道具
-- type: const.TASK_TYPE.use_item = 4      
-- action: 到指定的position使用道具(其实就是给服务器发一条使用消息)

require "Logic/Task/TaskData"
local const = require "Common/constant"
local log = require "basic/log"
local useItemDis = 8
function CreateUseItemTaskData(config)
	local self = CreateTaskData(config)

	self.useItem = function()
		UIManager.ShowCollectUI(3, function()
			TaskManager.EndUseItem(self)
		end)		
	end
	self.onDoing = function()
		log('task', 'onDoing id=' .. self.id)
		self.Excute()
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
			local pos = self.getUseItemPos()
			if Vector3.Distance2D(hero:GetPosition(), pos) > useItemDis then
			    hero:Moveto(pos, useItemDis, function()
			    	self.useItem()
			    end)
			else
				self.useItem()
			end
		end)
	end

	self.getBriefDesc = function()
		local str = self.getCurrentBriefDesc()
		if self.state >= const.TASK_STATE.doing and #self.excuTaskPara3 == 2 then	
			local cur = (self.param1 or 0)
			local need = self.excuTaskPara3[2]
			local numstr = '(' .. cur .. '/' .. need .. ')'
			local color = 'white'
			if cur >= need then
				color = 'green'
			end
			str = str .. "<color=" .. color .. ">".. numstr .. "</color>"
		end
		return str
	end
	self.getUseItemPos = function()
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
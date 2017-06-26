-- task: 杀怪
-- type: const.TASK_TYPE.kill_monster = 6
-- action: 进入某个场景, 杀死指定id的怪物num个

require "Logic/Task/TaskData"
local const = require "Common/constant"
local log = require "basic/log"

function CreateKillMonsterTaskData(config)
	local self = CreateTaskData(config)
	
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
			local monsterSceneId = self.getMonsterSceneId()
		    hero:StartKillMonster(monsterSceneId, self)
		end)
	end

	self.isKilledEnough = function()
		local need = self.excuTaskPara3[1]
		local current = self.param1 or 0
		return current >= need
	end
	self.getBriefDesc = function()
		local str = self.getCurrentBriefDesc()
		if self.state >= const.TASK_STATE.doing then
			local cur = (self.param1 or 0)
			local need = self.excuTaskPara3[1]
			if cur > need then
				cur = need
			end
			local numstr = '(' .. cur .. '/' .. need .. ')'
			local color = 'white'
			if cur >= need then
				color = 'green'
			end
			str = str .. "<color=" .. color .. ">".. numstr .. "</color>"
		end
		return str
	end
	self.getMonsterSceneId = function()
		local mid = self.excuTaskPara2
		if string.len(self.excuTaskPara2) > 0 then
			mid = math.floor(mid/1)
		end
		return mid
	end

	return self
end
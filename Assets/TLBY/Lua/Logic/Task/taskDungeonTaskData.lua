-- task: 任务副本
-- type: const.TASK_TYPE.task_dungeon = 15        
-- action: 环任务，接受环任务时并不知道确切的taskid, 只有在TaskManager.ReceiveCycleTask() 注：NPCBehavior作了特殊处理
-- 后会收到一个GetTaskInfoRet反馈，此时才知道taskid,　此任务一接受直接doing状态 

require "Logic/Task/TaskData"
local const = require "Common/constant"
local log = require "basic/log"

function CreateTaskDungeonTaskData(config)
	local self = CreateTaskData(config)
	
	local getExcuteNPCData = function()
		local d = {
			sceneType = self.excuTaskPara1[1],
			sceneId = self.excuTaskPara1[2],
			npcId = self.excuTaskPara2/1,
		}
		return d
	end

	local getError = function()
		if not TaskManager.IsCycleTaskCountOK() then
            return '任务剩余次数不足！'
        end
        if not TaskManager.IsCycleTaskLevelOK() then
            return '等级不够！'
        end
        if not TaskManager.isCycleTaskMemberOK() then
            return ('只有队长并且队伍成员数量达到' .. TaskManager.cycleTaskMemNum .. '个才能接受任务')
        end
        return nil
	end
	-- 状态切换为可接受, 由服务器推送
	self.onAcceptable = function()	
		log('task', 'onAcceptable id=' .. self.id)
		-- do nothing
	end
	-- 接受任务
	-- self.excuteAccept = function()
	-- 	log('task', 'excuteAccept id=' .. self.id)
	-- 	-- do nothing
	-- end
	self.onDoing = function()
		log('task', 'onDoing id=' .. self.id)
		self.Excute()
	end
	self.onEndTalk = function()
		log('task', 'onEndTalk id=' .. self.id .. ' state=' .. self.state)
		if self.state == const.TASK_STATE.acceptable then
			TaskManager.ReceiveTask(self)
		elseif self.state == const.TASK_STATE.doing then
			TaskDungeonManager.RequestEnterTaskDungeon(self)
		elseif self.state == const.TASK_STATE.submit then
			TaskManager.SubmitTask(self)
		else
			error('npc state error while end talk')
		end	
	end

	-- 继续执行任务
	self.excuteDoing = function(manual)
		log('task', 'excuteDoing id=' .. self.id)
		if SceneManager.currentSceneType == constant.SCENE_TYPE.WILD or SceneManager.currentSceneType == constant.SCENE_TYPE.CITY then
			local err = getError()
			if err then
				if manual then
					UIManager.ShowNotice(err)
				end
				return
			end
			local exeData = getExcuteNPCData()
			self.moveToUnit(exeData.npcId, exeData.sceneType, exeData.sceneId, function(npc)
				npc.behavior:InterAct()
			end)
		else
			print('无操作')
		end

		
	end
	self.isTargetNPC = function(npcscenetype, npcsceneid, npcid)
		if not self.isActive then
			return false
		end
		if self.state == const.TASK_STATE.acceptable or self.state == const.TASK_STATE.doing then
			local rd = getExcuteNPCData()
			return (rd.sceneType == npcscenetype and rd.sceneId == npcsceneid and rd.npcId == npcid)
		elseif self.state == const.TASK_STATE.submit then
			local rd = self.getSubmNPCData()
			return (rd.sceneType == npcscenetype and rd.sceneId == npcsceneid and rd.npcId == npcid)
		end
		return false
	end
	self.getBriefTaskName = function()
		return self.taskName .. '(' .. TaskManager.cycleTaskCount .. '/' .. TaskManager.cycleTaskMaxCount .. ')'
	end
	
	return self
end
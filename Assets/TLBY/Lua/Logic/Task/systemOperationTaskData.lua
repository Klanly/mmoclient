-- task: 系统操作
-- type: const.TASK_TYPE.system_operation = 14   
-- action: 打开某个UI(具体UI参考操作类型), 实现操作num次 

require "Logic/Task/TaskData"
local const = require "Common/constant"
local log = require "basic/log"

function CreateSystemOperationTaskData(config)
	local self = CreateTaskData(config)

	local isCatchPet = function()
		return self.excuTaskPara1[1] == 101
	end
	local getExcutePetData = function()
		local strr = string.split(self.excuTaskPara2, '=')
		local d = {
			sceneType = strr[1]/1,
			sceneId = strr[2]/1,
			npcId = self.excuTaskPara3[1],
		}
		return d
	end
	-- 继续执行任务
	self.excuteDoing = function()
		log('task', 'excuteDoing id=' .. self.id)
		if isCatchPet() then -- 抓宠
			local petData = getExcutePetData()
			self.moveToUnit(petData.npcId, petData.sceneType, petData.sceneId, function(pet)
				if not pet then
					log('task', '没有找到宠物')
				end
				TargetManager.SetTarget(pet)
			end)
		else
			local recvData = self.getRecvNPCData()
			if not recvData then
				-- self.onEndTalk()
				error('system_operation类型的任务必须要有接收npc id=' .. self.id)
			else
				self.moveToUnit(recvData.npcId, recvData.sceneType, recvData.sceneId, function(npc)
					npc.behavior:InterAct()
				end)
			end
		end
	end

	local getUIId = function()
		if isCatchPet() then -- 抓宠
			return 0
		else
			local uiid = 0
			if string.len(self.excuTaskPara2) > 0 then
				uiid = self.excuTaskPara2/1
				uiid = math.floor(uiid)
			end
			return uiid
		end
		
	end
	local getOpenUIBtn = function(opertype)
		local uiid = getUIId()
		if uiid > 0 then
			local btnname = UISwitchManager.GetUIName(uiid)
			local btn = {}
			btn.text = btnname
			btn.event = function()
				UISwitchManager.OpenUI(uiid)
				if opertype then
					TaskManager.EndUpdateTaskOperation(self, opertype)
				end
				UIManager.UnloadView(ViewAssets.NPCTalkUI)
			end
			return btn
		end	
		return nil
	end
	self.getDialogueBtns = function()
		if self.state ~= const.TASK_STATE.acceptable and self.state ~= const.TASK_STATE.doing then
			return nil
		end
		local btns = {}
		if self.excuTaskPara1[1] == const.TASK_SYSTEM_OPERATION.capture_pet then    --捕捉宠物
			local btn = getOpenUIBtn()
			if btn then
				table.insert(btns, btn)
			end
		elseif self.excuTaskPara1[1] == const.TASK_SYSTEM_OPERATION.seal then 		--升级宝印
			local btn = getOpenUIBtn()
			if btn then
				table.insert(btns, btn)
			end
		elseif self.excuTaskPara1[1] == const.TASK_SYSTEM_OPERATION.equipment_strengthen then  --强化装备
			local btn = getOpenUIBtn()
			if btn then
				table.insert(btns, btn)
			end
		elseif self.excuTaskPara1[1] == const.TASK_SYSTEM_OPERATION.qinggong then   --使用轻功
		elseif self.excuTaskPara1[1] == const.TASK_SYSTEM_OPERATION.fashion then  	--穿上时装	
			local btn = getOpenUIBtn()
			if btn then
				table.insert(btns, btn)
			end	
		elseif self.excuTaskPara1[1] == const.TASK_SYSTEM_OPERATION.dress_equipment then  --穿装备
			local btn = getOpenUIBtn()
			if btn then
				table.insert(btns, btn)
			end
		elseif self.excuTaskPara1[1] == const.TASK_SYSTEM_OPERATION.faction then    --打开帮会界面
			local btn = getOpenUIBtn(const.TASK_SYSTEM_OPERATION.faction)
			if btn then
				table.insert(btns, btn)
			end
		elseif self.excuTaskPara1[1] == const.TASK_SYSTEM_OPERATION.shop then   --打开商店界面	
			local btn = getOpenUIBtn(const.TASK_SYSTEM_OPERATION.shop)
			if btn then
				table.insert(btns, btn)
			end
		elseif self.excuTaskPara1[1] == const.TASK_SYSTEM_OPERATION.gem then  --打开宝石界面
			local btn = getOpenUIBtn(const.TASK_SYSTEM_OPERATION.gem)
			if btn then
				table.insert(btns, btn)
			end
		elseif self.excuTaskPara1[1] == const.TASK_SYSTEM_OPERATION.upgrade_skill then  --升级技能
			local btn = getOpenUIBtn()
			if btn then
				table.insert(btns, btn)
			end
		elseif self.excuTaskPara1[1] == const.TASK_SYSTEM_OPERATION.arena_guide then  --竞技场引导
			local btn = getOpenUIBtn(const.TASK_SYSTEM_OPERATION.arena_guide)
			if btn then
				table.insert(btns, btn)
			end
		elseif self.excuTaskPara1[1] == const.TASK_SYSTEM_OPERATION.activity_guide then  --活动引导
			local btn = getOpenUIBtn(const.TASK_SYSTEM_OPERATION.activity_guide)
			if btn then
				table.insert(btns, btn)
			end
		elseif self.excuTaskPara1[1] == const.TASK_SYSTEM_OPERATION.team_guide then  --组队引导
			local btn = getOpenUIBtn(const.TASK_SYSTEM_OPERATION.team_guide)
			if btn then
				table.insert(btns, btn)
			end
		elseif self.excuTaskPara1[1] == const.TASK_SYSTEM_OPERATION.contry_guide then  --阵营引导
			local btn = getOpenUIBtn(const.TASK_SYSTEM_OPERATION.contry_guide)
			if btn then
				table.insert(btns, btn)
			end
		elseif self.excuTaskPara1[1] == const.TASK_SYSTEM_OPERATION.businessman_guide then  --云游商人引导
			local btn = getOpenUIBtn(const.TASK_SYSTEM_OPERATION.businessman_guide)
			if btn then
				table.insert(btns, btn)
			end
		elseif self.excuTaskPara1[1] == const.TASK_SYSTEM_OPERATION.equip_skill then  --装备技能
			local btn = getOpenUIBtn()
			if btn then
				table.insert(btns, btn)
			end
		elseif self.excuTaskPara1[1] == const.TASK_SYSTEM_OPERATION.hangup_guide then  --挂机引导
			local btn = getOpenUIBtn(const.TASK_SYSTEM_OPERATION.hangup_guide)
			if btn then
				table.insert(btns, btn)
			end
		else
			error('没有实现操作类型　TASK_SYSTEM_OPERATION=' .. (self.excuTaskPara1[1] or ' nil '))
		end 
		return btns   
	end
	self.getBriefDesc = function()
		local str = self.getCurrentBriefDesc()
		if self.state >= const.TASK_STATE.doing then	
			local cur = (self.param1 or 0)
			local need = self.excuTaskPara1[2]
			local numstr = '(' .. cur .. '/' .. need .. ')'
			local color = 'white'
			if cur >= need then
				color = 'green'
			end
			str = str .. "<color=" .. color .. ">".. numstr .. "</color>"
		end
		return str
	end
	self.onSubmitable = function()
		log('task', 'onSubmitable id=' .. self.id)
		if self.autoSubmit then
			local submData = self.getSubmNPCData()
			if not submData then
				self.onEndTalk()
			else
				self.moveToUnit(submData.npcId, submData.sceneType, submData.sceneId, function(npc)
					npc.behavior:InterAct()
				end)
			end
		end
	end
	return self
end


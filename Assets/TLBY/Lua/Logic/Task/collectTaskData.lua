-- task: 收集
-- type: const.TASK_TYPE.collect = 1        
-- action1: 打开杂货铺UI, 购买num个道具

require "Logic/Task/TaskData"
local const = require "Common/constant"
local log = require "basic/log"

function CreateCollectTaskData(config)
	local self = CreateTaskData(config)

	-- 继续执行任务
	self.excuteDoing = function()
		log('task', 'excuteDoing id=' .. self.id)
		local recvData = self.getRecvNPCData()
		if not recvData then
			self.onEndTalk()
		else
			self.moveToUnit(recvData.npcId, recvData.sceneType, recvData.sceneId, function(npc)
				npc.behavior:InterAct()
			end)
		end
	end

	local getUIId = function()
		local uiid = 0
		if string.len(self.excuTaskPara2) > 0 then
			uiid = self.excuTaskPara2/1
			uiid = math.floor(uiid)
		end
		return uiid
	end
	local getOpenUIBtn = function()
		local uiid = getUIId()
		if uiid > 0 then
			local btnname = UISwitchManager.GetUIName(uiid)
			local btn = {}
			btn.text = btnname
			btn.event = function()
				local UICtrl = UISwitchManager.OpenUI(uiid)
				if not UICtrl or UICtrl.asset ~= ViewAssets.NormalShopUI then
					-- error('UI打开错误, 应该打开ViewAssets.NormalShopUI')
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
		local btn = getOpenUIBtn()
		if btn then
			table.insert(btns, btn)
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
	return self
end
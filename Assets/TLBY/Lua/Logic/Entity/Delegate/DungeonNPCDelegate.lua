---------------------------------------------------
-- auth： wupeifeng
-- date： 2016/12/13
-- desc： 单位的事件delegate
---------------------------------------------------
local Delegate = require "Logic/Entity/Delegate/Delegate"
local DungeonNPCDelegate = ExtendClass(Delegate)

function DungeonNPCDelegate:__ctor()

end

function DungeonNPCDelegate:OnHpChanged()
	Delegate.OnHpChanged(self)
	if self.owner.taskData.isShowHalfHP == false then
		if self.owner.hp/self.owner.base_hp_max() <= 0.5 then
			self.owner.taskData.isShowHalfHP = true
			if self.owner.taskData.taskType == NPCTask.Escort then
				self.owner.behavior.chatBar.PushChat(uiText(1135107), 2)
			elseif self.owner.taskData.taskType == NPCTask.Defend then
				UIManager.ShowNotice(uiText(1135112))
			end	
		end
	elseif self.owner.taskData.isShowLowHP == false then
		if self.owner.hp/self.owner.base_hp_max() <= 0.2 then
			self.owner.taskData.isShowLowHP = true
			if self.owner.taskData.taskType == NPCTask.Escort then
				self.owner.behavior.chatBar.PushChat(uiText(1135108), 2)	
			elseif self.owner.taskData.taskType == NPCTask.Defend then
				UIManager.ShowNotice(uiText(1135113))
			end	
		end
	end
end

return DungeonNPCDelegate

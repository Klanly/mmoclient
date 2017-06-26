---------------------------------------------------
-- auth： panyinglong
-- date： 2016/8/26
-- desc： 单位表现
---------------------------------------------------

local Behavior = require "Logic/Entity/Behavior/Behavior"
local DungeonNPCBehavior = ExtendClass(Behavior)

function DungeonNPCBehavior:__ctor(owner)

	self:OnCreate()
end

function DungeonNPCBehavior:OnCreate()					
	self.modelId = self.owner.data.ModelID
	local item = self:GetModelData(self.modelId)
	local ownerScale = self:GetObjectSettingScale()
	print('ownerScale = ', ownerScale)
	self.modelScale = ownerScale * item.Scale
	self.behavior = EntityBehaviorManager.CreateNPC(
		SceneManager.GetCurServerSceneId(), 
		self.owner.uid, self.owner.entityType, 
		self.owner:GetBornPosition(), 
		self.modelId, self.modelScale,function() 
            if self.hpBar then self.hpBar:UpdateFollowingTarget() end
			if self.nameBar then self.nameBar:UpdateFollowingTarget() end
        end)
    
	self.gameObject = self.behavior.gameObject
	self.transform = self.behavior.transform
	self.behavior.runAnimation = 'run'
	self.behavior.defaultAnimation = 'NormalStandby'
    self.nameBar = CreateNameBar(self.owner,self.behavior, 0, 100, '#ffb40a',0)
    self.hpBar = CreateHPBar(self.owner,self.behavior, 0, 30, 6,0)
    self.chatBar = CreateChatBar(self.behavior,0,40)
end

return DungeonNPCBehavior

---------------------------------------------------
-- auth： panyinglong
-- date： 2016/8/26
-- desc： 单位表现
---------------------------------------------------

local Behavior = require "Logic/Entity/Behavior/Behavior"
local WildPetBehavior = ExtendClass(Behavior)

local GrowingPet = require "Logic/Scheme/growing_pet"

function WildPetBehavior:__ctor(owner)
	self:OnCreate()
end

function WildPetBehavior:OnCreate()
	self.modelId = self.owner.data.ModelID
	local item = self:GetModelData(self.modelId)
	local ownerScale = self:GetObjectSettingScale()
	local modelScale = ownerScale * item.Scale * self.owner.data.Scale
	self.behavior = EntityBehaviorManager.CreateMonster(
		SceneManager.GetCurServerSceneId(), 
		self.owner.uid, self.owner.entityType, 
		self.owner:GetBornPosition(), self.modelId, modelScale,function()
            if self.hpBar then self.hpBar:UpdateFollowingTarget() end
			if self.nameBar then self.nameBar:UpdateFollowingTarget() end
        end)
    
    self.nameBar = CreateNameBar(self.owner,self.behavior,0,100,'yellow',0)
    self.hpBar = CreateHPBar(self.owner,self.behavior, 0, 30, 1,3)
    
    
	self.gameObject = self.behavior.gameObject
	self.transform = self.behavior.transform
	self.behavior.runAnimation = 'run'
	self.behavior.defaultAnimation = 'NormalStandby'
end

return WildPetBehavior
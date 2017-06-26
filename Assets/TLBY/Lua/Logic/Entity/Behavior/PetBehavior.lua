---------------------------------------------------
-- auth： panyinglong
-- date： 2016/8/26
-- desc： 单位表现
---------------------------------------------------

local Behavior = require "Logic/Entity/Behavior/Behavior"
local PetBehavior = ExtendClass(Behavior)

local GrowingPet = require "Logic/Scheme/growing_pet"

function PetBehavior:__ctor(owner)
	self.modelId = nil
	self:OnCreate()
end

function PetBehavior:GetPetModelRes()  --获取宠物模型
	local modelId
	local modelKey = 'ModelID'	--默认第一种外观
	local petAppearance = self.owner.data.pet_appearance
	if petAppearance == 2 or petAppearance == 3 then   --为第二种外观和第三种外观时
		
		modelKey = modelKey .. petAppearance
	end
	modelId = GrowingPet.Attribute[self.owner.data.pet_id][modelKey]
	
	return modelId
end

function PetBehavior:OnCreate()
	self.modelId = self:GetPetModelRes()--GrowingPet.Attribute[self.owner.data.pet_id].ModelID   -- 根据pet_id,从宠物养成表中获取宠物modelId
	local item = self:GetModelData(self.modelId)
	local ownerScale = self:GetObjectSettingScale()
	self.modelScale = ownerScale * item.Scale * GrowingPet.Attribute[self.owner.data.pet_id].Scale
	self.behavior = EntityBehaviorManager.CreatePet(
		SceneManager.GetCurServerSceneId(), 
		self.owner.uid, self.owner.entityType, 
		self.owner:GetBornPosition(), item.Prefab, self.modelScale,function() 
            self:BindEffect() 
            if self.hpBar then self.hpBar:UpdateFollowingTarget() end
			if self.nameBar then self.nameBar:UpdateFollowingTarget() end
        end)
    
    
    local delay = -1
    local barType = 2
    local nameColor = '#29c6c6'
    if self.owner:IsHeroPet() then
        delay = 0
    else
        if self.owner.owner and self.owner.owner.behavior and self.owner.owner.behavior:IsEnemy() then
            barType = 1
            nameColor = '#f93954'
        end
    end
    self.nameBar = CreateNameBar(self.owner,self.behavior,0,100,nameColor,0,65)    
    self.hpBar = CreateHPBar(self.owner,self.behavior, 0, 30, 2,delay)
    
	self.gameObject = self.behavior.gameObject
	self.transform = self.behavior.transform
	self.behavior.runAnimation = 'run'
	self.behavior.defaultAnimation = 'NormalStandby'

end

function PetBehavior:BindEffect()		
    self:BindEffectByModelId(self.modelId)
end

return PetBehavior

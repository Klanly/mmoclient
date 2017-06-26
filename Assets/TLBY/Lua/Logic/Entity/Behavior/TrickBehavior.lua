---------------------------------------------------
-- auth： panyinglong
-- date： 2017/3/18
-- desc： 机关
---------------------------------------------------

local Behavior = require "Logic/Entity/Behavior/Behavior"
local TrickBehavior = ExtendClass(Behavior)

function TrickBehavior:__ctor(owner)
    self:OnCreate()
end

function TrickBehavior:OnCreate() 
    
    self.modelId = self.owner.data.ModelID
    local item = self:GetModelData(self.modelId)
    local ownerScale = self:GetObjectSettingScale()
    self.modelScale = ownerScale * item.Scale * self.owner.data.Scale

    self.behavior = EntityBehaviorManager.CreateTrick(
        SceneManager.GetCurServerSceneId(),  
        self.owner.uid, self.owner.entityType, 
        self.owner:GetBornPosition(), item.Prefab, 
        self.modelScale)

    self.gameObject = self.behavior.gameObject
    self.transform = self.behavior.transform
end

function TrickBehavior:BehaviorTrigger()
    if self.transform then
        self.transform.localScale = Vector3.New(2, 2, 2)
        return true
    end
    return false
end

return TrickBehavior
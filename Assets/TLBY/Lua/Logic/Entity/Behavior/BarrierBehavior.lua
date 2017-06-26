---------------------------------------------------
-- auth： zhangzeng
-- date： 2016/9/12
-- desc： 加载屏障
---------------------------------------------------
local Behavior = require "Logic/Entity/Behavior/Behavior"
local BarrierBehavior = ExtendClass(Behavior)

function BarrierBehavior:__ctor(owner)
    self.modelId = nil
	self:OnCreate()
end

function BarrierBehavior:OnCreate()

	local data = self.owner.data
    self.modelId = data.ModelID
    local item = self:GetModelData(self.modelId)
	local dir = Vector3.New()
	dir.x = data.ForwardX / 100
	dir.y = data.ForwardY / 100
	dir.z = data.ForwardZ / 100

	local scale = Vector3.New()
	scale.x = data.scaleX / 100
	scale.y = data.scaleY / 100
	scale.z = data.scaleZ / 100
	
    self.behavior = EntityBehaviorManager.CreateBarrierBehavior(
        SceneManager.GetCurServerSceneId(), 
        self.owner.uid, self.owner.entityType, 
        self.owner:GetBornPosition(),
		dir, scale, item.Prefab
        )
		
    self.gameObject = self.behavior.gameObject
    self.transform = self.behavior.transform
end

return BarrierBehavior
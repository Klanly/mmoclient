---------------------------------------------------
-- auth： panyinglong
-- date： 2017/2/13
-- desc： 空对象
---------------------------------------------------
local ToyBehavior = require "Logic/Entity/Behavior/ToyBehavior"
local EmptyGOBehavior = ExtendClass(ToyBehavior)

function EmptyGOBehavior:__ctor(owner)
	
	self:OnCreate()
end

function EmptyGOBehavior:OnCreate()
	self.behavior = EntityBehaviorManager.CreateEmptyGo(
		SceneManager.GetCurServerSceneId(), 
		self.owner.uid, EntityType.EmptyGO, self.owner:GetBornPosition(), 
		'Toy/empty')
end

return EmptyGOBehavior

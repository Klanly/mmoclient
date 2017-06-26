---------------------------------------------------
-- auth： panyinglong
-- date： 2016/8/26
-- desc： 单位表现
---------------------------------------------------
local ToyBehavior = require "Logic/Entity/Behavior/ToyBehavior"
local SummonBehavior = ExtendClass(ToyBehavior)

function SummonBehavior:__ctor(owner)
	
	self:OnCreate()
end

function SummonBehavior:OnCreate()
	self.behavior = EntityBehaviorManager.CreateSummon(
		SceneManager.GetCurServerSceneId(), 
		self.owner.uid, EntityType.Summon, self.owner:GetBornPosition(), 
		self.owner.data.res, self.owner.data.scale)	
	--self.behavior.Speed = self.owner.data.speed
end

return SummonBehavior

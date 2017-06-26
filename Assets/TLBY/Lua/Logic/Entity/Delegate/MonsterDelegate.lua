---------------------------------------------------
-- auth： wupeifeng
-- date： 2016/12/13
-- desc： 单位的事件delegate
---------------------------------------------------

local Delegate = require "Logic/Entity/Delegate/Delegate"
local MonsterDelegate = ExtendClass(Delegate)

function MonsterDelegate:__ctor()

end

function MonsterDelegate:OnBorn()
	if self.owner.data.canBeattack ~= nil then
		self.owner.canBeattack = self.owner.data.canBeattack
	end
	if self.owner.data.canBeselect ~= nil then
		self.owner.canBeselect = self.owner.data.canBeselect
	end
	if self.owner.data.canAttack ~= nil then
		self.owner.canAttack = self.owner.data.canAttack
	end
end

function MonsterDelegate:OnEnterScene()
	if self.owner.canBeattack == false then
		self.owner:CastEffect("DissolveEffect")
	end
end

return MonsterDelegate

---------------------------------------------------
-- auth： panyinglong
-- date： 2016/8/26
-- desc： 单位表现
---------------------------------------------------
require "Common/basic/LuaObject"

local ToyBehavior = ExtendClass()

function ToyBehavior:__ctor(owner)
	self.owner = owner
	-- self.effects = {}
end

function ToyBehavior:GetPosition()
	if self.behavior then
		return self.behavior.transform.position;
	end
	return nil
end
function ToyBehavior:Moveto(pos)
	if self.behavior then
		self.behavior:Moveto(pos)
	end
end

function ToyBehavior:MoveToDirectly(pos)
    self:Moveto(pos)
end

function ToyBehavior:StopMove()
	if self.behavior then
		self.behavior:StopMove()
	end
end

-- function ToyBehavior:SetNavMesh(b)
-- 	if self.behavior then
-- 		self.behavior:SetNavMesh(true)
-- 	end
-- end
-- function ToyBehavior:AddEffect(res)
-- 	if not self.behavior then
-- 		print("对象已经销毁")
-- 		return
-- 	end
-- 	local effect = ResourceManager.CreateEffect(res)
-- 	if not effect then
-- 		print("error!!! not found effect resource = " .. res)
-- 		return
-- 	end
-- 	effect.transform:SetParent(self.behavior.transform, false)

-- 	self.effects[res] = effect
-- end
-- function ToyBehavior:RemoveEffect(res)
-- 	if not IsNil(self.effects[res]) then
-- 		RecycleObject(self.effects[res])
-- 	end
-- 	self.effects[res] = nil
-- end
-- function ToyBehavior:RemoveAllEffect()		
--     for k, v in pairs(self.effects) do
--         if not IsNil(v) then
--             RecycleObject(v)
--         end
--     end
-- 	self.effects = {}
-- end
function ToyBehavior:AddEffect(resName, rootName, recyle, pos, angle, scale, detach, lossyScale)
    if not resName then
        return 
    end
    if not self.behavior then
        print("对象已经销毁")
        return
    end
    local r = rootName
    local rec = recyle
    local p = pos
    local a = angle
    local s = scale
    local d = detach
    local l = lossyScale
    if r == nil then
        r = 'root'
    end
    if rec == nil then
        rec = 0
    end
    if p == nil then
        p = Vector3.zero
    end
    if a == nil then
        a = Vector3.zero
    end
    if s == nil then
        s = Vector3.one
    end
    if d == nil then
        d = false
    end
    if l == nil then
        l = false
    end
    self.behavior:AddEffectGameObject(resName, r, rec, p, a, s, d, l)
end

function ToyBehavior:RemoveEffect(res)
    if self.behavior then
        self.behavior:RemoveEffectGameObject(res)
    end
end
function ToyBehavior:RemoveAllEffect()
    if self.behavior then
        self.behavior:RemoveAllEffectGameObject()
    end
end

function ToyBehavior:Destroy()
	self:RemoveAllEffect()
    EntityBehaviorManager.Destroy(self.owner.uid)
    self.behavior = nil
end

function ToyBehavior:SetSpeed(s)
    if self.behavior and self.behavior.Speed ~= s then
        self.behavior.Speed = s
    end
end

function ToyBehavior:GetSpeed()
    if self.behavior then
        return self.behavior.Speed
    end
end

function ToyBehavior:SetPosition(pos)
    if self.behavior then
        self.behavior:SetPosition(pos)
    end
end

function ToyBehavior:SetScale(scale)
	if self.behavior then
		self.behavior:SetScale(scale)
	end
end

function ToyBehavior:LookAt(pos)
    if self.behavior then
        self.behavior:SetLookAt(pos)
    end
end
return ToyBehavior
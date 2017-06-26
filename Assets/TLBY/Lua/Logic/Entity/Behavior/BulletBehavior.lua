---------------------------------------------------
-- auth： wupeifeng
-- date： 2017/1/11
-- desc： 单位表现
---------------------------------------------------
local ToyBehavior = require "Logic/Entity/Behavior/ToyBehavior"
local BulletBehavior = ExtendClass(ToyBehavior)

local config = GetConfig("growing_skill")

function BulletBehavior:__ctor(owner)
	
	-- 子弹走过的距离
	self.walk_distance = 0
	self.pre_walk_distance = 0
	self.target_pos = nil
	self.last_tick_time = 0
	self:OnCreate()

	self.last_tick_time = UnityEngine.Time.time
	self.move_timer = self.owner:GetTimer().Repeat(0.01, self.Tick, self)
	self.has_destination = false
end

function BulletBehavior:OnCreate()

	self.behavior = EntityBehaviorManager.CreateBullet(
		SceneManager.GetCurServerSceneId(), 
		self.owner.uid, 
		self.owner.entityType, 
		self.owner:GetBornPosition(), 
		'Toy/empty', 
		1)

	self:AddEffect(self.owner.data.effectPath)
end

function BulletBehavior:Tick()

	local delta_time = UnityEngine.Time.time - self.last_tick_time
	self.last_tick_time = UnityEngine.Time.time

	if self.has_destination then
		local distance = Vector3.Distance2D(self.target_pos, self:GetPosition())	
		local move_distance = (self:GetSpeed() / 100) * delta_time

		self.pre_walk_distance = self.walk_distance
		if move_distance >= distance then
	        self:StopMove()
	    end
	    self.walk_distance = self.walk_distance + move_distance
		self:UpdateNowPos()
	end
    
end

function BulletBehavior:GetBezierControl()
	local movement = self.target_pos - self.born_pos
	local distance = Vector3.Distance2D(self.target_pos, self.born_pos)
	local distance_offset = 0.5 --data_dict["distance_offset"]
	local height_offset = 0.5
	movement = movement * distance_offset
	movement.y = movement.y + distance * height_offset
	local control_position = self.born_pos + movement
	return control_position
end

function BulletBehavior:UpdateNowPos()
	local r = self.walk_distance / ( self.pre_walk_distance + Vector3.Distance2D(self.target_pos, self:GetPosition()))
	if r > 1 then
		r = 1
	end
	local time = r
	local _control = self:GetBezierControl()
    local _start = self.born_pos
    local _end = self.target_pos
    local tmp = ( _control - _start) * 2 * time
    tmp = _start + tmp 
    tmp = tmp + ( _end-_control*2+_start)*(time*time)
    local now_pos = _start+( _control - _start) * 2 * time + ( _end-_control*2+_start)*(time*time)
    self:SetPosition(now_pos)
end
--[[
function BulletBehavior:Moveto(pos)
	self:LookAt(pos)
	self.target_pos = pos
	self.has_destination = true
end

function ToyBehavior:StopMove()
	self.has_destination = false
end]]

function BulletBehavior:Destroy()
	if self.move_timer then
		self.owner:GetTimer().Remove(self.move_timer)
		self.move_timer = nil
	end
	ToyBehavior.Destroy(self)
end

return BulletBehavior

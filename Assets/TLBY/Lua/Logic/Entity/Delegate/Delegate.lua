---------------------------------------------------
-- auth： wupeifeng
-- date： 2016/12/13
-- desc： 单位的事件delegate
---------------------------------------------------

local EntityDelegate = require "Common/combat/Entity/Delegate/EntityDelegate"
local Delegate = ExtendClass(EntityDelegate)

function Delegate:__ctor()

end

function Delegate:ChangeModel()
	local model_id = nil 
	if self.owner.disguise_model_id and self.owner.disguise_model_id ~= 0 then
		model_id = self.owner.disguise_model_id
	else
		model_id = self.owner:GetModelId()
	end
	local model_scale = nil
	if self.owner.disguise_model_scale and self.owner.disguise_model_scale ~= 100 then
		model_scale = self.owner.disguise_model_scale / 100
	else
		model_scale = self.owner:GetModelScale()
	end

	if not self.owner:IsDied() then
		if model_id and model_scale then
			if self.old_model_id == nil or 
				self.old_model_id ~= model_id or
				self.old_model_scale == nil or 
				self.old_model_scale ~= model_scale then

				if model_id == self.owner:GetModelId() then
					if old_model_id ~= nil then
						self.owner:ResetModel()
					end
					self.owner:SetModelScale(model_scale)
				else
					self.owner:ChangeModel(artResourceScheme.Model[model_id].Prefab, model_scale)
				end
				if self.owner.is_stealthy then
					self.owner:CastEffect("StealthEffect")
				end

				self.old_model_id = model_id
				self.old_model_scale = model_scale 
				--print('ChangeModel', artResourceScheme.Model[model_id].Prefab, model_scale)
			end
		end

	end

end

function Delegate:SetStealthy()
	if self.old_is_stealthy == nil then
		if self.owner.is_stealthy then
			self.owner:CastEffect("StealthEffect")
		end
	else
		if self.old_is_stealthy ~= self.owner.is_stealthy then
			if self.owner.is_stealthy then
				self.owner:CastEffect("StealthEffect")
			else
				self.owner:RevertEffect()
			end
		end
	end
	self.old_is_stealthy = self.owner.is_stealthy
end

function Delegate:UpdateNameBar()
	if self.old_name == nil or self.old_name ~= self.owner.name then
		self.old_name = self.owner.name
		if self.owner.behavior and self.owner.behavior.nameBar then
			self.owner.behavior.nameBar.UpdateName()
		end
	end

end

function Delegate:OnHpChanged()
end

function Delegate:UpdateHpBar()
	if self.old_hp == nil or self.old_hp ~= self.owner.hp then
		self.old_hp = self.owner.hp
		self:OnHpChanged()
        if self.owner.behavior and self.owner.behavior.hpBar then
            self.owner.behavior.hpBar.ShowHpBar()
        end
	end
end

function Delegate:OnCurrentAttributeChanged()
	self:ChangeModel()
	self:SetStealthy()
	self:UpdateNameBar()
	self:UpdateHpBar()
end


function Delegate:OnHpChanged(hp)

end

return Delegate

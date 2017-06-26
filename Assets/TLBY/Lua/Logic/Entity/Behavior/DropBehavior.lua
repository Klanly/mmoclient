---------------------------------------------------
-- auth： panyinglong
-- date： 2016/8/26
-- desc： 单位表现
---------------------------------------------------


local itemTable = GetConfig('common_item')

local ToyBehavior = require "Logic/Entity/Behavior/ToyBehavior"
local DropBehavior = ExtendClass(ToyBehavior)


function DropBehavior:__ctor(owner)
	owner.data.quality = itemTable.Item[owner.data.item_id].Quality
	owner.data.res = 'Drop/drop'
	owner.data.scale = 1
	self:OnCreate()
end

function DropBehavior:SetQualityEffect(quality)	
	if quality == 1 then
		self:AddEffect("Common/eff_common@diaoluo_bai")
	elseif quality == 2 then
		self:AddEffect("Common/eff_common@diaoluo_lv")
	elseif quality == 3 then
		self:AddEffect("Common/eff_common@diaoluo_lan")
	elseif quality == 4 then
		self:AddEffect("Common/eff_common@diaoluo_zi")
	elseif quality == 5 then
		self:AddEffect("Common/eff_common@diaoluo_jin")
	end
end

function DropBehavior:OnCreate()
	self.behavior = EntityBehaviorManager.CreateDrop(
		SceneManager.GetCurServerSceneId(), 
		self.owner.uid, EntityType.Drop, 
		self.owner:GetBornPosition(),  
		self.owner.data.res, self.owner.data.scale, function(obj)
		 -- if IsNil(self.gameObject) then
		 --   return
		 -- end
		    self.gameObject = obj
		    self.transform = self.gameObject.transform	
			self.transform.scale = Vector3.New(0.3, 0.2, 0.3)
			local icon = itemTable.Item[self.owner.data.item_id].Icon
			local dropobj = self.transform:FindChild("Body/plane").gameObject
			local meshrender = dropobj:GetComponent('MeshRenderer')
			meshrender.material = ResourceManager.GetMaterial("ItemMaterial/" .. icon)
			-- print("??????" .. "ItemIcon/" .. icon, self.owner.data.item_id)
			--self:SetNavMesh(true)
			local quality = itemTable.Item[self.owner.data.item_id].Quality
			self:SetQualityEffect(quality)
		end)
end

return DropBehavior
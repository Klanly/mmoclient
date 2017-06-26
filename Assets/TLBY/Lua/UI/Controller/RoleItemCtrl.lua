
require "Common/basic/LuaObject"
require "Logic/Bag/QualityConst"
local itemTable = require "Logic/Scheme/common_item"

local function CreateRoleItemCtrl()
	local self = CreateCtrlBase()
	local FashionId
	self.Suitdata = nil
	self.bUsed = false
	self.bTakeup = false
	self.Awake = function()
       self.goIcon = self.transform:FindChild("Icon").gameObject
	   self.goSelect = self.transform:FindChild("Select").gameObject
	   self.goQuality = self.transform:FindChild("Quality").gameObject
	   self.goTakeup = self.transform:FindChild("TakeUp").gameObject
	   self.imgQuality = self.goQuality:GetComponent("Image")
	   self.imgIcon = self.goIcon:GetComponent("Image")
	   ClickEventListener.Get(self.goIcon).onClick = self.OnClick
	   ClickEventListener.Get(self.goQuality).onClick = self.OnClick
    end

    self.OnClick = function()
	   self.goSelect:SetActive(true)
	   UIManager.GetCtrl(ViewAssets.RoleappearanceUI).ShowSelItemData(self.ItemID,FashionId)
    end

    self.SetData = function(id,data)
		 self.ItemID = id 
         local item = itemTable.Item[id]
		 self.type = item.Type
		 if data ~= nil then
		   self.Suitdata = data
		   self.bUsed = true 
		 end
		 FashionId = tonumber(item.Para1)
		 if id > 0 then
            self.goIcon:SetActive(true)
            self.imgIcon.sprite = ResourceManager.LoadSprite(string.format("ItemIcon/%s",item.Icon))
            self.imgQuality.sprite = LuaUIUtil.GetItemQuality(id)
            self.goSelect:SetActive(false)
			if self.bUsed == false then
				self.imgIcon.material = UIGrayMaterial.GetUIGrayMaterial()
			else
			    self.imgIcon.material = nil
			end
			
			if self.bTakeup then
				self.goTakeup:SetActive(true)
			else
				self.goTakeup:SetActive(false)
			end
			
		end
    end

	return self
end

return CreateRoleItemCtrl()


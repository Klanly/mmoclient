
require "Common/basic/LuaObject"
require "Logic/Bag/QualityConst"
local itemTable = require "Logic/Scheme/common_item"
local texttable = require "Logic/Scheme/common_char_chinese"
local localization = require "Common/basic/Localization"
local const = require "Common/constant"

local function CreateDrugItemCtrl()
	local self = CreateCtrlBase()
    local ItemID
	local para1
	self.Awake = function()
       self.goIcon = self.transform:FindChild("Icon").gameObject
	   self.goSelect = self.transform:FindChild("Select").gameObject
	   self.goQuality = self.transform:FindChild("Quality").gameObject
	   self.imgQuality = self.goQuality:GetComponent("Image")
	   self.imgIcon = self.goIcon:GetComponent("Image")
	   self.DescText = self.transform:FindChild("DescText").gameObject:GetComponent("TextMeshProUGUI")
	   self.NumText = self.transform:FindChild("NumText").gameObject:GetComponent("TextMeshProUGUI")
	   ClickEventListener.Get(self.goIcon).onClick = self.OnClick
    end

    self.OnClick = function()

	   local itemTpye
	   local data = {}
	   data.func_name = 'on_save_client_config'
	   if math.floor(tonumber(para1)) == const.RECOVERY_DRUG_TYPE.actor_hp then
	      itemTpye = 'HP'
		  data.key =  'HealthSuppleDurgID'
	   elseif math.floor(tonumber(para1)) == const.RECOVERY_DRUG_TYPE.actor_mp then
	      itemTpye = 'MP'
		  data.key =  'MagicSuppleDurgID'
	   elseif math.floor(tonumber(para1)) == const.RECOVERY_DRUG_TYPE.pet_hp then
	      itemTpye = 'PetHP'
		  data.key =  'PetHealthSuppleDurgID'
	   end
		data.value = ItemID
		MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
	    UIManager.GetCtrl(ViewAssets.SystemSettingUI).HideDrugItems(itemTpye,self.imgIcon.overrideSprite)
    end

    self.SetData = function(id)
		 ItemID = id
         local item = itemTable.Item[id]
		 para1 = item.Para1
		 if id > 0 then
            self.goIcon:SetActive(true)
            self.imgIcon.sprite = ResourceManager.LoadSprite(string.format("ItemIcon/%s",item.Icon))
			self.goQuality:SetActive(true)
            self.imgQuality.sprite = ResourceManager.LoadSprite(QualityConst.GetSquareQualityIconPath(item.Quality))
			self.DescText.text = localization.GetItemName(id)
            self.NumText.text = BagManager.GetItemNumberById(id)
		end
    end

	return self
end

return CreateDrugItemCtrl()


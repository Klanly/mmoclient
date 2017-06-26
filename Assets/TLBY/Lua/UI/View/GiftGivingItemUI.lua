----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local itemTable = require "Logic/Scheme/common_item"
local texttable = require "Logic/Scheme/common_char_chinese"
local localization = require "Common/basic/Localization"
local math = require "math"
local constant = require "Common/constant"

local function CreateGiftGivingItemUI()
	local self = CreateViewBase();
	self.id = 0
	self.count = 0
	self.actor_id = 0
	self.press_time = 0
	self.Awake = function()
		self.com_btn_3_1 = self.transform:FindChild("@com_btn_3_1").gameObject;
		self.com_text_btn_3_1 = self.transform:FindChild("@com_text_btn_3_1").gameObject;
		self.com_text_s3 = self.transform:FindChild("@com_text_s3").gameObject;
		self.text2 = self.transform:FindChild("@text2").gameObject;
		self.com_frame_white = self.transform:FindChild("@com_frame_white").gameObject;
		self.icon1 = self.transform:FindChild("@icon1").gameObject;
		self.com_text_s10 = self.transform:FindChild("@com_text_s10").gameObject;
		self.Init()
	end

	local onGivingBtnPress = function(event,press)
		if press then
			self.press_time = networkMgr:GetConnection():GetTimestamp()
		else
			local giving_count = math.floor((networkMgr:GetConnection():GetTimestamp() - self.press_time)/100)
			if giving_count > self.count then
				giving_count = self.count
			elseif giving_count < 1 then
				giving_count = 1
			end
			MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC,{func_name="on_giving_gift_to_friend",item_id=self.id,item_count=giving_count,actor_id=self.actor_id})
		end
	end

	self.Init = function()
		self.givingLabel = self.com_text_btn_3_1:GetComponent("TextMeshProUGUI")
		self.givingLabel.text = texttable.UIText[1101064].NR
		self.nameText = self.com_text_s3:GetComponent("TextMeshProUGUI")
		self.text2Label = self.text2:GetComponent("TextMeshProUGUI")
		self.numberTxt = self.com_text_s10:GetComponent("TextMeshProUGUI")
		self.imgIcon1 = self.icon1:GetComponent("Image")
		PressEventListener.Get(self.com_btn_3_1).onPress = onGivingBtnPress
	end

	self.SetData = function(data)
		self.actor_id = data.actor_id
		self.count = data.count
		self.id = data.id

        local item = itemTable.Item[data.id]
		self.imgIcon1.overrideSprite = ResourceManager.LoadSprite(string.format("ItemIcon/%s",item.Icon))
		self.numberTxt.text = data.count
		self.nameText.text = localization.GetItemName(data.id)
	end

	return self;
end
return CreateGiftGivingItemUI()

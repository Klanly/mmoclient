----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateGiftGivingUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.Giftgivingui = self.transform:FindChild("@Giftgivingui").gameObject;
		self.com_btnclose2 = self.transform:FindChild("@Giftgivingui/@com_btnclose2").gameObject;
		self.com_text_s3 = self.transform:FindChild("@Giftgivingui/@com_text_s3").gameObject;
		self.com_text_s1 = self.transform:FindChild("@Giftgivingui/@com_text_s1").gameObject;
		self.ScrollView = self.transform:FindChild("@Giftgivingui/@ScrollView").gameObject;
	end
	return self;
end
GiftGivingUI = GiftGivingUI or CreateGiftGivingUI();

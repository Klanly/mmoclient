----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateItemTipsUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.bgmask = self.transform:FindChild("bgtips/bgmask").gameObject;
		self.btnstrengthen = self.transform:FindChild("bgtips/@btnstrengthen").gameObject;
		self.btnsynthetic = self.transform:FindChild("bgtips/@btnsynthetic").gameObject;
		self.btnBreakUp = self.transform:FindChild("bgtips/@btnBreakUp").gameObject;
		self.imageQuality = self.transform:FindChild("bgtips/@imageQuality").gameObject;
		self.equipment = self.transform:FindChild("bgtips/@equipment").gameObject;
		self.texttitle = self.transform:FindChild("bgtips/@texttitle").gameObject;
		self.textaccess = self.transform:FindChild("bgtips/@textaccess").gameObject;
		self.texttype = self.transform:FindChild("bgtips/@texttype").gameObject;
		self.textdescribe = self.transform:FindChild("bgtips/@textdescribe").gameObject;
		self.textUseLevel = self.transform:FindChild("bgtips/@textUseLevel").gameObject;
		self.textstrengthen = self.transform:FindChild("bgtips/@textstrengthen").gameObject;
		self.textsynthetic = self.transform:FindChild("bgtips/@textsynthetic").gameObject;
		self.textBreakUp = self.transform:FindChild("bgtips/@textBreakUp").gameObject;
		self.text1 = self.transform:FindChild("bgtips/@text1").gameObject;
		self.btnClose = self.transform:FindChild("@btnClose").gameObject;
	end
	return self;
end
ItemTipsUI = ItemTipsUI or CreateItemTipsUI();

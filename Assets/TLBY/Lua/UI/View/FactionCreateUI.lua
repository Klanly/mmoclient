----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateFactionCreateUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.factionName = self.transform:FindChild("text/@factionName").gameObject;
		self.factionAnnounce = self.transform:FindChild("text/@factionAnnounce").gameObject;
		self.factionField = self.transform:FindChild("text/@factionField").gameObject;
		self.requireMoney = self.transform:FindChild("textDroid/@requireMoney").gameObject;
		self.requireLevel = self.transform:FindChild("textDroid/@requireLevel").gameObject;
		self.btnClose = self.transform:FindChild("@btnClose").gameObject;
		self.btnTip = self.transform:FindChild("@btnTip").gameObject;
		self.btnCreate = self.transform:FindChild("@btnCreate").gameObject;
		self.costIcon = self.transform:FindChild("@costIcon").gameObject;
	end
	return self;
end
FactionCreateUI = FactionCreateUI or CreateFactionCreateUI();

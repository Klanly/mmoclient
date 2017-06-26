----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateFactionUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.tabInfo = self.transform:FindChild("tabs/@tabInfo").gameObject;
		self.tabMembers = self.transform:FindChild("tabs/@tabMembers").gameObject;
		self.tabWelfare = self.transform:FindChild("tabs/@tabWelfare").gameObject;
		self.tabActivity = self.transform:FindChild("tabs/@tabActivity").gameObject;
		self.btnClose = self.transform:FindChild("@btnClose").gameObject;
	end
	return self;
end
FactionUI = FactionUI or CreateFactionUI();

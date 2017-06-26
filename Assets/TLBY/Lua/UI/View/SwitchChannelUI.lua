----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateSwitchChannelUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.btnClose = self.transform:FindChild("@btnClose").gameObject;
		self.texttitle = self.transform:FindChild("@texttitle").gameObject;
		self.scrollView = self.transform:FindChild("@scrollView").gameObject;
		self.item = self.transform:FindChild("@scrollView/Viewport/Content/@item").gameObject;
	end
	return self;
end
SwitchChannelUI = SwitchChannelUI or CreateSwitchChannelUI();

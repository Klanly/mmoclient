----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateWaitServerResponseUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.waitPart = self.transform:FindChild("@waitPart").gameObject;
		self.loading = self.transform:FindChild("@waitPart/@loading").gameObject;
		self.reloginPart = self.transform:FindChild("@reloginPart").gameObject;
		self.back = self.transform:FindChild("@reloginPart/@back").gameObject;
		self.relogin = self.transform:FindChild("@reloginPart/@relogin").gameObject;
		self.retryTime = self.transform:FindChild("@reloginPart/@relogin/@retryTime").gameObject;
		self.closedPart = self.transform:FindChild("@closedPart").gameObject;
		self.btnOK = self.transform:FindChild("@closedPart/@btnOK").gameObject;
	end
	return self;
end
WaitServerResponseUI = WaitServerResponseUI or CreateWaitServerResponseUI();

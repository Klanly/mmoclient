----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateGoldenFingerUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.command = self.transform:FindChild("@command").gameObject;
		self.btnSend = self.transform:FindChild("@btnSend").gameObject;
		self.grids = self.transform:FindChild("@grids").gameObject;
		self.btnItem = self.transform:FindChild("@grids/@btnItem").gameObject;
		self.closeBtn = self.transform:FindChild("@closeBtn").gameObject;
	end
	return self;
end
GoldenFingerUI = GoldenFingerUI or CreateGoldenFingerUI();

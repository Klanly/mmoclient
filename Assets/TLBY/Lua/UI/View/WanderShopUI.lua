----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateWanderShopUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.scrollView = self.transform:FindChild("@scrollView").gameObject;
		self.item = self.transform:FindChild("@scrollView/Viewport/content/@item").gameObject;
		self.timeLeft = self.transform:FindChild("@timeLeft").gameObject;
		self.close = self.transform:FindChild("@close").gameObject;
		self.btnHelp = self.transform:FindChild("@btnHelp").gameObject;
		self.buyBtn = self.transform:FindChild("@buyBtn").gameObject;
		self.buyBtnText = self.transform:FindChild("@buyBtn/@buyBtnText").gameObject;
	end
	return self;
end
WanderShopUI = WanderShopUI or CreateWanderShopUI();

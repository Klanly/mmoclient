----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateObtainUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.Mask = self.transform:FindChild("@Mask").gameObject;
		self.CloseBtn = self.transform:FindChild("bgCongratulations/@CloseBtn").gameObject;
		self.Content = self.transform:FindChild("bgCongratulations/@ScrollView/Viewport/Content").gameObject;
		self.ObtainItem = self.transform:FindChild("bgCongratulations/@ScrollView/Viewport/Content/@ObtainItem").gameObject;
		self.ScrollView = self.transform:FindChild("bgCongratulations/@ScrollView").gameObject;
	end
	return self;
end
ObtainUI = ObtainUI or CreateObtainUI();

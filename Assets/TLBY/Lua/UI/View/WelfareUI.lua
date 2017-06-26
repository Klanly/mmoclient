----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateWelfareUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.tabs = self.transform:FindChild("tabs/Viewport/@tabs").gameObject;
		self.tabItem = self.transform:FindChild("tabs/Viewport/@tabs/@tabItem").gameObject;
		self.awardActivityPage = self.transform:FindChild("@awardActivityPage").gameObject;
		self.awardItem = self.transform:FindChild("@awardActivityPage/@awardItem").gameObject;
		self.awardActivityGrid = self.transform:FindChild("@awardActivityPage/Scroll View/Viewport/@awardActivityGrid").gameObject;
		self.awardActivityItem = self.transform:FindChild("@awardActivityPage/Scroll View/Viewport/@awardActivityGrid/@awardActivityItem").gameObject;
		self.dailyAwardPage = self.transform:FindChild("@dailyAwardPage").gameObject;
		self.serialNumberPage = self.transform:FindChild("@serialNumberPage").gameObject;
		self.codeInput = self.transform:FindChild("@serialNumberPage/@codeInput").gameObject;
		self.btnExchange = self.transform:FindChild("@serialNumberPage/@btnExchange").gameObject;
		self.normalActivityPage = self.transform:FindChild("@normalActivityPage").gameObject;
		self.normalActivityGrid = self.transform:FindChild("@normalActivityPage/Scroll View/Viewport/@normalActivityGrid").gameObject;
		self.activityDesItem = self.transform:FindChild("@normalActivityPage/Scroll View/Viewport/@normalActivityGrid/@activityDesItem").gameObject;
	end
	return self;
end
WelfareUI = WelfareUI or CreateWelfareUI();

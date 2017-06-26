----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateDailyTaskCan()
	local self = CreateViewBase();
	self.Awake = function()
		self.firstinterface = self.transform:FindChild("@firstinterface").gameObject;
		self.btnClose = self.transform:FindChild("@firstinterface/@btnClose").gameObject;
		self.List1 = self.transform:FindChild("@firstinterface/title/@List1").gameObject;
		self.template1 = self.transform:FindChild("@firstinterface/title/@List1/ScrollView/Viewport/Content/@template1").gameObject;
		self.List2 = self.transform:FindChild("@firstinterface/title/@List2").gameObject;
		self.template2 = self.transform:FindChild("@firstinterface/title/@List2/ScrollView/Viewport/Content/@template2").gameObject;
		self.List3 = self.transform:FindChild("@firstinterface/title/@List3").gameObject;
		self.template3 = self.transform:FindChild("@firstinterface/title/@List3/ScrollView/Viewport/Content/@template3").gameObject;
		self.List4 = self.transform:FindChild("@firstinterface/title/@List4").gameObject;
		self.template4 = self.transform:FindChild("@firstinterface/title/@List4/ScrollView/Viewport/Content/@template4").gameObject;
		self.List5 = self.transform:FindChild("@firstinterface/title/@List5").gameObject;
		self.template5 = self.transform:FindChild("@firstinterface/title/@List5/ScrollView/Viewport/Content/@template5").gameObject;
		self.List6 = self.transform:FindChild("@firstinterface/title/@List6").gameObject;
		self.template6 = self.transform:FindChild("@firstinterface/title/@List6/ScrollView/Viewport/Content/@template6").gameObject;
		self.List7 = self.transform:FindChild("@firstinterface/title/@List7").gameObject;
		self.template7 = self.transform:FindChild("@firstinterface/title/@List7/ScrollView/Viewport/Content/@template7").gameObject;
	end
	return self;
end
DailyTaskCan = DailyTaskCan or CreateDailyTaskCan();

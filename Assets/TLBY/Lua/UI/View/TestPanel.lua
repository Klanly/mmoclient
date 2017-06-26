----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateTestPanel()
	local self = CreateViewBase();
	self.Awake = function()
		self.scrollView = self.transform:FindChild("@scrollView").gameObject;
		self.buttonScrollviewItem = self.transform:FindChild("@scrollView/ViewPort/Content/@buttonScrollviewItem").gameObject;
		self.itemText = self.transform:FindChild("@scrollView/ViewPort/Content/@buttonScrollviewItem/@itemText").gameObject;
		self.buttonScrollviewItem2 = self.transform:FindChild("@scrollView/ViewPort/Content/@buttonScrollviewItem2").gameObject;
		self.itemText2 = self.transform:FindChild("@scrollView/ViewPort/Content/@buttonScrollviewItem2/@itemText2").gameObject;
		self.toggleText = self.transform:FindChild("backgroundImage1/@toggleText").gameObject;
		self.inputFieldOnlyContent = self.transform:FindChild("@inputFieldOnlyContent").gameObject;
		self.inputFieldNoPlaceText = self.transform:FindChild("@inputFieldNoPlaceText").gameObject;
		self.inputField = self.transform:FindChild("@inputField").gameObject;
		self.buttonImage = self.transform:FindChild("@buttonImage").gameObject;
		self.buttonText = self.transform:FindChild("@buttonText").gameObject;
		self.normalText = self.transform:FindChild("@normalText").gameObject;
	end
	return self;
end
TestPanel = TestPanel or CreateTestPanel();

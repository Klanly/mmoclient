----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateCampItemSubmitUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.btnClose = self.transform:FindChild("main/@btnClose").gameObject;
		self.title = self.transform:FindChild("main/@title").gameObject;
		self.des = self.transform:FindChild("main/@des").gameObject;
		self.ScrollView = self.transform:FindChild("main/@ScrollView").gameObject;
		self.submitItem = self.transform:FindChild("main/@ScrollView/Viewport/Content/@submitItem").gameObject;
	end
	return self;
end
CampItemSubmitUI = CampItemSubmitUI or CreateCampItemSubmitUI();

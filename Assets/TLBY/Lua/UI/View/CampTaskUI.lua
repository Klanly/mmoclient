----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateCampTaskUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.tab1 = self.transform:FindChild("@tab1").gameObject;
		self.tab2 = self.transform:FindChild("@tab2").gameObject;
		self.scrollView = self.transform:FindChild("@scrollView").gameObject;
		self.taskItem = self.transform:FindChild("@scrollView/Viewport/content/@taskItem").gameObject;
	end
	return self;
end
CampTaskUI = CampTaskUI or CreateCampTaskUI();

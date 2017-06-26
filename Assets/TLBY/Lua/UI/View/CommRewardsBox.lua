----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateCommRewardsBox()
	local self = CreateViewBase();
	self.Awake = function()
		self.btnclose = self.transform:FindChild("@btnclose").gameObject;
		self.btnok = self.transform:FindChild("@btnok").gameObject;
		self.textok = self.transform:FindChild("@textok").gameObject;
		self.textdesc = self.transform:FindChild("@textdesc").gameObject;
		self.ScrollView = self.transform:FindChild("@ScrollView").gameObject;
		self.Content = self.transform:FindChild("@ScrollView/Viewport/@Content").gameObject;
	end
	return self;
end
CommRewardsBox = CommRewardsBox or CreateCommRewardsBox();

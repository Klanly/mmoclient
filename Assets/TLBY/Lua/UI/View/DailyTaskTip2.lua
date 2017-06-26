----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateDailyTaskTip2()
	local self = CreateViewBase();
	self.Awake = function()
		self.btnclose = self.transform:FindChild("bgpopupwindow/@btnclose").gameObject;
		self.template_box = self.transform:FindChild("bgpopupwindow/ScrollView/Viewport/Content/@template_box").gameObject;
		self.tip_insufficient = self.transform:FindChild("bgpopupwindow/@tip_insufficient").gameObject;
		self.tip_lack = self.transform:FindChild("bgpopupwindow/@tip_lack").gameObject;
		self.btnopen = self.transform:FindChild("bgpopupwindow/@btnopen").gameObject;
		self.textdonatianmessage = self.transform:FindChild("bgpopupwindow/@textdonatianmessage").gameObject;
	end
	return self;
end
DailyTaskTip2 = DailyTaskTip2 or CreateDailyTaskTip2();

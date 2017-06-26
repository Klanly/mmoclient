----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateDailyTaskTip1()
	local self = CreateViewBase();
	self.Awake = function()
		self.btnClose = self.transform:FindChild("bgCamppopupwindow/@btnClose").gameObject;
		self.text_acti_cishu = self.transform:FindChild("bgCamppopupwindow/@text_acti_cishu").gameObject;
		self.text_acti_time = self.transform:FindChild("bgCamppopupwindow/@text_acti_time").gameObject;
		self.text_acti_type = self.transform:FindChild("bgCamppopupwindow/@text_acti_type").gameObject;
		self.text_acti_limit = self.transform:FindChild("bgCamppopupwindow/@text_acti_limit").gameObject;
		self.text_acti_desc = self.transform:FindChild("bgCamppopupwindow/@text_acti_desc").gameObject;
		self.text_acti_huoyue = self.transform:FindChild("bgCamppopupwindow/@text_acti_huoyue").gameObject;
		self.textCampagainst = self.transform:FindChild("bgCamppopupwindow/@textCampagainst").gameObject;
		self.btncamp = self.transform:FindChild("bgCamppopupwindow/@btncamp").gameObject;
		self.template_item = self.transform:FindChild("ScrollView/Viewport/Content/@template_item").gameObject;
	end
	return self;
end
DailyTaskTip1 = DailyTaskTip1 or CreateDailyTaskTip1();

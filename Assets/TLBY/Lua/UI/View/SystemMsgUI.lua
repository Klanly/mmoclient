----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateSystemMsgUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.scrollview = self.transform:FindChild("@scrollview").gameObject;
		self.resultList = self.transform:FindChild("@scrollview/Viewport/@resultList").gameObject;
		self.timeItem = self.transform:FindChild("@scrollview/Viewport/@resultList/@timeItem").gameObject;
		self.msgItem = self.transform:FindChild("@scrollview/Viewport/@resultList/@msgItem").gameObject;
	end
	return self;
end
SystemMsgUI = SystemMsgUI or CreateSystemMsgUI();

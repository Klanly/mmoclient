----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateTopNoticeUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.pos = self.transform:FindChild("@pos").gameObject;
		self.noticeItem = self.transform:FindChild("@pos/@noticeItem").gameObject;
	end
	return self;
end
TopNoticeUI = TopNoticeUI or CreateTopNoticeUI();

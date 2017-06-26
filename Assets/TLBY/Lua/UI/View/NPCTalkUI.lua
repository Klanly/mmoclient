----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateNPCTalkUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.close = self.transform:FindChild("@close").gameObject;
		self.imgSkip = self.transform:FindChild("@imgSkip").gameObject;
		self.txtSkip = self.transform:FindChild("@imgSkip/@txtSkip").gameObject;
		self.leftGroup = self.transform:FindChild("@leftGroup").gameObject;
		self.imgLeftHead = self.transform:FindChild("@leftGroup/talkGroup/@imgLeftHead").gameObject;
		self.txtLeftName = self.transform:FindChild("@leftGroup/talkGroup/@txtLeftName").gameObject;
		self.txtLeftContent = self.transform:FindChild("@leftGroup/talkGroup/@txtLeftContent").gameObject;
		self.btnGroup = self.transform:FindChild("@leftGroup/@btnGroup").gameObject;
		self.btnsContainer = self.transform:FindChild("@leftGroup/@btnGroup/@btnsContainer").gameObject;
		self.taskBtnTemplate = self.transform:FindChild("@leftGroup/@btnGroup/@btnsContainer/@taskBtnTemplate").gameObject;
		self.rightGroup = self.transform:FindChild("@rightGroup").gameObject;
		self.imgRightHead = self.transform:FindChild("@rightGroup/talkGroup/@imgRightHead").gameObject;
		self.txtRightName = self.transform:FindChild("@rightGroup/talkGroup/@txtRightName").gameObject;
		self.txtRightContent = self.transform:FindChild("@rightGroup/talkGroup/@txtRightContent").gameObject;
		self.imgContiue = self.transform:FindChild("@imgContiue").gameObject;
	end
	return self;
end
NPCTalkUI = NPCTalkUI or CreateNPCTalkUI();

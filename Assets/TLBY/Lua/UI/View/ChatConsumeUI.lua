----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateChatConsumeUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.btnClose = self.transform:FindChild("@btnClose").gameObject;
		self.consumeText = self.transform:FindChild("@consumeText").gameObject;
		self.btnConfirm = self.transform:FindChild("@btnConfirm").gameObject;
		self.btnCancel = self.transform:FindChild("@btnCancel").gameObject;
		self.toggle = self.transform:FindChild("@toggle").gameObject;
	end
	return self;
end
ChatConsumeUI = ChatConsumeUI or CreateChatConsumeUI();

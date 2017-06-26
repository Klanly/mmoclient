----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateCommTipBox1()
	local self = CreateViewBase();
	self.Awake = function()
		self.btnquitdesign = self.transform:FindChild("@btnquitdesign").gameObject;
		self.BtnOk = self.transform:FindChild("@BtnOk").gameObject;
		self.BtnCancel = self.transform:FindChild("@BtnCancel").gameObject;
		self.Content = self.transform:FindChild("@Content").gameObject;
		self.Title = self.transform:FindChild("@Title").gameObject;
		self.Save = self.transform:FindChild("@Save").gameObject;
	end
	return self;
end
CommTipBox1 = CommTipBox1 or CreateCommTipBox1();

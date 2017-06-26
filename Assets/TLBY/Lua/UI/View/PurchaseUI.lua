----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreatePurchaseUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.interfacebagchooseprops = self.transform:FindChild("@interfacebagchooseprops").gameObject;
		self.interfacebg = self.transform:FindChild("@interfacebagchooseprops/@interfacebg").gameObject;
		self.btnNormal = self.transform:FindChild("@interfacebagchooseprops/@btnNormal").gameObject;
		self.btnclose = self.transform:FindChild("@interfacebagchooseprops/@btnclose").gameObject;
		self.bgtextStrengthenstonetitle = self.transform:FindChild("@interfacebagchooseprops/@bgtextStrengthenstonetitle").gameObject;
		self.textprop = self.transform:FindChild("@interfacebagchooseprops/@textprop").gameObject;
		self.textpropstitle = self.transform:FindChild("@interfacebagchooseprops/@textpropstitle").gameObject;
		self.textchoosepropstitle = self.transform:FindChild("@interfacebagchooseprops/@textchoosepropstitle").gameObject;
		self.textbuy = self.transform:FindChild("@interfacebagchooseprops/@textbuy").gameObject;
		self.btnNormal2 = self.transform:FindChild("@interfacebagchooseprops/@btnNormal2").gameObject;
		self.textok = self.transform:FindChild("@interfacebagchooseprops/@textok").gameObject;
		self.Content = self.transform:FindChild("@interfacebagchooseprops/Scroll View/Viewport/@Content").gameObject;
	end
	return self;
end
PurchaseUI = PurchaseUI or CreatePurchaseUI()

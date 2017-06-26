----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateBagUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.ScrollView = self.transform:FindChild("@ScrollView").gameObject;
		self.playerresourcesui = self.transform:FindChild("@playerresourcesui").gameObject;
		self.btndeal = self.transform:FindChild("@playerresourcesui/@btndeal").gameObject;
		self.btnrecycl = self.transform:FindChild("@playerresourcesui/@btnrecycl").gameObject;
		self.btnwarehouse = self.transform:FindChild("@playerresourcesui/@btnwarehouse").gameObject;
		self.textwarehouse = self.transform:FindChild("@playerresourcesui/@textwarehouse").gameObject;
		self.textrecycl = self.transform:FindChild("@playerresourcesui/@textrecycl").gameObject;
		self.sell = self.transform:FindChild("@sell").gameObject;
		self.btndetermine = self.transform:FindChild("@sell/@btndetermine").gameObject;
		self.btncancel = self.transform:FindChild("@sell/@btncancel").gameObject;
		self.textdetermine = self.transform:FindChild("@sell/@textdetermine").gameObject;
		self.textcancel = self.transform:FindChild("@sell/@textcancel").gameObject;
		self.textsellobtain = self.transform:FindChild("@sell/@textsellobtain").gameObject;
		self.btnHelp = self.transform:FindChild("@btnHelp").gameObject;
	end
	return self;
end
BagUI = BagUI or CreateBagUI();

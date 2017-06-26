----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateNormalShopUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.btnClose = self.transform:FindChild("@btnClose").gameObject;
		self.subTabs = self.transform:FindChild("@subTabs").gameObject;
		self.subTabItem = self.transform:FindChild("@subTabs/@subTabItem").gameObject;
		self.scrollView = self.transform:FindChild("@scrollView").gameObject;
		self.mallItem = self.transform:FindChild("@scrollView/Viewport/content/@mallItem").gameObject;
		self.title = self.transform:FindChild("@title").gameObject;
		self.itemName = self.transform:FindChild("detail/@itemName").gameObject;
		self.des = self.transform:FindChild("detail/@des").gameObject;
		self.extra1 = self.transform:FindChild("detail/extra/@extra1").gameObject;
		self.extra2 = self.transform:FindChild("detail/extra/@extra2").gameObject;
		self.extra3 = self.transform:FindChild("detail/extra/@extra3").gameObject;
		self.costItemIcon = self.transform:FindChild("detail/@costItemIcon").gameObject;
		self.btnBuy = self.transform:FindChild("detail/@btnBuy").gameObject;
		self.num = self.transform:FindChild("detail/@num").gameObject;
		self.costNum = self.transform:FindChild("detail/@costNum").gameObject;
		self.btnAdd = self.transform:FindChild("detail/@btnAdd").gameObject;
		self.btnMinus = self.transform:FindChild("detail/@btnMinus").gameObject;
		self.btnHelp = self.transform:FindChild("@btnHelp").gameObject;
	end
	return self;
end
NormalShopUI = NormalShopUI or CreateNormalShopUI();

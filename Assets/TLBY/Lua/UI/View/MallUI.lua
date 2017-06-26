----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateMallUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.btnClose = self.transform:FindChild("@btnClose").gameObject;
		self.MallPage = self.transform:FindChild("@MallPage").gameObject;
		self.subTabs = self.transform:FindChild("@MallPage/@subTabs").gameObject;
		self.subTabItem = self.transform:FindChild("@MallPage/@subTabs/@subTabItem").gameObject;
		self.scrollView = self.transform:FindChild("@MallPage/@scrollView").gameObject;
		self.mallItem = self.transform:FindChild("@MallPage/@scrollView/Viewport/content/@mallItem").gameObject;
		self.itemName = self.transform:FindChild("@MallPage/detail/@itemName").gameObject;
		self.des = self.transform:FindChild("@MallPage/detail/@des").gameObject;
		self.extra1 = self.transform:FindChild("@MallPage/detail/extra/@extra1").gameObject;
		self.extra2 = self.transform:FindChild("@MallPage/detail/extra/@extra2").gameObject;
		self.extra3 = self.transform:FindChild("@MallPage/detail/extra/@extra3").gameObject;
		self.costItemIcon = self.transform:FindChild("@MallPage/detail/@costItemIcon").gameObject;
		self.btnBuy = self.transform:FindChild("@MallPage/detail/@btnBuy").gameObject;
		self.limitDes = self.transform:FindChild("@MallPage/detail/@limitDes").gameObject;
		self.num = self.transform:FindChild("@MallPage/detail/@num").gameObject;
		self.costNum = self.transform:FindChild("@MallPage/detail/@costNum").gameObject;
		self.btnAdd = self.transform:FindChild("@MallPage/detail/@btnAdd").gameObject;
		self.btnMinus = self.transform:FindChild("@MallPage/detail/@btnMinus").gameObject;
		self.btnHelp = self.transform:FindChild("@MallPage/@btnHelp").gameObject;
		self.OtherStorePage = self.transform:FindChild("@OtherStorePage").gameObject;
		self.otherStoreScrollView = self.transform:FindChild("@OtherStorePage/@otherStoreScrollView").gameObject;
		self.OtherStoreItem = self.transform:FindChild("@OtherStorePage/@otherStoreScrollView/Viewport/content/@OtherStoreItem").gameObject;
		self.ChargePage = self.transform:FindChild("@ChargePage").gameObject;
		self.tab1 = self.transform:FindChild("tabs/@tab1").gameObject;
		self.tab2 = self.transform:FindChild("tabs/@tab2").gameObject;
		self.tab3 = self.transform:FindChild("tabs/@tab3").gameObject;
		self.tab4 = self.transform:FindChild("tabs/@tab4").gameObject;
	end
	return self;
end
MallUI = MallUI or CreateMallUI();

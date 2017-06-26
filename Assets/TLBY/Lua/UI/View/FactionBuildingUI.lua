----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateFactionBuildingUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.toggleGroup = self.transform:FindChild("@toggleGroup").gameObject;
		self.toggleInfo = self.transform:FindChild("@toggleGroup/@toggleInfo").gameObject;
		self.toggleRank = self.transform:FindChild("@toggleGroup/@toggleRank").gameObject;
		self.btnclose = self.transform:FindChild("@btnclose").gameObject;
		self.title = self.transform:FindChild("@title").gameObject;
		self.houseIcon = self.transform:FindChild("bg1/@houseIcon").gameObject;
		self.des = self.transform:FindChild("bg1/@des").gameObject;
		self.skill1 = self.transform:FindChild("bg1/@des/@skill1").gameObject;
		self.skill2 = self.transform:FindChild("bg1/@des/@skill2").gameObject;
		self.des1 = self.transform:FindChild("bg1/@des/@des1").gameObject;
		self.des2 = self.transform:FindChild("bg1/@des/@des2").gameObject;
		self.processBar = self.transform:FindChild("bg1/process/@processBar").gameObject;
		self.index = self.transform:FindChild("bg1/process/@index").gameObject;
		self.processText = self.transform:FindChild("bg1/process/@processText").gameObject;
		self.bulidingName = self.transform:FindChild("bg1/process/@bulidingName").gameObject;
		self.rankListPage = self.transform:FindChild("bg1/@rankListPage").gameObject;
		self.scrollView = self.transform:FindChild("bg1/@rankListPage/@scrollView").gameObject;
		self.rankItem = self.transform:FindChild("bg1/@rankListPage/@scrollView/Viewport/content/@rankItem").gameObject;
		self.time = self.transform:FindChild("@time").gameObject;
		self.countDown = self.transform:FindChild("@time/@countDown").gameObject;
		self.upgrade = self.transform:FindChild("@upgrade").gameObject;
		self.btnUpgrade = self.transform:FindChild("@upgrade/@btnUpgrade").gameObject;
		self.invest = self.transform:FindChild("@invest").gameObject;
		self.btnFundInvest = self.transform:FindChild("@invest/@btnFundInvest").gameObject;
		self.btnCoinInvest = self.transform:FindChild("@invest/@btnCoinInvest").gameObject;
		self.fundIcon = self.transform:FindChild("@invest/@fundIcon").gameObject;
		self.coinIcon = self.transform:FindChild("@invest/@coinIcon").gameObject;
		self.fundNum = self.transform:FindChild("@invest/@fundNum").gameObject;
		self.coinNum = self.transform:FindChild("@invest/@coinNum").gameObject;
	end
	return self;
end
FactionBuildingUI = FactionBuildingUI or CreateFactionBuildingUI();

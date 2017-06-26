----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateSelectServerUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.btnClose = self.transform:FindChild("@btnClose").gameObject;
		self.btnMyServer = self.transform:FindChild("bgblackleft/@btnMyServer").gameObject;
		self.tab = self.transform:FindChild("bgblackleft/@tab").gameObject;
		self.pageServer = self.transform:FindChild("@pageServer").gameObject;
		self.scrollView = self.transform:FindChild("@pageServer/@scrollView").gameObject;
		self.serverItem = self.transform:FindChild("@pageServer/@scrollView/Viewport/contractList/@serverItem").gameObject;
		self.pageAccount = self.transform:FindChild("@pageAccount").gameObject;
		self.bgareamessage1 = self.transform:FindChild("@pageAccount/@bgareamessage1").gameObject;
		self.textplayername1 = self.transform:FindChild("@pageAccount/@bgareamessage1/@textplayername1").gameObject;
		self.text60first = self.transform:FindChild("@pageAccount/@bgareamessage1/@text60first").gameObject;
		self.textthinkfuture1 = self.transform:FindChild("@pageAccount/@bgareamessage1/@textthinkfuture1").gameObject;
	end
	return self;
end
SelectServerUI = SelectServerUI or CreateSelectServerUI();

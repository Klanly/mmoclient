----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateFactionMembersUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.timeBg = self.transform:FindChild("bgtitlename/@timeBg").gameObject;
		self.btnLeave = self.transform:FindChild("btns/@btnLeave").gameObject;
		self.btnTop = self.transform:FindChild("btns/@btnTop").gameObject;
		self.btnMerge = self.transform:FindChild("btns/@btnMerge").gameObject;
		self.btnDismiss = self.transform:FindChild("btns/@btnDismiss").gameObject;
		self.btnApplyList = self.transform:FindChild("btns/@btnApplyList").gameObject;
		self.myFactionItem = self.transform:FindChild("@myFactionItem").gameObject;
		self.scrollView = self.transform:FindChild("@scrollView").gameObject;
		self.factionItem = self.transform:FindChild("@scrollView/Viewport/content/@factionItem").gameObject;
		self.topTime = self.transform:FindChild("text/@topTime").gameObject;
		self.btnTip = self.transform:FindChild("@btnTip").gameObject;
	end
	return self;
end
FactionMembersUI = FactionMembersUI or CreateFactionMembersUI();

----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateCampBattleUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.process = self.transform:FindChild("@process").gameObject;
		self.chest1 = self.transform:FindChild("@chest1").gameObject;
		self.chest2 = self.transform:FindChild("@chest2").gameObject;
		self.chest3 = self.transform:FindChild("@chest3").gameObject;
		self.imgstar1 = self.transform:FindChild("@imgstar1").gameObject;
		self.imgstar2 = self.transform:FindChild("@imgstar2").gameObject;
		self.imgstar3 = self.transform:FindChild("@imgstar3").gameObject;
		self.leftTime = self.transform:FindChild("@leftTime").gameObject;
		self.textHit2 = self.transform:FindChild("@textHit2").gameObject;
		self.textHit1 = self.transform:FindChild("@textHit1").gameObject;
		self.textScore2 = self.transform:FindChild("@textScore2").gameObject;
		self.textScore1 = self.transform:FindChild("@textScore1").gameObject;
		self.texttask1 = self.transform:FindChild("@texttask1").gameObject;
		self.texttask2 = self.transform:FindChild("@texttask2").gameObject;
		self.texttask3 = self.transform:FindChild("@texttask3").gameObject;
		self.myScore = self.transform:FindChild("@myScore").gameObject;
		self.btnRefresh1 = self.transform:FindChild("@btnRefresh1").gameObject;
		self.btnRefresh2 = self.transform:FindChild("@btnRefresh2").gameObject;
		self.btnRefresh3 = self.transform:FindChild("@btnRefresh3").gameObject;
		self.textplayername = self.transform:FindChild("@textplayername").gameObject;
		self.scrollView = self.transform:FindChild("@scrollView").gameObject;
		self.logItem = self.transform:FindChild("@scrollView/Viewport/content/@logItem").gameObject;
	end
	return self;
end
CampBattleUI = CampBattleUI or CreateCampBattleUI();

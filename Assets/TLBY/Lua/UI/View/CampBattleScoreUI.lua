----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateCampBattleScoreUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.Fightingui = self.transform:FindChild("@Fightingui").gameObject;
		self.btnClose = self.transform:FindChild("@Fightingui/@btnClose").gameObject;
		self.scrollView1 = self.transform:FindChild("@Fightingui/@scrollView1").gameObject;
		self.playerItem1 = self.transform:FindChild("@Fightingui/@scrollView1/Viewport/content/@playerItem1").gameObject;
		self.scrollView2 = self.transform:FindChild("@Fightingui/@scrollView2").gameObject;
		self.playerItem2 = self.transform:FindChild("@Fightingui/@scrollView2/Viewport/content/@playerItem2").gameObject;
		self.score1 = self.transform:FindChild("@Fightingui/@score1").gameObject;
		self.killMost1 = self.transform:FindChild("@Fightingui/@killMost1").gameObject;
		self.leftBoss1 = self.transform:FindChild("@Fightingui/@leftBoss1").gameObject;
		self.score2 = self.transform:FindChild("@Fightingui/@score2").gameObject;
		self.killMost2 = self.transform:FindChild("@Fightingui/@killMost2").gameObject;
		self.leftBoss2 = self.transform:FindChild("@Fightingui/@leftBoss2").gameObject;
	end
	return self;
end
CampBattleScoreUI = CampBattleScoreUI or CreateCampBattleScoreUI();

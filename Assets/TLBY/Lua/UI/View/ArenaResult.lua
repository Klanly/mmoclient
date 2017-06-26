----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateArenaResult()
	local self = CreateViewBase();
	self.Awake = function()
		self.overImg = self.transform:FindChild("@overImg").gameObject;
		self.Settlementui = self.transform:FindChild("@Settlementui").gameObject;
		self.btnclose2 = self.transform:FindChild("@Settlementui/@btnclose2").gameObject;
		self.textranking = self.transform:FindChild("@Settlementui/fieldGroup/@textranking").gameObject;
		self.textplayername = self.transform:FindChild("@Settlementui/fieldGroup/@textplayername").gameObject;
		self.textOccupation = self.transform:FindChild("@Settlementui/fieldGroup/@textOccupation").gameObject;
		self.textSceneScore = self.transform:FindChild("@Settlementui/fieldGroup/@textSceneScore").gameObject;
		self.textplunderScore = self.transform:FindChild("@Settlementui/fieldGroup/@textplunderScore").gameObject;
		self.thisscore = self.transform:FindChild("@Settlementui/fieldGroup/@thisscore").gameObject;
		self.resultSV = self.transform:FindChild("@Settlementui/@resultSV").gameObject;
		self.itemTemplate = self.transform:FindChild("@Settlementui/@resultSV/Viewport/Content/@itemTemplate").gameObject;
	end
	return self;
end
ArenaResult = ArenaResult or CreateArenaResult();

----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateArenaReward()
	local self = CreateViewBase();
	self.Awake = function()
		self.close = self.transform:FindChild("@close").gameObject;
		self.bg = self.transform:FindChild("@bg").gameObject;
		self.bgreward = self.transform:FindChild("@bgreward").gameObject;
		self.textranking = self.transform:FindChild("@textranking").gameObject;
		self.textreward = self.transform:FindChild("@textreward").gameObject;
		self.succui = self.transform:FindChild("@succui").gameObject;
		self.arrowequipmentadvanced = self.transform:FindChild("@succui/@arrowequipmentadvanced").gameObject;
		self.textAutomaticallyexits = self.transform:FindChild("@succui/@textAutomaticallyexits").gameObject;
		self.textClickExit = self.transform:FindChild("@succui/@textClickExit").gameObject;
		self.failedui = self.transform:FindChild("@failedui").gameObject;
		self.textAutomaticallyexitf = self.transform:FindChild("@failedui/@textAutomaticallyexitf").gameObject;
		self.textClickExit = self.transform:FindChild("@failedui/@textClickExit").gameObject;
		self.rewardItem = self.transform:FindChild("rewards/Viewport/Content/@rewardItem").gameObject;
		self.equipmentdrop = self.transform:FindChild("rewards/Viewport/Content/@rewardItem/@equipmentdrop").gameObject;
		self.textequipment = self.transform:FindChild("rewards/Viewport/Content/@rewardItem/@textequipment").gameObject;
		self.textequipmentNum = self.transform:FindChild("rewards/Viewport/Content/@rewardItem/@textequipmentNum").gameObject;
	end
	return self;
end
ArenaReward = ArenaReward or CreateArenaReward();

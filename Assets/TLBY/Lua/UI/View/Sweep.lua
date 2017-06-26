----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateSweep()
	local self = CreateViewBase();
	self.Awake = function()
		self.sweepui = self.transform:FindChild("@sweepui").gameObject;
		self.btnclose = self.transform:FindChild("@sweepui/@btnclose").gameObject;
		self.btnok = self.transform:FindChild("@sweepui/@btnok").gameObject;
		self.textok = self.transform:FindChild("@sweepui/@textok").gameObject;
		self.imgTitle = self.transform:FindChild("@sweepui/@imgTitle").gameObject;
		self.textdesc = self.transform:FindChild("@sweepui/@textdesc").gameObject;
		self.textsituation = self.transform:FindChild("@sweepui/SweepItem/expGroup/@textsituation").gameObject;
		self.textsilver = self.transform:FindChild("@sweepui/SweepItem/expGroup/@textsilver").gameObject;
		self.textexp = self.transform:FindChild("@sweepui/SweepItem/expGroup/@textexp").gameObject;
		self.rewardItem = self.transform:FindChild("@sweepui/SweepItem/Viewport/Content/@rewardItem").gameObject;
		self.equipmentdrop = self.transform:FindChild("@sweepui/SweepItem/Viewport/Content/@rewardItem/@equipmentdrop").gameObject;
		self.textequipment = self.transform:FindChild("@sweepui/SweepItem/Viewport/Content/@rewardItem/@textequipment").gameObject;
		self.textequipmentNum = self.transform:FindChild("@sweepui/SweepItem/Viewport/Content/@rewardItem/@textequipmentNum").gameObject;
	end
	return self;
end
Sweep = Sweep or CreateSweep();

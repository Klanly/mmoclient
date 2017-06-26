----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateCatchPetUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.bgdisc = self.transform:FindChild("@bgdisc").gameObject;
		self.textcountdown = self.transform:FindChild("@textcountdown").gameObject;
		self.textmany = self.transform:FindChild("@textmany").gameObject;
		self.bgblueprogressbar = self.transform:FindChild("@bgblueprogressbar").gameObject;
		self.textcatchrate = self.transform:FindChild("@textcatchrate").gameObject;
		self.eff_UIzhuachong_cirque = self.transform:FindChild("@eff_UIzhuachong_cirque").gameObject;
		self.cirque01 = self.transform:FindChild("@eff_UIzhuachong_cirque/0/@cirque01").gameObject;
		self.cirque02 = self.transform:FindChild("@eff_UIzhuachong_cirque/0/@cirque02").gameObject;
		self.eff_UIzhuachong_star = self.transform:FindChild("@eff_UIzhuachong_star").gameObject;
		self.star01 = self.transform:FindChild("@eff_UIzhuachong_star/0/@star01").gameObject;
	end
	return self;
end
CatchPetUI = CatchPetUI or CreateCatchPetUI();

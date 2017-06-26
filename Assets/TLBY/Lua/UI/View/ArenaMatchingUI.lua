----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateArenaMatchingUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.matchingGroup = self.transform:FindChild("@matchingGroup").gameObject;
		self.bg1 = self.transform:FindChild("@matchingGroup/@bg1").gameObject;
		self.machingLabel = self.transform:FindChild("@matchingGroup/@machingLabel").gameObject;
		self.matchingTime = self.transform:FindChild("@matchingGroup/@matchingTime").gameObject;
		self.readyGroup = self.transform:FindChild("@readyGroup").gameObject;
		self.bg2 = self.transform:FindChild("@readyGroup/@bg2").gameObject;
		self.readyText = self.transform:FindChild("@readyGroup/@readyText").gameObject;
		self.arenaProGroup = self.transform:FindChild("@arenaProGroup").gameObject;
		self.btnFightInfo = self.transform:FindChild("@arenaProGroup/@btnFightInfo").gameObject;
		self.arenaProFg = self.transform:FindChild("@arenaProGroup/group/proBg/@arenaProFg").gameObject;
		self.textResttime = self.transform:FindChild("@arenaProGroup/group/@textResttime").gameObject;
	end
	return self;
end
ArenaMatchingUI = ArenaMatchingUI or CreateArenaMatchingUI();

require "UI/View/LuaViewBase"

local function CreateArenaTimerUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.number_small = self.transform:FindChild("@number_small").gameObject;
		self.number_big = self.transform:FindChild("@number_big").gameObject;
	end
	return self;
end
ArenaTimerUI = ArenaTimerUI or CreateArenaTimerUI();

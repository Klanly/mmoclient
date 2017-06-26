----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateSpeakerUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.text = self.transform:FindChild("mask/@text").gameObject;
		self.speaker = self.transform:FindChild("@speaker").gameObject;
	end
	return self;
end
SpeakerUI = SpeakerUI or CreateSpeakerUI();

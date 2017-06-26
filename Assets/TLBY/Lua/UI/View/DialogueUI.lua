----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateDialogueUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.btnok = self.transform:FindChild("frameconfirmationui/@btnok").gameObject;
		self.textok = self.transform:FindChild("frameconfirmationui/@btnok/@textok").gameObject;
		self.btncancel = self.transform:FindChild("frameconfirmationui/@btncancel").gameObject;
		self.textcancel = self.transform:FindChild("frameconfirmationui/@btncancel/@textcancel").gameObject;
		self.text = self.transform:FindChild("frameconfirmationui/@text").gameObject;
		self.btnclose3 = self.transform:FindChild("frameconfirmationui/@btnclose3").gameObject;
	end
	return self;
end
DialogueUI = DialogueUI or CreateDialogueUI();

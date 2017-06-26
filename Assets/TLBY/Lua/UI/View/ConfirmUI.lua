----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateConfirmUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.interfacebag = self.transform:FindChild("@interfacebag").gameObject;
		self.imgbagbg = self.transform:FindChild("@interfacebag/@imgbagbg").gameObject;
		self.interfacebg = self.transform:FindChild("@interfacebag/@interfacebg").gameObject;
		self.btnNormal = self.transform:FindChild("@interfacebag/@btnNormal").gameObject;
		self.btnclose = self.transform:FindChild("@interfacebag/@btnclose").gameObject;
		self.text = self.transform:FindChild("@interfacebag/@text").gameObject;
		self.textok = self.transform:FindChild("@interfacebag/@textok").gameObject;
		self.iconImag = self.transform:FindChild("@interfacebag/@iconImag").gameObject;
	end
	return self;
end
ConfirmUI = ConfirmUI or CreateConfirmUI();

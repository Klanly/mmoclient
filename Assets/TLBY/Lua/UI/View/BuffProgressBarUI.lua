----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateBuffProgressBarUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.sliderDizzy = self.transform:FindChild("@sliderDizzy").gameObject;
		self.sliderCharm = self.transform:FindChild("@sliderCharm").gameObject;
		self.sliderPetrifaction = self.transform:FindChild("@sliderPetrifaction").gameObject;
		self.iconpetrochemical = self.transform:FindChild("@sliderPetrifaction/@iconpetrochemical").gameObject;
		self.sliderFear = self.transform:FindChild("@sliderFear").gameObject;
		self.iconfear = self.transform:FindChild("@sliderFear/@iconfear").gameObject;
		self.textTime = self.transform:FindChild("@textTime").gameObject;
	end
	return self;
end
BuffProgressBarUI = BuffProgressBarUI or CreateBuffProgressBarUI();

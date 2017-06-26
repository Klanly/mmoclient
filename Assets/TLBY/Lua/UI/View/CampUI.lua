----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateCampUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.Generalmask = self.transform:FindChild("@Generalmask").gameObject;
		self.campui = self.transform:FindChild("@campui").gameObject;
		self.tab1 = self.transform:FindChild("@campui/@tab1").gameObject;
		self.tab2 = self.transform:FindChild("@campui/@tab2").gameObject;
		self.tab3 = self.transform:FindChild("@campui/@tab3").gameObject;
		self.tab4 = self.transform:FindChild("@campui/@tab4").gameObject;
		self.tab5 = self.transform:FindChild("@campui/@tab5").gameObject;
		self.btnquit = self.transform:FindChild("@btnquit").gameObject;
	end
	return self;
end
CampUI = CampUI or CreateCampUI();

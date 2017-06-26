----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreatePetUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.tab1 = self.transform:FindChild("tabs/@tab1").gameObject;
		self.tab2 = self.transform:FindChild("tabs/@tab2").gameObject;
		self.tab3 = self.transform:FindChild("tabs/@tab3").gameObject;
		self.tab4 = self.transform:FindChild("tabs/@tab4").gameObject;
		self.tab5 = self.transform:FindChild("tabs/@tab5").gameObject;
		self.scrollView = self.transform:FindChild("list/@scrollView").gameObject;
		self.petItem = self.transform:FindChild("list/@scrollView/Viewport/content/@petItem").gameObject;
		self.arrow = self.transform:FindChild("list/@arrow").gameObject;
		self.btnClose = self.transform:FindChild("@btnClose").gameObject;
	end
	return self;
end
PetUI = PetUI or CreatePetUI();

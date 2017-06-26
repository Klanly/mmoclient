----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateEquipmentUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.generalbox = self.transform:FindChild("@generalbox").gameObject;
		self.chooseStrengthenstoneui = self.transform:FindChild("@generalbox/@chooseStrengthenstoneui").gameObject;
		self.Content = self.transform:FindChild("@generalbox/@chooseStrengthenstoneui/Scroll View/Viewport/@Content").gameObject;
		self.texttitle = self.transform:FindChild("@texttitle").gameObject;
		self.tab1 = self.transform:FindChild("tabs/@tab1").gameObject;
		self.tabLight = self.transform:FindChild("tabs/@tabLight").gameObject;
		self.tab2 = self.transform:FindChild("tabs/@tab2").gameObject;
		self.tab3 = self.transform:FindChild("tabs/@tab3").gameObject;
		self.tab4 = self.transform:FindChild("tabs/@tab4").gameObject;
		self.tab5 = self.transform:FindChild("tabs/@tab5").gameObject;
		self.tabText1 = self.transform:FindChild("tabs/@tabText1").gameObject;
		self.tabText2 = self.transform:FindChild("tabs/@tabText2").gameObject;
		self.tabText3 = self.transform:FindChild("tabs/@tabText3").gameObject;
		self.tabText4 = self.transform:FindChild("tabs/@tabText4").gameObject;
		self.tabText5 = self.transform:FindChild("tabs/@tabText5").gameObject;
	end
	return self;
end
EquipmentUI = EquipmentUI or CreateEquipmentUI();

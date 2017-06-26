----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateCreateRoleUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.vocationDes = self.transform:FindChild("@vocationDes").gameObject;
		self.countryName = self.transform:FindChild("@countryName").gameObject;
		self.countryDes = self.transform:FindChild("@countryDes").gameObject;
		self.randomCountry = self.transform:FindChild("@randomCountry").gameObject;
		self.textGold = self.transform:FindChild("@randomCountry/@textGold").gameObject;
		self.btnCountry1 = self.transform:FindChild("@btnCountry1").gameObject;
		self.btnCountry2 = self.transform:FindChild("@btnCountry2").gameObject;
		self.btnEnter = self.transform:FindChild("@btnEnter").gameObject;
		self.toggle1 = self.transform:FindChild("@toggle1").gameObject;
		self.toggle2 = self.transform:FindChild("@toggle2").gameObject;
		self.toggle3 = self.transform:FindChild("@toggle3").gameObject;
		self.toggle4 = self.transform:FindChild("@toggle4").gameObject;
		self.InputField = self.transform:FindChild("@InputField").gameObject;
		self.randomName = self.transform:FindChild("@randomName").gameObject;
		self.btnMale = self.transform:FindChild("@btnMale").gameObject;
		self.btnFemale = self.transform:FindChild("@btnFemale").gameObject;
		self.btnBack = self.transform:FindChild("@btnBack").gameObject;
		self.btnShowAction = self.transform:FindChild("@btnShowAction").gameObject;
	end
	return self;
end
CreateRoleUI = CreateRoleUI or CreateCreateRoleUI();

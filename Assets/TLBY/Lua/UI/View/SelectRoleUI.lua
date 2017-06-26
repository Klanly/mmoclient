----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateSelectRoleUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.des4 = self.transform:FindChild("des/@des4").gameObject;
		self.des3 = self.transform:FindChild("des/@des3").gameObject;
		self.des2 = self.transform:FindChild("des/@des2").gameObject;
		self.des1 = self.transform:FindChild("des/@des1").gameObject;
		self.vocation2 = self.transform:FindChild("@vocation2").gameObject;
		self.vocation1 = self.transform:FindChild("@vocation1").gameObject;
		self.vocation3 = self.transform:FindChild("@vocation3").gameObject;
		self.vocation4 = self.transform:FindChild("@vocation4").gameObject;
		self.item1 = self.transform:FindChild("@item1").gameObject;
		self.item2 = self.transform:FindChild("@item2").gameObject;
		self.item3 = self.transform:FindChild("@item3").gameObject;
		self.item4 = self.transform:FindChild("@item4").gameObject;
		self.btnAdd1 = self.transform:FindChild("@btnAdd1").gameObject;
		self.btnAdd2 = self.transform:FindChild("@btnAdd2").gameObject;
		self.btnAdd3 = self.transform:FindChild("@btnAdd3").gameObject;
		self.btnAdd4 = self.transform:FindChild("@btnAdd4").gameObject;
		self.btnEnter = self.transform:FindChild("@btnEnter").gameObject;
		self.btnBack = self.transform:FindChild("@btnBack").gameObject;
		self.btnShowAction = self.transform:FindChild("@btnShowAction").gameObject;
	end
	return self;
end
SelectRoleUI = SelectRoleUI or CreateSelectRoleUI();

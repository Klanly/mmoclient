----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateEquipGemTipUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.pos = self.transform:FindChild("@pos").gameObject;
		self.icon = self.transform:FindChild("@pos/@icon").gameObject;
		self.btnClose = self.transform:FindChild("@pos/@btnClose").gameObject;
		self.name = self.transform:FindChild("@pos/@name").gameObject;
		self.type = self.transform:FindChild("@pos/@type").gameObject;
		self.level = self.transform:FindChild("@pos/@level").gameObject;
		self.des = self.transform:FindChild("@pos/@des").gameObject;
		self.output = self.transform:FindChild("@pos/@output").gameObject;
		self.btn1 = self.transform:FindChild("@pos/btns/@btn1").gameObject;
		self.btnImage1 = self.transform:FindChild("@pos/btns/@btn1/@btnImage1").gameObject;
		self.btnText1 = self.transform:FindChild("@pos/btns/@btn1/@btnImage1/@btnText1").gameObject;
		self.btn2 = self.transform:FindChild("@pos/btns/@btn2").gameObject;
		self.btnImage2 = self.transform:FindChild("@pos/btns/@btn2/@btnImage2").gameObject;
		self.btnText2 = self.transform:FindChild("@pos/btns/@btn2/@btnImage2/@btnText2").gameObject;
		self.bgicon = self.transform:FindChild("@pos/bgtips2/bgicon").gameObject;
		self.mask = self.transform:FindChild("@pos/mask").gameObject;
	end
	return self;
end
EquipGemTipUI = EquipGemTipUI or CreateEquipGemTipUI();

----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateEquipmentSmeltingUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.smeltingui = self.transform:FindChild("@smeltingui").gameObject;
		self.bigarrow = self.transform:FindChild("@smeltingui/@bigarrow").gameObject;
		self.textnosmelting = self.transform:FindChild("@smeltingui/@textnosmelting").gameObject;
		self.textsmeltingpay = self.transform:FindChild("@smeltingui/@textsmeltingpay").gameObject;
		self.textchooseequipment = self.transform:FindChild("@smeltingui/@textchooseequipment").gameObject;
		self.ScrollView = self.transform:FindChild("@smeltingui/@ScrollView").gameObject;
		self.Content = self.transform:FindChild("@smeltingui/@ScrollView/Viewport/@Content").gameObject;
		self.btnsmelting = self.transform:FindChild("@smeltingui/@btnsmelting").gameObject;
		self.textsmelting = self.transform:FindChild("@smeltingui/@textsmelting").gameObject;
		self.btnreturn = self.transform:FindChild("@smeltingui/@btnreturn").gameObject;
		self.textCurrentEquipLabel = self.transform:FindChild("@smeltingui/@textCurrentEquipLabel").gameObject;
		self.effectSmelting = self.transform:FindChild("@smeltingui/@effectSmelting").gameObject;
		self.effectCamera = self.transform:FindChild("@smeltingui/@effectSmelting/@effectCamera").gameObject;
		self.glow_common1 = self.transform:FindChild("@smeltingui/@effectSmelting/@glow_common1").gameObject;
		self.glow_common2 = self.transform:FindChild("@smeltingui/@effectSmelting/@glow_common2").gameObject;
		self.glow_common3 = self.transform:FindChild("@smeltingui/@effectSmelting/@glow_common3").gameObject;
		self.xilian_burn = self.transform:FindChild("@smeltingui/@effectSmelting/@xilian_burn").gameObject;
		self.xilian_comp = self.transform:FindChild("@smeltingui/@effectSmelting/@xilian_comp").gameObject;
		self.btnHelp = self.transform:FindChild("@btnHelp").gameObject;
		self.btnclose = self.transform:FindChild("@btnclose").gameObject;
	end
	return self;
end
EquipmentSmeltingUI = EquipmentSmeltingUI or CreateEquipmentSmeltingUI();

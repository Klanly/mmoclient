----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateRoleUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.btnclose = self.transform:FindChild("@btnclose").gameObject;
		self.btnbagpage = self.transform:FindChild("@btnbagpage").gameObject;
		self.btnbag = self.transform:FindChild("@btnbagpage/@btnbag").gameObject;
		self.btnattribute = self.transform:FindChild("@btnbagpage/@btnattribute").gameObject;
		self.btninfor = self.transform:FindChild("@btnbagpage/@btninfor").gameObject;
		self.textinforbtn = self.transform:FindChild("@btnbagpage/@textinforbtn").gameObject;
		self.textattributebtn = self.transform:FindChild("@btnbagpage/@textattributebtn").gameObject;
		self.textbagbtn = self.transform:FindChild("@btnbagpage/@textbagbtn").gameObject;
		self.roleui = self.transform:FindChild("@roleui").gameObject;
		self.btnMasterr = self.transform:FindChild("@roleui/@btnMasterr").gameObject;
		self.btnMasterr = self.transform:FindChild("@roleui/@btnMasterr/@btnMasterr").gameObject;
		self.Frame1 = self.transform:FindChild("@roleui/@Frame1").gameObject;
		self.btnequipmentadd1 = self.transform:FindChild("@roleui/@Frame1/@btnequipmentadd1").gameObject;
		self.iconequipmentitem1 = self.transform:FindChild("@roleui/@Frame1/@iconequipmentitem1").gameObject;
		self.number1 = self.transform:FindChild("@roleui/@Frame1/@iconequipmentitem1/bgnumber/@number1").gameObject;
		self.Frame2 = self.transform:FindChild("@roleui/@Frame2").gameObject;
		self.btnequipmentadd2 = self.transform:FindChild("@roleui/@Frame2/@btnequipmentadd2").gameObject;
		self.iconequipmentitem2 = self.transform:FindChild("@roleui/@Frame2/@iconequipmentitem2").gameObject;
		self.number2 = self.transform:FindChild("@roleui/@Frame2/@iconequipmentitem2/bgnumber/@number2").gameObject;
		self.Frame3 = self.transform:FindChild("@roleui/@Frame3").gameObject;
		self.btnequipmentadd3 = self.transform:FindChild("@roleui/@Frame3/@btnequipmentadd3").gameObject;
		self.iconequipmentitem3 = self.transform:FindChild("@roleui/@Frame3/@iconequipmentitem3").gameObject;
		self.number3 = self.transform:FindChild("@roleui/@Frame3/@iconequipmentitem3/bgnumber/@number3").gameObject;
		self.Frame4 = self.transform:FindChild("@roleui/@Frame4").gameObject;
		self.btnequipmentadd4 = self.transform:FindChild("@roleui/@Frame4/@btnequipmentadd4").gameObject;
		self.iconequipmentitem4 = self.transform:FindChild("@roleui/@Frame4/@iconequipmentitem4").gameObject;
		self.number4 = self.transform:FindChild("@roleui/@Frame4/@iconequipmentitem4/bgnumber/@number4").gameObject;
		self.Frame5 = self.transform:FindChild("@roleui/@Frame5").gameObject;
		self.btnequipmentadd5 = self.transform:FindChild("@roleui/@Frame5/@btnequipmentadd5").gameObject;
		self.iconequipmentitem5 = self.transform:FindChild("@roleui/@Frame5/@iconequipmentitem5").gameObject;
		self.number5 = self.transform:FindChild("@roleui/@Frame5/@iconequipmentitem5/bgnumber/@number5").gameObject;
		self.Frame6 = self.transform:FindChild("@roleui/@Frame6").gameObject;
		self.btnequipmentadd6 = self.transform:FindChild("@roleui/@Frame6/@btnequipmentadd6").gameObject;
		self.iconequipmentitem6 = self.transform:FindChild("@roleui/@Frame6/@iconequipmentitem6").gameObject;
		self.number6 = self.transform:FindChild("@roleui/@Frame6/@iconequipmentitem6/bgnumber/@number6").gameObject;
		self.Frame7 = self.transform:FindChild("@roleui/@Frame7").gameObject;
		self.btnequipmentadd7 = self.transform:FindChild("@roleui/@Frame7/@btnequipmentadd7").gameObject;
		self.iconequipmentitem7 = self.transform:FindChild("@roleui/@Frame7/@iconequipmentitem7").gameObject;
		self.number7 = self.transform:FindChild("@roleui/@Frame7/@iconequipmentitem7/bgnumber/@number7").gameObject;
		self.Frame8 = self.transform:FindChild("@roleui/@Frame8").gameObject;
		self.btnequipmentadd8 = self.transform:FindChild("@roleui/@Frame8/@btnequipmentadd8").gameObject;
		self.iconequipmentitem8 = self.transform:FindChild("@roleui/@Frame8/@iconequipmentitem8").gameObject;
		self.number8 = self.transform:FindChild("@roleui/@Frame8/@iconequipmentitem8/bgnumber/@number8").gameObject;
		self.textplayername = self.transform:FindChild("@roleui/@textplayername").gameObject;
		self.textfightdigital = self.transform:FindChild("@roleui/@textfightdigital").gameObject;
		self.textmagicdigital = self.transform:FindChild("@roleui/@textmagicdigital").gameObject;
		self.rolemodel = self.transform:FindChild("@rolemodel").gameObject;
	end
	return self;
end
RoleUI = RoleUI or CreateRoleUI();

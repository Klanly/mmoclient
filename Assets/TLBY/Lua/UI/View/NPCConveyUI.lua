----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateNPCConveyUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.rect = self.transform:FindChild("@rect").gameObject;
		self.bg = self.transform:FindChild("@bg").gameObject;
		self.btn1 = self.transform:FindChild("@bg/@btn1").gameObject;
		self.name1 = self.transform:FindChild("@bg/@btn1/@name1").gameObject;
		self.costDes1 = self.transform:FindChild("@bg/@btn1/@costDes1").gameObject;
		self.costNum1 = self.transform:FindChild("@bg/@btn1/@costDes1/@costNum1").gameObject;
		self.costIcon1 = self.transform:FindChild("@bg/@btn1/@costDes1/@costNum1/@costIcon1").gameObject;
		self.btn2 = self.transform:FindChild("@bg/@btn2").gameObject;
		self.name2 = self.transform:FindChild("@bg/@btn2/@name2").gameObject;
		self.costDes2 = self.transform:FindChild("@bg/@btn2/@costDes2").gameObject;
		self.costNum2 = self.transform:FindChild("@bg/@btn2/@costDes2/@costNum2").gameObject;
		self.costIcon2 = self.transform:FindChild("@bg/@btn2/@costDes2/@costNum2/@costIcon2").gameObject;
		self.btn3 = self.transform:FindChild("@bg/@btn3").gameObject;
		self.name3 = self.transform:FindChild("@bg/@btn3/@name3").gameObject;
		self.costDes3 = self.transform:FindChild("@bg/@btn3/@costDes3").gameObject;
		self.costNum3 = self.transform:FindChild("@bg/@btn3/@costDes3/@costNum3").gameObject;
		self.costIcon3 = self.transform:FindChild("@bg/@btn3/@costDes3/@costNum3/@costIcon3").gameObject;
		self.btn4 = self.transform:FindChild("@bg/@btn4").gameObject;
		self.name4 = self.transform:FindChild("@bg/@btn4/@name4").gameObject;
		self.costDes4 = self.transform:FindChild("@bg/@btn4/@costDes4").gameObject;
		self.costNum4 = self.transform:FindChild("@bg/@btn4/@costDes4/@costNum4").gameObject;
		self.costIcon4 = self.transform:FindChild("@bg/@btn4/@costDes4/@costNum4/@costIcon4").gameObject;
		self.btn5 = self.transform:FindChild("@bg/@btn5").gameObject;
		self.name5 = self.transform:FindChild("@bg/@btn5/@name5").gameObject;
		self.costDes5 = self.transform:FindChild("@bg/@btn5/@costDes5").gameObject;
		self.costNum5 = self.transform:FindChild("@bg/@btn5/@costDes5/@costNum5").gameObject;
		self.costIcon5 = self.transform:FindChild("@bg/@btn5/@costDes5/@costNum5/@costIcon5").gameObject;
	end
	return self;
end
NPCConveyUI = NPCConveyUI or CreateNPCConveyUI();

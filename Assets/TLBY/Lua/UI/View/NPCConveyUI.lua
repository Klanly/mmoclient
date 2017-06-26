----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateNPCConveyUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.rect = self.transform:FindChild("@rect").gameObject;
		self.bg = self.transform:FindChild("@bg").gameObject;
		self.btn1 = self.transform:FindChild("@bg/@btn1").gameObject;
		self.name1 = self.transform:FindChild("@bg/@btn1/@name1").gameObject;
		self.btn2 = self.transform:FindChild("@bg/@btn2").gameObject;
		self.name2 = self.transform:FindChild("@bg/@btn2/@name2").gameObject;
		self.btn3 = self.transform:FindChild("@bg/@btn3").gameObject;
		self.name3 = self.transform:FindChild("@bg/@btn3/@name3").gameObject;
		self.btn4 = self.transform:FindChild("@bg/@btn4").gameObject;
		self.name4 = self.transform:FindChild("@bg/@btn4/@name4").gameObject;
		self.btn5 = self.transform:FindChild("@bg/@btn5").gameObject;
		self.name5 = self.transform:FindChild("@bg/@btn5/@name5").gameObject;
	end
	return self;
end
NPCConveyUI = NPCConveyUI or CreateNPCConveyUI();

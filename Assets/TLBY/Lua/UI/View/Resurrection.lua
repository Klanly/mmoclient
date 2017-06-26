----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateResurrection()
	local self = CreateViewBase();
	self.Awake = function()
		self.Resurrectionui = self.transform:FindChild("@Resurrectionui").gameObject;
		self.cost = self.transform:FindChild("@Resurrectionui/@cost").gameObject;
		self.iconAcer = self.transform:FindChild("@Resurrectionui/@cost/@iconAcer").gameObject;
		self.textconsumenumber = self.transform:FindChild("@Resurrectionui/@cost/@textconsumenumber").gameObject;
		self.textconsume = self.transform:FindChild("@Resurrectionui/@cost/@textconsume").gameObject;
		self.btn1 = self.transform:FindChild("@Resurrectionui/@btn1").gameObject;
		self.text1 = self.transform:FindChild("@Resurrectionui/@btn1/@text1").gameObject;
		self.time1 = self.transform:FindChild("@Resurrectionui/@btn1/@time1").gameObject;
		self.btn2 = self.transform:FindChild("@Resurrectionui/@btn2").gameObject;
		self.text2 = self.transform:FindChild("@Resurrectionui/@btn2/@text2").gameObject;
		self.time2 = self.transform:FindChild("@Resurrectionui/@btn2/@time2").gameObject;
		self.btn3 = self.transform:FindChild("@Resurrectionui/@btn3").gameObject;
		self.text3 = self.transform:FindChild("@Resurrectionui/@btn3/@text3").gameObject;
		self.time3 = self.transform:FindChild("@Resurrectionui/@btn3/@time3").gameObject;
		self.texttitle = self.transform:FindChild("@Resurrectionui/title/@texttitle").gameObject;
	end
	return self;
end
Resurrection = Resurrection or CreateResurrection();

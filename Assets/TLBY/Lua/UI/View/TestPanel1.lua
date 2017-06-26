----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateTestPanel1()
	local self = CreateViewBase();
	self.Awake = function()
		self.background = self.transform:FindChild("@background").gameObject;
		self.btn1 = self.transform:FindChild("@btn1").gameObject;
		self.btn2 = self.transform:FindChild("@btn2").gameObject;
		self.btn3 = self.transform:FindChild("@btn3").gameObject;
		self.btn4 = self.transform:FindChild("@btn4").gameObject;
		self.btn5 = self.transform:FindChild("@btn5").gameObject;
		self.text1 = self.transform:FindChild("@text1").gameObject;
		self.text2 = self.transform:FindChild("@text2").gameObject;
		self.text3 = self.transform:FindChild("@text3").gameObject;
		self.text4 = self.transform:FindChild("@text4").gameObject;
		self.text5 = self.transform:FindChild("@text5").gameObject;
		self.input = self.transform:FindChild("@input").gameObject;
		self.input2 = self.transform:FindChild("@input2").gameObject;
		self.input3 = self.transform:FindChild("@input3").gameObject;
		self.input4 = self.transform:FindChild("@input4").gameObject;
		self.input5 = self.transform:FindChild("@input5").gameObject;
	end
	return self;
end
TestPanel1 = TestPanel1 or CreateTestPanel1();

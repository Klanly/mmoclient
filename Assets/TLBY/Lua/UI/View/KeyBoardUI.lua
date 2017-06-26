----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateKeyBoardUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.btnclose = self.transform:FindChild("@btnclose").gameObject;
		self.btn9 = self.transform:FindChild("bgkeyboard/@btn9").gameObject;
		self.btn8 = self.transform:FindChild("bgkeyboard/@btn8").gameObject;
		self.btn7 = self.transform:FindChild("bgkeyboard/@btn7").gameObject;
		self.btn6 = self.transform:FindChild("bgkeyboard/@btn6").gameObject;
		self.btn5 = self.transform:FindChild("bgkeyboard/@btn5").gameObject;
		self.btn4 = self.transform:FindChild("bgkeyboard/@btn4").gameObject;
		self.btn3 = self.transform:FindChild("bgkeyboard/@btn3").gameObject;
		self.btn2 = self.transform:FindChild("bgkeyboard/@btn2").gameObject;
		self.btn1 = self.transform:FindChild("bgkeyboard/@btn1").gameObject;
		self.btn0 = self.transform:FindChild("bgkeyboard/@btn0").gameObject;
		self.btndelete = self.transform:FindChild("bgkeyboard/@btndelete").gameObject;
		self.btnOK = self.transform:FindChild("bgkeyboard/@btnOK").gameObject;
		self.Breakupui = self.transform:FindChild("bgkeyboard/@Breakupui").gameObject;
		self.textdelete = self.transform:FindChild("bgkeyboard/@textdelete").gameObject;
		self.textBreakupdigital = self.transform:FindChild("bgkeyboard/@textBreakupdigital").gameObject;
	end
	return self;
end
KeyBoardUI = KeyBoardUI or CreateKeyBoardUI();

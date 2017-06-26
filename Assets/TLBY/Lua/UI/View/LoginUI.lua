----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateLoginUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.btnAccount = self.transform:FindChild("btns/@btnAccount").gameObject;
		self.btnAnnouncement = self.transform:FindChild("btns/@btnAnnouncement").gameObject;
		self.btnSweep = self.transform:FindChild("btns/@btnSweep").gameObject;
		self.textTitle = self.transform:FindChild("bottom/@textTitle").gameObject;
		self.textEdition = self.transform:FindChild("bottom/@textEdition").gameObject;
		self.textVersion = self.transform:FindChild("bottom/@textVersion").gameObject;
		self.textAnnounce = self.transform:FindChild("bottom/@textAnnounce").gameObject;
		self.enter = self.transform:FindChild("@enter").gameObject;
		self.btnSelectCharacter = self.transform:FindChild("@enter/@btnSelectCharacter").gameObject;
		self.btnSelectServer = self.transform:FindChild("@enter/@btnSelectServer").gameObject;
		self.btnEnterGame = self.transform:FindChild("@enter/@btnEnterGame").gameObject;
		self.textServer = self.transform:FindChild("@enter/@textServer").gameObject;
		self.textCharacter = self.transform:FindChild("@enter/@textCharacter").gameObject;
		self.login = self.transform:FindChild("@login").gameObject;
		self.NameInput = self.transform:FindChild("@login/@NameInput").gameObject;
		self.PwdInput = self.transform:FindChild("@login/@PwdInput").gameObject;
		self.CreateAccount = self.transform:FindChild("@login/@CreateAccount").gameObject;
		self.LoginBtn = self.transform:FindChild("@login/@LoginBtn").gameObject;
		self.waiting = self.transform:FindChild("@login/@waiting").gameObject;
		self.create = self.transform:FindChild("@create").gameObject;
		self.TelInput = self.transform:FindChild("@create/@TelInput").gameObject;
		self.SetPwdInput = self.transform:FindChild("@create/@SetPwdInput").gameObject;
		self.ActiveCodeInput = self.transform:FindChild("@create/@ActiveCodeInput").gameObject;
		self.BtnCreateAccount = self.transform:FindChild("@create/@BtnCreateAccount").gameObject;
		self.btnCloseCreate = self.transform:FindChild("@create/@btnCloseCreate").gameObject;
	end
	return self;
end
LoginUI = LoginUI or CreateLoginUI();

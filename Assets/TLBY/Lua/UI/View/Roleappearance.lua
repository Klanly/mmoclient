----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateRoleappearance()
	local self = CreateViewBase();
	self.Awake = function()
		self.back = self.transform:FindChild("@back").gameObject;
		self.com_btnclose3 = self.transform:FindChild("@com_btnclose3").gameObject;
		self.rolemodel = self.transform:FindChild("@rolemodel").gameObject;
		self.btndyeing = self.transform:FindChild("@btndyeing").gameObject;
		self.textchannel = self.transform:FindChild("@textchannel").gameObject;
		self.btnAccessories = self.transform:FindChild("@btnAccessories").gameObject;
		self.imgNotshow4 = self.transform:FindChild("@btnAccessories/@imgNotshow4").gameObject;
		self.btnarms = self.transform:FindChild("@btnarms").gameObject;
		self.imgNotshow3 = self.transform:FindChild("@btnarms/@imgNotshow3").gameObject;
		self.btnLatestfashion = self.transform:FindChild("@btnLatestfashion").gameObject;
		self.imgNotshow2 = self.transform:FindChild("@btnLatestfashion/@imgNotshow2").gameObject;
		self.btnHeadportrait = self.transform:FindChild("@btnHeadportrait").gameObject;
		self.imgNotshow1 = self.transform:FindChild("@btnHeadportrait/@imgNotshow1").gameObject;
		self.AppearanceMaterialList = self.transform:FindChild("@AppearanceMaterialList").gameObject;
		self.bg4 = self.transform:FindChild("@AppearanceMaterialList/@bg4").gameObject;
		self.iconequipment = self.transform:FindChild("@AppearanceMaterialList/@iconequipment").gameObject;
		self.MaterialScrollView = self.transform:FindChild("@AppearanceMaterialList/@MaterialScrollView").gameObject;
		self.MaterialScrollViewContent = self.transform:FindChild("@AppearanceMaterialList/@MaterialScrollView/Viewport/@MaterialScrollViewContent").gameObject;
		self.AppearanceMaterialBasic = self.transform:FindChild("@AppearanceMaterialBasic").gameObject;
		self.SelQuality = self.transform:FindChild("@AppearanceMaterialBasic/@SelQuality").gameObject;
		self.SelIcon = self.transform:FindChild("@AppearanceMaterialBasic/@SelIcon").gameObject;
		self.btn_buySave = self.transform:FindChild("@AppearanceMaterialBasic/@btn_buySave").gameObject;
		self.Label_foreverTime = self.transform:FindChild("@AppearanceMaterialBasic/@Label_foreverTime").gameObject;
		self.Label_Time = self.transform:FindChild("@AppearanceMaterialBasic/@Label_Time").gameObject;
		self.IntroTxt = self.transform:FindChild("@AppearanceMaterialBasic/@IntroTxt").gameObject;
		self.TitleTxt = self.transform:FindChild("@AppearanceMaterialBasic/@TitleTxt").gameObject;
		self.btnTitle = self.transform:FindChild("@AppearanceMaterialBasic/@btnTitle").gameObject;
		self.TxtFashionTime = self.transform:FindChild("@AppearanceMaterialBasic/@TxtFashionTime").gameObject;
		self.RubbingAppearanceUI = self.transform:FindChild("@RubbingAppearanceUI").gameObject;
		self.iconMateria = self.transform:FindChild("@RubbingAppearanceUI/@iconMateria").gameObject;
		self.com_arrow10 = self.transform:FindChild("@RubbingAppearanceUI/@com_arrow10").gameObject;
		self.ColorScrBar = self.transform:FindChild("@RubbingAppearanceUI/@ColorScrBar").gameObject;
		self.PurityCorScrBar = self.transform:FindChild("@RubbingAppearanceUI/@PurityCorScrBar").gameObject;
		self.LightnessCorScrBar = self.transform:FindChild("@RubbingAppearanceUI/@LightnessCorScrBar").gameObject;
	end
	return self;
end
Roleappearance = Roleappearance or CreateRoleappearance();

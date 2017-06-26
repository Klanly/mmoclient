----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateCampBaseUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.bgyellowinterface = self.transform:FindChild("@bgyellowinterface").gameObject;
		self.bgabove = self.transform:FindChild("@bgabove").gameObject;
		self.textthedeclarationofcamp = self.transform:FindChild("@bgabove/Left/@textthedeclarationofcamp").gameObject;
		self.bgcampmessagebox = self.transform:FindChild("@bgabove/Left/@bgcampmessagebox").gameObject;
		self.textcampmessage = self.transform:FindChild("@bgabove/Left/@textcampmessage").gameObject;
		self.textcampleader = self.transform:FindChild("@bgabove/Left/@textcampleader").gameObject;
		self.textcampaignfunds = self.transform:FindChild("@bgabove/Left/@textcampaignfunds").gameObject;
		self.textcampaignfunds2 = self.transform:FindChild("@bgabove/Left/@textcampaignfunds2").gameObject;
		self.iconsilver = self.transform:FindChild("@bgabove/Left/@iconsilver").gameObject;
		self.btneditor = self.transform:FindChild("@bgabove/Left/@btneditor").gameObject;
		self.texteditor = self.transform:FindChild("@bgabove/Left/@texteditor").gameObject;
		self.btnsalary = self.transform:FindChild("@bgabove/Left/@btnsalary").gameObject;
		self.textsalary2 = self.transform:FindChild("@bgabove/Left/@textsalary2").gameObject;
		self.bgline2 = self.transform:FindChild("@bgabove/Left/@bgline2").gameObject;
		self.textChinesealliance = self.transform:FindChild("@bgabove/Middle/@textChinesealliance").gameObject;
		self.iconChinesealliance = self.transform:FindChild("@bgabove/Middle/@iconChinesealliance").gameObject;
		self.textenchbattleorder = self.transform:FindChild("@bgabove/Right/@textenchbattleorder").gameObject;
		self.textcampaignfunds3 = self.transform:FindChild("@bgabove/Right/@textcampaignfunds3").gameObject;
		self.textsalarycumulative = self.transform:FindChild("@bgabove/Right/@textsalarycumulative").gameObject;
		self.iconsilver1 = self.transform:FindChild("@bgabove/Right/@iconsilver1").gameObject;
		self.textthecurrentposition = self.transform:FindChild("@bgabove/Right/@textthecurrentposition").gameObject;
		self.textthecurrenttitle = self.transform:FindChild("@bgabove/Right/@textthecurrenttitle").gameObject;
		self.btnreceive = self.transform:FindChild("@bgabove/Right/@btnreceive").gameObject;
		self.textreceive = self.transform:FindChild("@bgabove/Right/@textreceive").gameObject;
		self.bgbelowbox = self.transform:FindChild("@bgbelowbox").gameObject;
		self.WarSoulValue = self.transform:FindChild("@bgbelowbox/Left/WarSoulAwake/@WarSoulValue").gameObject;
		self.WarSoulSlider = self.transform:FindChild("@bgbelowbox/Left/WarSoulAwake/@WarSoulSlider").gameObject;
		self.WarSoulLevel = self.transform:FindChild("@bgbelowbox/Left/WarSoulAwake/@WarSoulSlider/HandleRect/@WarSoulLevel").gameObject;
		self.eff_UIzhanhun = self.transform:FindChild("@bgbelowbox/Left/WarSoulAwake/@WarSoulSlider/HandleRect/@WarSoulLevel/@eff_UIzhanhun").gameObject;
		self.TextWarSoulTic = self.transform:FindChild("@bgbelowbox/Left/WarSoulAwake/@TextWarSoulTic").gameObject;
		self.btnWarSoulAwake = self.transform:FindChild("@bgbelowbox/Left/@btnWarSoulAwake").gameObject;
		self.textWarSoulAwake = self.transform:FindChild("@bgbelowbox/Left/@textWarSoulAwake").gameObject;
		self.TextWarSoulDescrip = self.transform:FindChild("@bgbelowbox/Left/@TextWarSoulDescrip").gameObject;
		self.bgprogressbarred = self.transform:FindChild("@bgbelowbox/Middle/progressbarred/@bgprogressbarred").gameObject;
		self.icongoldendesign = self.transform:FindChild("@bgbelowbox/Middle/@icongoldendesign").gameObject;
		self.iconsilverdesign = self.transform:FindChild("@bgbelowbox/Middle/@iconsilverdesign").gameObject;
		self.textsix = self.transform:FindChild("@bgbelowbox/Middle/@textsix").gameObject;
		self.textgeneral1 = self.transform:FindChild("@bgbelowbox/Middle/@textgeneral1").gameObject;
		self.textgenera2 = self.transform:FindChild("@bgbelowbox/Middle/@textgenera2").gameObject;
		self.textseven = self.transform:FindChild("@bgbelowbox/Middle/@textseven").gameObject;
		self.textWarLevelDescrip = self.transform:FindChild("@bgbelowbox/Middle/@textWarLevelDescrip").gameObject;
		self.textLavelBar = self.transform:FindChild("@bgbelowbox/Middle/@textLavelBar").gameObject;
		self.icongettherewards = self.transform:FindChild("@bgbelowbox/Right/@icongettherewards").gameObject;
		self.btngettherewards = self.transform:FindChild("@bgbelowbox/Right/@btngettherewards").gameObject;
		self.textgettherewards = self.transform:FindChild("@bgbelowbox/Right/@textgettherewards").gameObject;
		self.textyellowChinesealliance = self.transform:FindChild("@bgbelowbox/@textyellowChinesealliance").gameObject;
		self.btnHelp = self.transform:FindChild("@btnHelp").gameObject;
	end
	return self;
end
CampBaseUI = CampBaseUI or CreateCampBaseUI();

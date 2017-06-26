----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateFightStatisUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.bgchoiceboxdamage = self.transform:FindChild("yellowpagin/titlegroup/@bgchoiceboxdamage").gameObject;
		self.bgchoiceboxkill_monster = self.transform:FindChild("yellowpagin/titlegroup/@bgchoiceboxkill_monster").gameObject;
		self.bgchoiceboxkill_player = self.transform:FindChild("yellowpagin/titlegroup/@bgchoiceboxkill_player").gameObject;
		self.bgchoiceboxdie = self.transform:FindChild("yellowpagin/titlegroup/@bgchoiceboxdie").gameObject;
		self.bgchoiceboxtreat = self.transform:FindChild("yellowpagin/titlegroup/@bgchoiceboxtreat").gameObject;
		self.bgchoiceboxinhury = self.transform:FindChild("yellowpagin/titlegroup/@bgchoiceboxinhury").gameObject;
		self.textDramaticlist = self.transform:FindChild("yellowpagin/titlegroup/@textDramaticlist").gameObject;
		self.textKillmonster = self.transform:FindChild("yellowpagin/titlegroup/@textKillmonster").gameObject;
		self.textkill = self.transform:FindChild("yellowpagin/titlegroup/@textkill").gameObject;
		self.textdied = self.transform:FindChild("yellowpagin/titlegroup/@textdied").gameObject;
		self.textinput = self.transform:FindChild("yellowpagin/titlegroup/@textinput").gameObject;
		self.texttreatment = self.transform:FindChild("yellowpagin/titlegroup/@texttreatment").gameObject;
		self.textBearingdamage = self.transform:FindChild("yellowpagin/titlegroup/@textBearingdamage").gameObject;
		self.iconuparrowkill_monster = self.transform:FindChild("yellowpagin/titlegroup/@iconuparrowkill_monster").gameObject;
		self.iconuparrowkill_player = self.transform:FindChild("yellowpagin/titlegroup/@iconuparrowkill_player").gameObject;
		self.iconuparrowdie = self.transform:FindChild("yellowpagin/titlegroup/@iconuparrowdie").gameObject;
		self.iconuparrowdamage = self.transform:FindChild("yellowpagin/titlegroup/@iconuparrowdamage").gameObject;
		self.iconuparrowtreat = self.transform:FindChild("yellowpagin/titlegroup/@iconuparrowtreat").gameObject;
		self.iconuparrowinhury = self.transform:FindChild("yellowpagin/titlegroup/@iconuparrowinhury").gameObject;
		self.texttime = self.transform:FindChild("yellowpagin/bgtime/@texttime").gameObject;
		self.btnrefresh = self.transform:FindChild("yellowpagin/@btnrefresh").gameObject;
		self.btnquit = self.transform:FindChild("yellowpagin/@btnquit").gameObject;
		self.textCombatstatistics = self.transform:FindChild("yellowpagin/@textCombatstatistics").gameObject;
		self.scrollview = self.transform:FindChild("yellowpagin/@scrollview").gameObject;
		self.itemtemplate = self.transform:FindChild("yellowpagin/@scrollview/Viewport/Content/@itemtemplate").gameObject;
		self.btnbelow = self.transform:FindChild("@btnbelow").gameObject;
		self.bgPopupwindow = self.transform:FindChild("@btnbelow/@bgPopupwindow").gameObject;
		self.btnnear = self.transform:FindChild("@btnbelow/@bgPopupwindow/rightgroup/@btnnear").gameObject;
		self.btnteam = self.transform:FindChild("@btnbelow/@bgPopupwindow/rightgroup/@btnteam").gameObject;
		self.btnhang = self.transform:FindChild("@btnbelow/@bgPopupwindow/rightgroup/@btnhang").gameObject;
		self.textgang = self.transform:FindChild("@btnbelow/@bgPopupwindow/rightgroup/@textgang").gameObject;
		self.textteam = self.transform:FindChild("@btnbelow/@bgPopupwindow/rightgroup/@textteam").gameObject;
		self.textnear = self.transform:FindChild("@btnbelow/@bgPopupwindow/rightgroup/@textnear").gameObject;
		self.btnrelease = self.transform:FindChild("@btnbelow/@btnrelease").gameObject;
		self.textrelease = self.transform:FindChild("@btnbelow/@btnrelease/@textrelease").gameObject;
		self.btnotherdate = self.transform:FindChild("@btnbelow/leftgroup/@btnotherdate").gameObject;
		self.textotherdata = self.transform:FindChild("@btnbelow/leftgroup/@textotherdata").gameObject;
		self.btnResetdata = self.transform:FindChild("@btnbelow/@btnResetdata").gameObject;
		self.textResetdata = self.transform:FindChild("@btnbelow/@btnResetdata/@textResetdata").gameObject;
	end
	return self;
end
FightStatisUI = FightStatisUI or CreateFightStatisUI();

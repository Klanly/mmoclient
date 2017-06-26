----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateCampTitleUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.textCamptitle = self.transform:FindChild("@textCamptitle").gameObject;
		self.weekPage = self.transform:FindChild("ToggleGroup/@weekPage").gameObject;
		self.totalPage = self.transform:FindChild("ToggleGroup/@totalPage").gameObject;
		self.bgyrllpwpagin = self.transform:FindChild("@bgyrllpwpagin").gameObject;
		self.texttitle = self.transform:FindChild("@bgyrllpwpagin/Tile/@texttitle").gameObject;
		self.textgain = self.transform:FindChild("@bgyrllpwpagin/Tile/@textgain").gameObject;
		self.textgain = self.transform:FindChild("@bgyrllpwpagin/Tile/@textgain").gameObject;
		self.textranking = self.transform:FindChild("@bgyrllpwpagin/Tile/@textranking").gameObject;
		self.bgsettingbelow = self.transform:FindChild("@bgsettingbelow").gameObject;
		self.btnadd = self.transform:FindChild("@bgsettingbelow/@btnadd").gameObject;
		self.bggreenprogressbar = self.transform:FindChild("@bgsettingbelow/@bggreenprogressbar").gameObject;
		self.Slider = self.transform:FindChild("@bgsettingbelow/@Slider").gameObject;
		self.btndragsquare = self.transform:FindChild("@bgsettingbelow/@Slider/HandleRect/@btndragsquare").gameObject;
		self.textRate = self.transform:FindChild("@bgsettingbelow/@textRate").gameObject;
		self.btnreduction = self.transform:FindChild("@bgsettingbelow/@btnreduction").gameObject;
		self.btndonation = self.transform:FindChild("@bgsettingbelow/@btndonation").gameObject;
		self.textdonation = self.transform:FindChild("@bgsettingbelow/@textdonation").gameObject;
		self.textnumber = self.transform:FindChild("@bgsettingbelow/@textnumber").gameObject;
		self.iconsilver = self.transform:FindChild("@bgsettingbelow/@iconsilver").gameObject;
		self.textobtain = self.transform:FindChild("@bgsettingbelow/@textobtain").gameObject;
		self.btnquestion = self.transform:FindChild("@btnquestion").gameObject;
		self.WeakScrollView = self.transform:FindChild("@WeakScrollView").gameObject;
		self.TotalScrollView = self.transform:FindChild("@TotalScrollView").gameObject;
		self.textrankingnumber1 = self.transform:FindChild("RankItem/@textrankingnumber1").gameObject;
		self.textplayernamemessage = self.transform:FindChild("RankItem/@textplayernamemessage").gameObject;
		self.texttitlename2 = self.transform:FindChild("RankItem/@texttitlename2").gameObject;
		self.textobtainnumber1 = self.transform:FindChild("RankItem/@textobtainnumber1").gameObject;
		self.textpsychic1 = self.transform:FindChild("RankItem/@textpsychic1").gameObject;
		self.Top = self.transform:FindChild("RankItem/@Top").gameObject;
		self.TopIcon = self.transform:FindChild("RankItem/@Top/@TopIcon").gameObject;
	end
	return self;
end
CampTitleUI = CampTitleUI or CreateCampTitleUI();

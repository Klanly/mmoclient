----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreatePetDetailUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.expSlider = self.transform:FindChild("bgCenter content/@expSlider").gameObject;
		self.btnRename = self.transform:FindChild("bgCenter content/@btnRename").gameObject;
		self.btnAddExp = self.transform:FindChild("bgCenter content/@btnAddExp").gameObject;
		self.petName = self.transform:FindChild("bgCenter content/@petName").gameObject;
		self.petScrollRect = self.transform:FindChild("bgCenter content/@petScrollRect").gameObject;
		self.btnRest = self.transform:FindChild("btns/@btnRest").gameObject;
		self.btnFree = self.transform:FindChild("btns/@btnFree").gameObject;
		self.btnAppearance = self.transform:FindChild("btns/@btnAppearance").gameObject;
		self.btnAttribute = self.transform:FindChild("btns/@btnAttribute").gameObject;
		self.btnFight = self.transform:FindChild("btns/@btnFight").gameObject;
		self.petmodel = self.transform:FindChild("petModel/@petmodel").gameObject;
		self.petBase = self.transform:FindChild("petModel/@petmodel/@petBase").gameObject;
	end
	return self;
end
PetDetailUI = PetDetailUI or CreatePetDetailUI();

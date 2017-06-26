----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateWorldMapUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.imgmap = self.transform:FindChild("Scroll View/Viewport/Content/@imgmap").gameObject;
		self.city3 = self.transform:FindChild("Scroll View/Viewport/Content/@imgmap/@city3").gameObject;
		self.camp3 = self.transform:FindChild("Scroll View/Viewport/Content/@imgmap/@city3/@camp3").gameObject;
		self.cityName3 = self.transform:FindChild("Scroll View/Viewport/Content/@imgmap/@city3/@cityName3").gameObject;
		self.heroBg3 = self.transform:FindChild("Scroll View/Viewport/Content/@imgmap/@city3/@heroBg3").gameObject;
		self.iconRole3 = self.transform:FindChild("Scroll View/Viewport/Content/@imgmap/@city3/@heroBg3/mask/@iconRole3").gameObject;
		self.city5 = self.transform:FindChild("Scroll View/Viewport/Content/@imgmap/@city5").gameObject;
		self.camp5 = self.transform:FindChild("Scroll View/Viewport/Content/@imgmap/@city5/@camp5").gameObject;
		self.cityName5 = self.transform:FindChild("Scroll View/Viewport/Content/@imgmap/@city5/@cityName5").gameObject;
		self.heroBg5 = self.transform:FindChild("Scroll View/Viewport/Content/@imgmap/@city5/@heroBg5").gameObject;
		self.iconRole5 = self.transform:FindChild("Scroll View/Viewport/Content/@imgmap/@city5/@heroBg5/mask/@iconRole5").gameObject;
		self.city1 = self.transform:FindChild("Scroll View/Viewport/Content/@imgmap/@city1").gameObject;
		self.camp1 = self.transform:FindChild("Scroll View/Viewport/Content/@imgmap/@city1/@camp1").gameObject;
		self.cityName1 = self.transform:FindChild("Scroll View/Viewport/Content/@imgmap/@city1/@cityName1").gameObject;
		self.heroBg1 = self.transform:FindChild("Scroll View/Viewport/Content/@imgmap/@city1/@heroBg1").gameObject;
		self.iconRole1 = self.transform:FindChild("Scroll View/Viewport/Content/@imgmap/@city1/@heroBg1/mask/@iconRole1").gameObject;
		self.city4 = self.transform:FindChild("Scroll View/Viewport/Content/@imgmap/@city4").gameObject;
		self.camp4 = self.transform:FindChild("Scroll View/Viewport/Content/@imgmap/@city4/@camp4").gameObject;
		self.cityName4 = self.transform:FindChild("Scroll View/Viewport/Content/@imgmap/@city4/@cityName4").gameObject;
		self.heroBg4 = self.transform:FindChild("Scroll View/Viewport/Content/@imgmap/@city4/@heroBg4").gameObject;
		self.iconRole4 = self.transform:FindChild("Scroll View/Viewport/Content/@imgmap/@city4/@heroBg4/mask/@iconRole4").gameObject;
		self.city2 = self.transform:FindChild("Scroll View/Viewport/Content/@imgmap/@city2").gameObject;
		self.camp2 = self.transform:FindChild("Scroll View/Viewport/Content/@imgmap/@city2/@camp2").gameObject;
		self.cityName2 = self.transform:FindChild("Scroll View/Viewport/Content/@imgmap/@city2/@cityName2").gameObject;
		self.heroBg2 = self.transform:FindChild("Scroll View/Viewport/Content/@imgmap/@city2/@heroBg2").gameObject;
		self.iconRole2 = self.transform:FindChild("Scroll View/Viewport/Content/@imgmap/@city2/@heroBg2/mask/@iconRole2").gameObject;
		self.city6 = self.transform:FindChild("Scroll View/Viewport/Content/@imgmap/@city6").gameObject;
		self.camp6 = self.transform:FindChild("Scroll View/Viewport/Content/@imgmap/@city6/@camp6").gameObject;
		self.cityName6 = self.transform:FindChild("Scroll View/Viewport/Content/@imgmap/@city6/@cityName6").gameObject;
		self.heroBg6 = self.transform:FindChild("Scroll View/Viewport/Content/@imgmap/@city6/@heroBg6").gameObject;
		self.iconRole6 = self.transform:FindChild("Scroll View/Viewport/Content/@imgmap/@city6/@heroBg6/mask/@iconRole6").gameObject;
		self.city7 = self.transform:FindChild("Scroll View/Viewport/Content/@imgmap/@city7").gameObject;
		self.camp7 = self.transform:FindChild("Scroll View/Viewport/Content/@imgmap/@city7/@camp7").gameObject;
		self.cityName7 = self.transform:FindChild("Scroll View/Viewport/Content/@imgmap/@city7/@cityName7").gameObject;
		self.heroBg7 = self.transform:FindChild("Scroll View/Viewport/Content/@imgmap/@city7/@heroBg7").gameObject;
		self.iconRole7 = self.transform:FindChild("Scroll View/Viewport/Content/@imgmap/@city7/@heroBg7/mask/@iconRole7").gameObject;
		self.city8 = self.transform:FindChild("Scroll View/Viewport/Content/@imgmap/@city8").gameObject;
		self.camp8 = self.transform:FindChild("Scroll View/Viewport/Content/@imgmap/@city8/@camp8").gameObject;
		self.cityName8 = self.transform:FindChild("Scroll View/Viewport/Content/@imgmap/@city8/@cityName8").gameObject;
		self.heroBg8 = self.transform:FindChild("Scroll View/Viewport/Content/@imgmap/@city8/@heroBg8").gameObject;
		self.iconRole8 = self.transform:FindChild("Scroll View/Viewport/Content/@imgmap/@city8/@heroBg8/mask/@iconRole8").gameObject;
		self.btnClose = self.transform:FindChild("@btnClose").gameObject;
	end
	return self;
end
WorldMapUI = WorldMapUI or CreateWorldMapUI();

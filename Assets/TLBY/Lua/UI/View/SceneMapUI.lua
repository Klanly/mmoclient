----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateSceneMapUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.scrollView = self.transform:FindChild("@scrollView").gameObject;
		self.imgMap = self.transform:FindChild("@scrollView/Viewport/@imgMap").gameObject;
		self.dotNPC = self.transform:FindChild("@scrollView/Viewport/@imgMap/@dotNPC").gameObject;
		self.routeDots = self.transform:FindChild("@scrollView/Viewport/@imgMap/@routeDots").gameObject;
		self.dotRoute = self.transform:FindChild("@scrollView/Viewport/@imgMap/@routeDots/@dotRoute").gameObject;
		self.rightPos = self.transform:FindChild("@scrollView/Viewport/@imgMap/@rightPos").gameObject;
		self.dotOwn = self.transform:FindChild("@scrollView/Viewport/@imgMap/@dotOwn").gameObject;
		self.dotFence = self.transform:FindChild("@scrollView/Viewport/@imgMap/@dotFence").gameObject;
		self.dotEnemy = self.transform:FindChild("@scrollView/Viewport/@imgMap/@dotEnemy").gameObject;
		self.dotTeammate = self.transform:FindChild("@scrollView/Viewport/@imgMap/@dotTeammate").gameObject;
		self.dotOtherPlayers = self.transform:FindChild("@scrollView/Viewport/@imgMap/@dotOtherPlayers").gameObject;
		self.sceneName = self.transform:FindChild("@sceneName").gameObject;
		self.pos = self.transform:FindChild("@pos").gameObject;
		self.btnClose = self.transform:FindChild("@btnClose").gameObject;
		self.btnWorldMap = self.transform:FindChild("@btnWorldMap").gameObject;
		self.btnSwitchChannel = self.transform:FindChild("@btnSwitchChannel").gameObject;
		self.btnNPC = self.transform:FindChild("@btnNPC").gameObject;
	end
	return self;
end
SceneMapUI = SceneMapUI or CreateSceneMapUI();

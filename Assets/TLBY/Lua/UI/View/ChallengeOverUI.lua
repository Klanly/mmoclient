----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateChallengeOverUI()
	local self = CreateViewBase();
	self.Awake = function()
		self.btnResult = self.transform:FindChild("@btnResult").gameObject;
		self.txtResult = self.transform:FindChild("@btnResult/@txtResult").gameObject;
		self.mask = self.transform:FindChild("@mask").gameObject;
		self.WinGroup = self.transform:FindChild("@mask/@WinGroup").gameObject;
		self.imgGrade = self.transform:FindChild("@mask/@WinGroup/@imgGrade").gameObject;
		self.imgwin = self.transform:FindChild("@mask/@WinGroup/@imgwin").gameObject;
		self.txtMark = self.transform:FindChild("@mask/@WinGroup/@txtMark").gameObject;
		self.rewardTitle = self.transform:FindChild("@mask/@WinGroup/rewardItems/@rewardTitle").gameObject;
		self.rewardItem = self.transform:FindChild("@mask/@WinGroup/rewardItems/Viewport/Content/@rewardItem").gameObject;
		self.gradeBarGroup = self.transform:FindChild("@mask/@WinGroup/@gradeBarGroup").gameObject;
		self.imgProgress = self.transform:FindChild("@mask/@WinGroup/@gradeBarGroup/@imgProgress").gameObject;
		self.txtTime1 = self.transform:FindChild("@mask/@WinGroup/@gradeBarGroup/@txtTime1").gameObject;
		self.txtTime2 = self.transform:FindChild("@mask/@WinGroup/@gradeBarGroup/@txtTime2").gameObject;
		self.txtTime3 = self.transform:FindChild("@mask/@WinGroup/@gradeBarGroup/@txtTime3").gameObject;
		self.txtTime4 = self.transform:FindChild("@mask/@WinGroup/@gradeBarGroup/@txtTime4").gameObject;
		self.txtTime5 = self.transform:FindChild("@mask/@WinGroup/@gradeBarGroup/@txtTime5").gameObject;
		self.FailedGroup = self.transform:FindChild("@mask/@FailedGroup").gameObject;
		self.text1 = self.transform:FindChild("@mask/@FailedGroup/@text1").gameObject;
		self.text2 = self.transform:FindChild("@mask/@FailedGroup/@text2").gameObject;
		self.text3 = self.transform:FindChild("@mask/@FailedGroup/@text3").gameObject;
		self.btnQuit = self.transform:FindChild("@mask/@btnQuit").gameObject;
		self.txtQuit = self.transform:FindChild("@mask/@btnQuit/@txtQuit").gameObject;
		self.txtCountdown = self.transform:FindChild("@mask/@btnQuit/@txtCountdown").gameObject;
		self.btnStay = self.transform:FindChild("@mask/@btnStay").gameObject;
		self.txtStay = self.transform:FindChild("@mask/@btnStay/@txtStay").gameObject;
	end
	return self;
end
ChallengeOverUI = ChallengeOverUI or CreateChallengeOverUI();

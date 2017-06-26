----------------------- auto generate code --------------------------
require "UI/View/LuaViewBase"

local function CreateDailyTask()
	local self = CreateViewBase();
	self.Awake = function()
		self.btnClose = self.transform:FindChild("@btnClose").gameObject;
		self.btnhunting = self.transform:FindChild("bgselectionpage/@btnhunting").gameObject;
		self.btndaily = self.transform:FindChild("bgselectionpage/@btndaily").gameObject;
		self.btnWelfare = self.transform:FindChild("bgselectionpage/@btnWelfare").gameObject;
		self.DailyPart = self.transform:FindChild("@DailyPart").gameObject;
		self.taskList = self.transform:FindChild("@DailyPart/abovearea/@taskList").gameObject;
		self.template_daily = self.transform:FindChild("@DailyPart/abovearea/@taskList/Viewport/Content/@template_daily").gameObject;
		self.icontreasurechest1 = self.transform:FindChild("@DailyPart/bgbelowarea/@icontreasurechest1").gameObject;
		self.textten1 = self.transform:FindChild("@DailyPart/bgbelowarea/@icontreasurechest1/@textten1").gameObject;
		self.icontreasurechest2 = self.transform:FindChild("@DailyPart/bgbelowarea/@icontreasurechest2").gameObject;
		self.textten2 = self.transform:FindChild("@DailyPart/bgbelowarea/@icontreasurechest2/@textten2").gameObject;
		self.icontreasurechest3 = self.transform:FindChild("@DailyPart/bgbelowarea/@icontreasurechest3").gameObject;
		self.textten3 = self.transform:FindChild("@DailyPart/bgbelowarea/@icontreasurechest3/@textten3").gameObject;
		self.icontreasurechest4 = self.transform:FindChild("@DailyPart/bgbelowarea/@icontreasurechest4").gameObject;
		self.textten4 = self.transform:FindChild("@DailyPart/bgbelowarea/@icontreasurechest4/@textten4").gameObject;
		self.icontreasurechest5 = self.transform:FindChild("@DailyPart/bgbelowarea/@icontreasurechest5").gameObject;
		self.textten5 = self.transform:FindChild("@DailyPart/bgbelowarea/@icontreasurechest5/@textten5").gameObject;
		self.btn_canledar = self.transform:FindChild("@DailyPart/bgbelowarea/bgrefreshbox/@btn_canledar").gameObject;
		self.textrefresh = self.transform:FindChild("@DailyPart/bgbelowarea/bgrefreshbox/@textrefresh").gameObject;
		self.textactivenumber = self.transform:FindChild("@DailyPart/bgbelowarea/bgactivebox/@textactivenumber").gameObject;
		self.textactive = self.transform:FindChild("@DailyPart/bgbelowarea/bgactivebox/@textactive").gameObject;
		self.HuntPart = self.transform:FindChild("@HuntPart").gameObject;
		self.btn_world_boss = self.transform:FindChild("@HuntPart/ToggleGroup/@btn_world_boss").gameObject;
		self.btn_boss = self.transform:FindChild("@HuntPart/ToggleGroup/@btn_boss").gameObject;
		self.contractScrollView = self.transform:FindChild("@HuntPart/@contractScrollView").gameObject;
		self.template_hunt = self.transform:FindChild("@HuntPart/@contractScrollView/Viewport/contractList/@template_hunt").gameObject;
		self.txt_task_name = self.transform:FindChild("@HuntPart/TaskDetail/@txt_task_name").gameObject;
		self.text_descrip = self.transform:FindChild("@HuntPart/TaskDetail/@text_descrip").gameObject;
		self.text_descrip2 = self.transform:FindChild("@HuntPart/TaskDetail/@text_descrip2").gameObject;
		self.template_hunt_detail_item = self.transform:FindChild("@HuntPart/TaskDetail/ScrollView/Viewport/Content/@template_hunt_detail_item").gameObject;
		self.btnHelp = self.transform:FindChild("@btnHelp").gameObject;
	end
	return self;
end
DailyTask = DailyTask or CreateDailyTask();

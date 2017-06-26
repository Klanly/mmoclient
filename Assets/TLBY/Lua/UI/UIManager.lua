---------------------------------------------------
-- auth： panyinglong
-- date： 2016/8/16
-- desc： ctrl的管理类，所有的lua view创建和销毁应该通过此类
---------------------------------------------------

require "Common/basic/LuaObject"
require "UI/UIGrayMaterial"

ViewAssets = { -- {ui resource path, ui control path}
    MainLandUI = 	{"MainLand/MainLandUI", 	"UI/Controller/MainLandUICtrl",},
	-- StampUI = 		{"StampUI", 					"UI/Controller/StampUICtrl"},
    TipsUI = 	    {"Common/TipsUI", 	"UI/Controller/TipsUICtrl"},
	ItemTipsUI = 	{"AutoGenerate/Equip/ItemTipsUI", 	"UI/Controller/ItemTipsUICtrl"},
	EquipTipsUI = 	{"AutoGenerate/Equip/EquipTipsUI", 	"UI/Controller/EquipTipsUICtrl"},
	ConfirmUI = 	{"AutoGenerate/Fight/ConfirmUI", 		"UI/Controller/ConfirmUICtrl"},
	GoldenFingerUI = {"GoldenFingerUI", 			"UI/Controller/GoldenFingerUICtrl"},
	RoleUI = 		{"AutoGenerate/Hero/RoleUI", 		"UI/Controller/RoleUICtrl",['rank'] = 1},
	BagUI = 		{"AutoGenerate/Hero/BagUI", 			"UI/Controller/BagUICtrl",['tip'] = 1010},
	RoleAttributeUI = {"AutoGenerate/Hero/RoleAttributeUI", "UI/Controller/RoleAttributeUICtrl"},
	CatchPetUI = 	{"AutoGenerate/Pet/CatchPetUI",		"UI/Controller/CatchPetUICtrl"},
	ObtainUI = 		{"AutoGenerate/Challenge/ObtainUI",			"UI/Controller/ObtainUICtrl"},
	PromptUI = 		{"PromptUI/PromptUI",			"UI/Controller/PromptUICtrl"},
	WeaponsUI = 	{"AutoGenerate/Pet/weaponsui",		"UI/Controller/WeaponsUICtrl",['tip'] = 1210,['rank'] = 1},
    PetUI = 		{"AutoGenerate/Pet/PetUI",			"UI/Controller/PetUICtrl",['rank'] = 1},
    PetDetailUI = 	{"AutoGenerate/Pet/PetDetailUI",    "UI/Controller/PetDetailUICtrl"},
    PetAttributeUI = {"AutoGenerate/Pet/PetAttributeUI",			"UI/Controller/PetAttributeUICtrl"},
    PetSkillUI = 	{"AutoGenerate/Pet/PetSkillUI",    "UI/Controller/PetSkillUICtrl",['tip'] = 1240},
    PetMergeEatUI = {"AutoGenerate/Pet/PetMergeEatUI",  "UI/Controller/PetMergeEatUICtrl",['tip'] = 1220},
    PetMergeEatAttributeUI = 		{"AutoGenerate/Pet/PetMergeEatAttributeUI",			"UI/Controller/PetMergeEatAttributeUICtrl"},
    PetUpgradeUI = 	{"AutoGenerate/Pet/PetUpgradeUI",				"UI/Controller/PetUpgradeUICtrl"},
    ChallengeUI = 	{"AutoGenerate/Challenge/ChallengeUI",	"UI/Controller/ChallengeUICtrl",['tip'] = 1270,['rank'] = 1},
    ChallengeOverUI = {"AutoGenerate/Challenge/ChallengeOverUI","UI/Controller/ChallengeOverUICtrl"},
	EquipmentUI = 	{"AutoGenerate/Equip/EquipmentUI",	"UI/Controller/EquipmentUICtrl",['rank'] = 1},
	EquipmentStrengthenUI = {"AutoGenerate/Equip/EquipmentStrengthenUI","UI/Controller/EquipmentStrengthenUICtrl",['tip'] = 1150},
	EquipmentUpgradeStarUI = {"AutoGenerate/Equip/EquipmentUpgradeStarUI","UI/Controller/EquipmentUpgradeStarUICtrl",['tip'] = 1250},
	EquipmentSmeltingUI = {"AutoGenerate/Equip/EquipmentSmeltingUI","UI/Controller/EquipmentSmeltingUICtrl",['tip'] = 1160},
	PurchaseUI = 	{"AutoGenerate/Main/PurchaseUI",		"UI/Controller/PurchaseUICtrl"},
    NormalShopUI = 	{"NormalShopUI",				"UI/Controller/NormalShopUICtrl",['rank'] = 1},
    WanderShopUI = 	{"WanderShopUI",				"UI/Controller/WanderShopUICtrl",['tip'] = 1501,['rank'] = 1},
    KeyBoardUI = 	{"AutoGenerate/Main/KeyBoardUI",					"UI/Controller/KeyBoardUICtrl"},
	CompareEquipTipsUI = {"AutoGenerate/Equip/CompareEquipTipsUI","UI/Controller/CompareEquipTipsUICtrl"},
	TeamInviteUI = {"AutoGenerate/Team/TeamInviteUI","UI/Controller/TeamInviteUICtrl"},
    CreateRoleUI =  {'AutoGenerate/Main/CreateRoleUI',                'UI/Controller/CreateRoleUICtrl'},
    NPCTalkUI = 	{"AutoGenerate/Main/NPCTalkUI",					"UI/Controller/NPCTalkUICtrl"},
	Resurrection = 	{"AutoGenerate/Hero/Resurrection",	"UI/Controller/ResurrectionCtrl"},
	PropertyChangeUI = {"AutoGenerate/Hero/PropertyChangeUI","UI/Controller/PropertyChangeUICtrl"},
	Sweep = 		{"AutoGenerate/Challenge/Sweep",			"UI/Controller/SweepCtrl"},
    FriendsUI = 	{"FriendUI/FriendsUI",			"UI/Controller/FriendsUICtrl",['tip'] = 1360,['rank'] = 1},
	PlayerOpUI = 	{"FriendUI/PlayerOpUI",			"UI/Controller/PlayerOpUICtrl"},
	FriendsAddUI = 	{"FriendUI/FriendsAddUI",		"UI/Controller/FriendsAddUICtrl"},
	FriendsApproveUI = {"FriendUI/FriendsApproveUI","UI/Controller/FriendsApproveUICtrl"},
	PlayerTalkUI = 	{"FriendUI/PlayerTalkUI",		"UI/Controller/PlayerTalkUICtrl"},
	SystemMsgUI = 	{"FriendUI/SystemMsgUI",		"UI/Controller/SystemMsgUICtrl"},
    ContractSelectNoteUI = {'FriendUI/ContractSelectNoteUI',"UI/Controller/ContractSelectNoteUICtrl"},
	LoginPanelUI = 	{"LoginUI/LoginUI",			"UI/Controller/LoginPanelUICtrl",'full'},
	SelectRoleUI =  {"AutoGenerate/Main/SelectRoleUI",	"UI/Controller/SelectRoleUICtrl"},
    Overlordlist = 	{"AutoGenerate/Challenge/Overlordlist",	"UI/Controller/OverlordlistCtrl"},
    SkillSet = 		{"AutoGenerate/Hero/SkillSet",		"UI/Controller/SkillSetCtrl",['tip'] = 1120},
    ChatUI = 		{'FriendUI/ChatUI',						"UI/Controller/ChatUICtrl",['tip'] = 1030},
    ChatConsumeUI = {'FriendUI/ChatConsumeUI',				"UI/Controller/ChatConsumeUICtrl"},
    SpeakerUI = 	{'SpeakerUI',					"UI/Controller/SpeakerUICtrl"},
    EquipGemUI = 	{'AutoGenerate/Equip/EquipGemUI',		"UI/Controller/EquipGemUICtrl",['tip'] = 1170},
    ArenaSelect = 	{'AutoGenerate/Arena/ArenaSelect',	"UI/Controller/ArenaSelectCtrl",['tip'] = 1350},
    ArenaRankList = {'AutoGenerate/Arena/ArenaRankList',	"UI/Controller/ArenaRankListCtrl"},
    DialogueUI = 		{'AutoGenerate/Fight/DialogueUI',			"UI/Controller/DialogueUICtrl"},
    ArenaResult = 	{'AutoGenerate/Arena/ArenaResult',	"UI/Controller/ArenaResultCtrl"},
    ArenaReward = 	{'AutoGenerate/Arena/ArenaReward',	"UI/Controller/ArenaRewardCtrl"},
    ArenaMatch = 	{'AutoGenerate/Arena/ArenaMatch',		"UI/Controller/ArenaMatchCtrl"},
    ArenaPetSetting = {'AutoGenerate/Arena/ArenaPetSetting',"UI/Controller/ArenaPetSettingCtrl"},
    EquipGemTipUI = {'AutoGenerate/Equip/EquipGemTipUI',	"UI/Controller/EquipGemTipUICtrl"},
    EquipGemHandleUI = {'AutoGenerate/Equip/EquipGemHandleUI',"UI/Controller/EquipGemHandleUICtrl"},
	CommTextTipUI = {'Common/CommTextTipUI', 				"UI/Controller/CommTextTipUICtrl"},
	UnLockPetSkillTipUI = {'UnLockPetUI/UnLockPetSkillTipUI', 	"UI/Controller/UnLockPetSkillTipUICtrl"},
	CampUI = 		{'CampUI/CampUI', 				"UI/Controller/CampUIControl/CampUICtrl",['tip'] = 1550,['rank'] = 1},
    CampTitleUI = 		{'CampUI/CampTitleUI', 				"UI/Controller/CampUIControl/CampTitleUICtrl"},
    CampBaseUI = 		{'CampUI/CampBaseUI', 				"UI/Controller/CampUIControl/CampBaseUICtrl"},
    CampTaskUI = 		{'CampUI/CampTaskUI', 				"UI/Controller/CampUIControl/CampTaskUICtrl"},
    CampBattleUI = 		{'CampUI/CampBattleUI', 				"UI/Controller/CampUIControl/CampBattleUICtrl"},
    CampBattleStatusUI = 		{'CampUI/CampBattleStatusUI', 				"UI/Controller/CampUIControl/CampBattleStatusUICtrl"},
    CampBattleScoreUI = 		{'CampUI/CampBattleScoreUI', 				"UI/Controller/CampUIControl/CampBattleScoreUICtrl"},
    CampItemSubmitUI = 		{'CampUI/CampItemSubmitUI', 				"UI/Controller/CampUIControl/CampItemSubmitUICtrl"},
	TitleDescrip = 	{'TitleDescrip/TitleDescrip', 	"UI/Controller/TitleDescripCtrl"},
    WorldMapUI = 	{'MapUI/WorldMapUI', 			"UI/Controller/WorldMapUICtrl"},
    SceneMapUI = 	{'MapUI/SceneMapUI', 			"UI/Controller/SceneMapUICtrl"},
    SwitchChannelUI = {'MapUI/SwitchChannelUI', 	"UI/Controller/SwitchChannelUICtrl"},
	CommRewardsBox = {'Common/CommRewardsBox', 		"UI/Controller/CommRewardsBoxCtrl"},
    ArenaTimerUI = 	{'AutoGenerate/Arena/ArenaTimerUI', 				'UI/Controller/ArenaTimerUICtrl'},
	CommTipBox1 = 	{'Common/CommTipBox1', 			"UI/Controller/CommTipBox1Ctrl"},
	PKUI = 			{'AutoGenerate/Hero/PKUI', 			"UI/Controller/PKUICtrl"},
    ProcessBarUI = {'Common/ProcessBarUI', 'UI/Controller/ProcessBarUICtrl'},
    RichProcessBarUI = {'RichProcessBarUI', 'UI/Controller/RichProcessBarUICtrl'},
    TeamApplyUI = {'AutoGenerate/Team/TeamApplyUI','UI/Controller/TeamApplyUICtrl',['tip'] = 1281,['rank'] = 1},
    TeamOpUI = {'AutoGenerate/Team/TeamOpUI','UI/Controller/TeamOpUICtrl'},
    TeamConfirmUI = {'AutoGenerate/Team/TeamConfirmUI','UI/Controller/TeamConfirmUICtrl'},
    TeamUI = {'AutoGenerate/Team/TeamUI','UI/Controller/TeamUICtrl',['rank'] = 1},
    TeamChangeTargetUI = {'AutoGenerate/Team/TeamChangeTargetUI','UI/Controller/TeamChangeTargetUICtrl'},
    TeamDungeonUI = {'AutoGenerate/Team/TeamDungeonUI','UI/Controller/TeamDungeonUICtrl',['tip'] = 1280,['rank'] = 1},
    BuffProgressBarUI = {'AutoGenerate/Fight/BuffProgressBarUI','UI/Controller/BuffProgressBarUICtrl'},
    SelectServerUI = {'LoginUI/SelectServerUI','UI/Controller/SelectServerUICtrl'},
    ArenaMixMatch = {'AutoGenerate/Arena/ArenaMixMatch', 'UI/Controller/ArenaMixMatchCtrl'},
    PetImproveUI = {'AutoGenerate/Pet/PetImproveUI','UI/Controller/PetImproveUICtrl'},
    TeamRankListUI = {'AutoGenerate/Team/TeamRankListUI','UI/Controller/TeamRankListUICtrl'},
    FightStatisUI = {'AutoGenerate/Fight/FightStatisUI', "UI/Controller/FightStatisUICtrl"},
    WaitServerResponseUI = {'NetUI/WaitServerResponseUI','UI/Controller/WaitServerResponseUICtrl'},
	SystemSettingUI = {'AutoGenerate/Main/SystemSetting','UI/Controller/SystemSettingCtrl',['tip'] = 1090,['rank'] = 1},
    MailUI = {'AutoGenerate/Hero/MailUI','UI/Controller/MailUICtrl',['tip'] = 1040,['rank'] = 1},
    MallUI = {'AutoGenerate/Main/MallUI','UI/Controller/MallUICtrl',['tip'] = 1110,['rank'] = 1},
	ArenaMatchingUI = {'AutoGenerate/ArenaUI/ArenaMatchingUI','UI/Controller/ArenaMatchingUICtrl'},
	PetappearanceUI = {'AutoGenerate/Pet/Petappearance', 'UI/Controller/PetUIControl/PetappearanceUICtrl',['tip'] = 1180},
	ModifyNameUI = {'AutoGenerate/Hero/ModifyNameUI','UI/Controller/ModifyNameUICtrl'},
	GiftGivingUI = {'AutoGenerate/GiftGiving/GiftGivingUI','UI/Controller/GiftGivingUICtrl'},
    PlayerResourceUI = {'AutoGenerate/Hero/PlayerResourceUI','UI/Controller/PlayerResourceUICtrl'},
    FactionUI = {'AutoGenerate/Faction/FactionUI','UI/Controller/FactionUICtrl',['rank'] = 1},
    FactionMembersUI = {'AutoGenerate/Faction/FactionMembersUI','UI/Controller/FactionMembersUICtrl'},
    FactionCreateUI = {'AutoGenerate/Faction/FactionCreateUI','UI/Controller/FactionCreateUICtrl'},
    FactionApplyUI = {'AutoGenerate/Faction/FactionApplyUI','UI/Controller/FactionApplyUICtrl'},
    FactionPositionUI = {'AutoGenerate/Faction/FactionPositionUI','UI/Controller/FactionPositionUICtrl'},
    FactionBuildingUI = {'AutoGenerate/Faction/FactionBuildingUI','UI/Controller/FactionBuildingUICtrl'},
    DailyTask = {'AutoGenerate/DailyTask/DailyTask','UI/Controller/DailyTaskCtrl',['tip'] = 1050},
    DailyTaskCan = {'AutoGenerate/DailyTask/DailyTaskCan','UI/Controller/DailyTaskCanCtrl'},
    DailyTaskTip1 = {'AutoGenerate/DailyTask/DailyTaskTip1','UI/Controller/DailyTaskTip1Ctrl'},
    DailyTaskTip2 = {'AutoGenerate/DailyTask/DailyTaskTip2','UI/Controller/DailyTaskTip2Ctrl'},
    TaskUI = {'AutoGenerate/Hero/TaskUI','UI/Controller/TaskUICtrl',['tip'] = 1020},
	RoleappearanceUI = {'AutoGenerate/Hero/Roleappearance','UI/Controller/RoleappearanceCtrl'},
	CollectUI = {'CollectUI','UI/Controller/CollectUICtrl'},
	UnionInformationsUI = {'AutoGenerate/Faction/UnionInformations', 'UI/Controller/UnionUIControl/UnionInformationsUICtrl'},
	UnionListUI = {'AutoGenerate/Faction/UnionList', 'UI/Controller/UnionUIControl/UnionListUICtrl'},
	UnionAntagonizeSettingUI = {'AutoGenerate/Faction/UnionAntagonizeSetting', 'UI/Controller/UnionUIControl/UnionAntagonizeSettingUICtrl'},
	RankingListUI = {'AutoGenerate/Arena/RankingList', 'UI/Controller/RankingUIControl/RankingListUICtrl'},
    WelfareUI = {'AutoGenerate/Hero/WelfareUI', 'UI/Controller/WelfareUICtrl',['rank'] = 1},
    SelectTargetUI = {'AutoGenerate/Main/SelectTargetUI', 'UI/Controller/SelectTargetUICtrl'},
    NPCConveyUI = {'AutoGenerate/Main/NPCConveyUI', 'UI/Controller/NPCConveyUICtrl'},
    TopNoticeUI = {'AutoGenerate/TopNoticeUI', 'UI/Controller/TopNoticeUICtrl'},
	IndependentBtnUI = {'AutoGenerate/IndependentBtnUI', 'UI/Controller/RankingUIControl/IndependentBtnUICtrl'},
	CampOfficeUI = {'CampUI/CampOffice', 'UI/Controller/CampUIControl/CampOfficeUICtrl'},
	TalentUI = {'AutoGenerate/Talent', "UI/Controller/TalentUICtrl"},
};

local Canvas = GameObject.Find('Canvas')
local PopCanvas = GameObject.Find("PopCanvas")
local tfUIManager = PopCanvas.transform.parent
local const = require "Common/constant"
local fullMask = nil

LayerGroup = {
	scene = "Canvas/scene",
    sceneDamage = "Canvas/sceneDamage",
	base = "Canvas/base",
	pop = "Canvas/pop",
	login = "Canvas/login",
	notice = "Canvas/notice",
	network = "PopCanvas/network",
    loading = 'PopCanvas/loading',
	popCanvas = "PopCanvas/normal",
}

local FormatFirstRankViews = function()
    local tb = {}
    for k,v in pairs(ViewAssets) do
        if v.rank then
            tb[v[1]] = v
        end
    end
    return tb
end
local FirstRankViews = FormatFirstRankViews()

local function CreateUIManager()
	local self = CreateObject()
	local viewCtrlDic = {}
	local ctrls = {}
     
	local cacheViews = {} -- 缓存，比如退出副本后要打开副本UI，就可以先将副本UI缓存起来　

	local setAsLastSibling = function(ctrl)
		if not ctrls[ctrl.layer] then
			return
		end
		local replace = -1
		for i, v in ipairs(ctrls[ctrl.layer]) do
			if v == ctrl then
				replace = i
				break
			end
		end
		if replace > 0 then	
			table.remove(ctrls[ctrl.layer], replace)
			table.insert(ctrls[ctrl.layer], ctrl)
			ctrl.view.transform:SetAsLastSibling()
		end
	end
    
    local setSiblingIndex = function(ctrl)
		if not ctrls[ctrl.layer] then
			return
		end
		local replace = -1
		for i, v in ipairs(ctrls[ctrl.layer]) do
			if v == ctrl then
				replace = i
				break
			end
		end
		if replace > 0 then	
			table.remove(ctrls[ctrl.layer], replace)
			table.insert(ctrls[ctrl.layer], ctrl)
			ctrl.view.transform:SetAsLastSibling()
		end
	end

	local parent = function(layer)
        return tfUIManager:FindChild(layer)
	end
    
    self.SetParent = function(obj,layer)
        obj.transform:SetParent(parent(layer),false)
    end
    
	local UpdateResourceBar = function()
        for i=#ctrls[LayerGroup.pop],1,-1 do
            local data = ctrls[LayerGroup.pop][i].resourceBar
            if data then
                self.PushView(ViewAssets.PlayerResourceUI,function(ctrl) 
				ctrl.UpdateDynamicData(data)
                ctrl.view.transform:SetSiblingIndex(ctrls[LayerGroup.pop][i].view.transform:GetSiblingIndex() + 1)
				end)
                return
            end
        end
        self.UnloadView(ViewAssets.PlayerResourceUI)
    end
    
	local Load = function(asset,callback,...)
 		local ctrl = self.GetCtrl(asset)
 		ctrl.onLoadCallback = callback
 		if ctrl.isLoading then
            ctrl.isClosed = false
 			return
 		end
 		ctrl.isClosed = false
		ctrl.args = {...}
		ctrl.asset = asset
 		if ctrl.isLoaded then
 			setAsLastSibling(ctrl)
 			ctrl.onActive(...)
			if ctrl.resourceBar then
                  UpdateResourceBar()
             end
 		else
            if FirstRankViews[asset[1]] then
                for k,v in pairs(FirstRankViews) do
                    if asset ~= v then
                        self.UnloadView(v)
                    end
                end
            end
            ctrl.isLoading = true
            ResourceManager.CreateUI(asset[1],function(obj)
            	if ctrl.isClosed then -- 加载完成前, 就已经关了
            		ctrl.isLoading = false
            		RecycleObject(obj)
            		return
            	end
				go =  obj
				go.transform:SetParent(parent(ctrl.layer), false)
				go.transform.localScale = Vector3.one
				self.SetFullUI(go)
	
				local luaBehavior = go:GetComponent('LuaBehaviour')
				if not luaBehavior then
					luaBehavior = go:AddComponent('LuaBehaviour')
				end
				luaBehavior.assetName = asset[1]
	
				ctrl.luaBehaviour = luaBehavior
				ctrl.view = ctrl.luaBehaviour.luaTable
            	ctrl.isLoading = false
				ctrl.isLoaded = true
				ctrl.onLoad(unpack(ctrl.args))
				self.AddHelpTip(ctrl,asset[3])
				ctrl.isActived = true
				ctrl.onActive()
				
				local layer = ctrl.layer
				if not ctrls[layer] then
					ctrls[layer] = {}
				end
				table.insert(ctrls[layer], ctrl)
                if ctrl.resourceBar then
                  	UpdateResourceBar()
                end
			    if ctrl.onLoadCallback then
			    	ctrl.onLoadCallback(ctrl)
			    	ctrl.onLoadCallback = nil
			    end
		  end)	
        end
	end

 	local UnLoad = function(asset)
 		local ctrl = self.GetCtrl(asset)
 		ctrl.isClosed = true

 		local layer = ctrl.layer
 		if not ctrls[layer] then
 			return
 		end
		if not ctrl.isLoaded then
			return
		end

		-- 移除base
		local delete = -1
		for i, v in ipairs(ctrls[layer]) do
			if v == ctrl then
				delete = i
				break
			end
		end
		if delete > 0 then	
			if self.IsTopView(ctrl.layer, ctrl.asset) then
				ctrl.isActived = false
				ctrl.onDeactive()
			end
			ctrl.isLoaded = false
			ctrl.onUnload()
			RecycleObject(ctrl.view.gameObject)
			ctrl.luaBehaviour = nil
			ctrl.view = nil

			table.remove(ctrls[layer], delete)
		end
        
        if ctrl.resourceBar then
            UpdateResourceBar()
        end
        
		return ctrl
	end

	--- public function 
	-- 卸载view
	self.UnloadView = function(asset)
		return UnLoad(asset)
	end

	-- 先卸载最顶层的view, 再加载目标view
	self.LoadView = function(asset,callback,...)
 		local ctrl = self.GetCtrl(asset)
 		if ctrl.isLoading then
 			return
 		end
 		if self.IsTopView(ctrl.layer, asset) then
 			return
 		end
 		local top = self.Top(ctrl.layer)
		if top then
			UnLoad(top.asset)
		end
		Load(asset,callback,...)
	end

	-- 不卸载之前的，直接加载目标view
	self.PushView = function(asset,callback,...)
		return Load(asset,callback,...)
	end

	self.IsTopView = function(layer, asset)
		local ctrl = self.GetCtrl(asset)
		if not ctrls[layer] then
			return false
		end

		local layerCtrls = ctrls[layer]
		if #layerCtrls > 0 and layerCtrls[#layerCtrls] == ctrl then
			return true
		end

		return false
	end

	-- 获取顶层的控制器ctrl
	self.Top = function(layer)
		if not ctrls[layer] then
			return nil
		end

		local layerCtrls = ctrls[layer]
		if #layerCtrls > 0 then
			return layerCtrls[#layerCtrls]
		end

		return nil
	end

	-- 卸载所有的view force表示强力卸载,会先设isLock = false
	self.UnloadAll = function(force)
		for layer, layerCtrls in pairs(ctrls) do
			for i = #layerCtrls, 1, -1 do
				local ctrl = layerCtrls[i]
				if force then
					ctrl.isLock = false
				end
				ctrl.close()
			end
		end
	end
	-- 缓存当前打开的view后
	self.CacheLoadedViews = function()
		cacheViews = {}
		for layer, layerCtrls in pairs(ctrls) do
			for i = 1, #layerCtrls do
				local ctrl = layerCtrls[i]
				if ctrl.enableCache then
					table.insert(cacheViews, ctrl.asset)
				end
			end
		end
	end
	self.LoadCacheViews = function()
		for i = 1, #cacheViews do
			local asset = cacheViews[i]
			local ctrl = self.GetCtrl(asset)
			if not ctrl.isLoaded then
				self.PushView(asset,nil, unpack(ctrl.args))
			end
		end
	end
	self.ClearCacheViews = function()
		cacheViews = {}
	end
	
	self.UnloadViewsByLayer = function(layer)
		for layer, layerCtrls in pairs(ctrls) do
			for i = #layerCtrls, 1, -1 do
				local ctrl = layerCtrls[i]
				if ctrl.layer == layer then
					ctrl.close()
				end
			end
		end
	end
	self.HideAll = function()
		for layer, layerCtrls in pairs(ctrls) do
			for i = #layerCtrls, 1, -1 do
				local ctrl = layerCtrls[i]
				ctrl.hide()
			end
		end
	end
	self.ShowAll = function()
		for layer, layerCtrls in pairs(ctrls) do
			for i = #layerCtrls, 1, -1 do
				local ctrl = layerCtrls[i]
				ctrl.show()
			end
		end
	end
	self.HideViewsByLayer = function(layer)
		for layer, layerCtrls in pairs(ctrls) do
			for i = #layerCtrls, 1, -1 do
				local ctrl = layerCtrls[i]
				if ctrl.layer == layer then
					ctrl.hide()
				end
			end
		end
	end
	self.ShowViewsByLayer = function(layer)
		for layer, layerCtrls in pairs(ctrls) do
			for i = #layerCtrls, 1, -1 do
				local ctrl = layerCtrls[i]
				if ctrl.layer == layer then
					ctrl.show()
				end				
			end
		end
	end

	self.GetCtrl = function(asset)
		if not viewCtrlDic[asset[1]] then			
			viewCtrlDic[asset[1]] = require (asset[2])
			-- local splits = string.split(asset[2], '/')
			-- _G[splits[#splits]] = viewCtrlDic[asset[1]] --定义一个全局的UI控制器
		end
		return viewCtrlDic[asset[1]]
	end

    -------------
    self.ShowNotice = function(MSG)
    	local ctrl = UIManager.GetCtrl(ViewAssets.PromptUI)
    	if ctrl.isLoaded then
    		ctrl.UpdateMsg(MSG)
    	else
	        self.PushView(ViewAssets.PromptUI, function(c)
	        	c.UpdateMsg(MSG)
	        end)
	    end
    end
    
    local processBarTimer = nil
    self.ShowProcessBar = function(value,text)
        if processBarTimer then
            Timer.Remove(processBarTimer)
            processBarTimer = nil
        end
        local bar = UIManager.GetCtrl(ViewAssets.ProcessBarUI)
       if not bar.isLoaded then
            self.PushView(ViewAssets.ProcessBarUI,function(obj)
			bar.UpdateText(text)
			bar.UpdateValue(value)
			end)
        end
        bar.UpdateValue(value)
    end
    
    self.ShowProcessBarByTime = function(totalTime,text,func, ...)
         local args = {...}
         -- self.HideProcessBar()
        self.PushView(ViewAssets.ProcessBarUI,function(obj)
		local bar =  obj
		bar.UpdateText(text)
        local passTime = 0 
        local UpdateProcessbar = function()
            passTime = passTime + 0.03
            bar.UpdateValue(passTime/totalTime)
            if passTime > totalTime then
                if func then
                    func(unpack(args))
                end
                self.HideProcessBar()
            end
        end
        processBarTimer = Timer.Repeat(0.03, UpdateProcessbar)
		end)
    end
    
    self.HideProcessBar = function()
        UIManager.UnloadView(ViewAssets.ProcessBarUI)
        if processBarTimer then
            Timer.Remove(processBarTimer)
            processBarTimer = nil
        end
    end
    
    self.ShowErrorMessage = function(error_id)
    	if not error_id then
    		return
    	end
    	if MSG_ERROR[error_id] then
			UIManager.ShowNotice(MSG_ERROR[error_id])
		else
			print("没有找到错误描述 error_id=" .. error_id)
		end
	end
	self.ShowDialog = function(text, okText, cancelText, okCallback, cancelCallback,defaultOperation,defaultDelay)
		UIManager.GetCtrl(ViewAssets.DialogueUI).PushDialog(text or '',okText,cancelText,okCallback,cancelCallback,defaultOperation,defaultDelay)
	end
    
    local notices = {}
    self.ShowTopNotice = function(text)
        local ctrl = UIManager.GetCtrl(ViewAssets.TopNoticeUI)
        if not ctrl.isLoaded then
            self.PushView(ViewAssets.TopNoticeUI,function(obj) ctrl.AddNotice(text) end)
		else
           ctrl.AddNotice(text)
		end
    end
    
    local sceneLoadingUI = nil
    self.ShowLoadingUI = function(id)
        if sceneLoadingUI == nil then
            ResourceManager.CreateUI('Loading/SceneLoadingUI',function(obj) 
			  sceneLoadingUI = obj
			  self.SetParent(sceneLoadingUI,LayerGroup.loading)
              self.SetFullUI(sceneLoadingUI)
              sceneLoadingUI:GetComponent("LuaBehaviour").luaTable.UpdateScene(id)
              sceneLoadingUI:SetActive(true)
			end)
        end
    end
    
    self.HideLoadingUI = function()
		RecycleObject(sceneLoadingUI)
        GameObject.Destroy(sceneLoadingUI)
        sceneLoadingUI = nil
        if SceneManager.currentSceneType == const.SCENE_TYPE.CITY or SceneManager.currentSceneType == const.SCENE_TYPE.WILD then
            if SceneManager.GetEntityManager().hero and SceneManager.GetEntityManager().hero.behavior then
                SceneManager.GetEntityManager().hero.behavior:UpdateBehavior('fall')
            end
		end
    end
    
    self.SetFullUI = function(gameObject)
        local rectTransform = gameObject:GetComponent('RectTransform')
        rectTransform.offsetMax = Vector2.zero
        rectTransform.offsetMin = Vector2.zero
        rectTransform.anchorMax = Vector2.one
        rectTransform.anchorMin = Vector2.zero
    end
    
    self.AddHelpTip = function(ctrl,id)
        if ctrl.view.btnHelp and id then
            local systemList = GetConfig('common_system_list')
            if systemList.system[id].Description ~= 0 then
                ClickEventListener.Get(ctrl.view.btnHelp).onClick = function() self.PushView(ViewAssets.TipsUI,nil,id) end
                ctrl.view.btnHelp:SetActive(true)
            else
                ctrl.view.btnHelp:SetActive(false)
            end
        end
    end
    
    local number = 0
    self.ShowGetDropItemUI = function(data)
        ResourceManager.CreateUI('Common/GetDropItemUI',function(obj)
		   local clone = obj
		   clone:GetComponent('LuaBehaviour').luaTable.SetData(data,number)
           self.SetParent(clone,LayerGroup.notice)
           clone.transform:SetAsFirstSibling()
           number = number+1
           if number == 5 then
              number = 0
           end
		end)
    end
    
    self.ShowFullMask = function()
        if not fullMask then
            fullMask = tfUIManager:FindChild('PopCanvas/loading/mask').gameObject
        end
		fullMask:SetActive(true)
    end
    
    self.HideFullMask = function()
        if not fullMask then
            fullMask = tfUIManager:FindChild('PopCanvas/loading/mask').gameObject
        end
		fullMask:SetActive(false)
    end
    
    self.ShowCollectUI = function(collectTime, onCollectOver)
    	self.PushView(ViewAssets.CollectUI,nil, collectTime, onCollectOver)
	end

	-- self.ShowFixedDialog = function(data)
	-- 	UIManager.PushView(ViewAssets.UIFixedDialog, data)
	-- end
	-- self.CloseFixedDialog = function()
	-- 	UIManager.UnloadView(ViewAssets.UIFixedDialog)
	-- end
	
	self.GetTopCanvas = function()
    	return Canvas
	end
    
    self.ShowAllUI = function(show)
        Canvas:SetActive(show)
        PopCanvas:SetActive(show)
    end
	
	return self
end

UIManager = UIManager or CreateUIManager()

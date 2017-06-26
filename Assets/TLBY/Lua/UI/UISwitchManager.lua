---------------------------------------------------
-- auth： panyinglong
-- date： 2017/3/16
-- desc： 界面快捷开关
---------------------------------------------------

require "Common/basic/LuaObject"
local systemTable = GetConfig('common_system_list')

local function CreateUISwitchManager()
	local self = CreateObject()
    
    self.OpenSceneObjectUI = function(id)
        local hero = SceneManager.GetEntityManager().hero
        local data = systemTable.system[id]
        local info = data['gotolink'..MyHeroManager.heroData.country]
        hero:moveToUnit(info[3], info[1], info[2],3, function() self.OpenUI(id) end)
    end
    
	self.OpenUI = function(id, callback, ...)
		local args = {...}
		if id == 1010 then --背包
			UIManager.PushView(ViewAssets.RoleUI, callback, unpack(args))
		elseif id == 1020 then -- 任务
			UIManager.PushView(ViewAssets.TaskUI, callback, unpack(args))
		elseif id == 1030 then -- 聊天
			UIManager.GetCtrl(ViewAssets.MainLandUI).chatUI.OnExpand()
		elseif id == 1040 then -- 邮件
			UIManager.GetCtrl(ViewAssets.MailUI).OpenUI()
		elseif id == 1050 then -- 日常活动			
			UIManager.PushView(ViewAssets.DailyTask, callback, unpack(args))
		elseif id == 1060 then -- 充值
			error('没有找到 ui id=' .. id)
		elseif id == 1070 then -- 榜单
			error('没有找到 ui id=' .. id)
		elseif id == 1080 then -- 引导
			error('没有找到 ui id=' .. id)
		elseif id == 1090 then -- 设置
			UIManager.PushView(ViewAssets.SystemSettingUI, callback, unpack(args))
		elseif id == 1100 then -- 积分商店
			error('没有找到 ui id=' .. id)
		elseif id == 1110 then -- 商城
			UIManager.GetCtrl(ViewAssets.MallUI).OpenUI()
		elseif id == 1120 then -- 技能
			UIManager.PushView(ViewAssets.SkillSet, callback, unpack(args))
		elseif id == 1130 then -- 天赋
			error('没有找到 ui id=' .. id)
		elseif id == 1140 then -- 锻造
            UIManager.PushView(ViewAssets.EquipmentUI,function(ctrl) ctrl.ShowTab(1) end)
		elseif id == 1150 then -- 装备强化
			UIManager.PushView(ViewAssets.EquipmentUI,function(ctrl) ctrl.ShowTab(1) end)
		elseif id == 1160 then -- 装备洗练
			UIManager.PushView(ViewAssets.EquipmentUI,function(ctrl) ctrl.ShowTab(3) end)
		elseif id == 1170 then -- 宝石
			UIManager.PushView(ViewAssets.EquipmentUI,function(ctrl) ctrl.ShowTab(4) end)
        elseif id == 1171 then -- 宝石合成
			UIManager.PushView(ViewAssets.EquipGemHandleUI,nil,1)
		elseif id == 1180 then -- 宠物外观
			error('没有找到 ui id=' .. id)
		elseif id == 1190 then -- 宠物收集
			UIManager.PushView(ViewAssets.WeaponsUI, callback, unpack(args))
		elseif id == 1200 then -- 时装
			UIManager.PushView(ViewAssets.RoleappearanceUI, callback, unpack(args))
		elseif id == 1210 then -- 宝印
			UIManager.PushView(ViewAssets.WeaponsUI, callback, unpack(args))
		elseif id == 1211 then -- 宝印进阶
			UIManager.PushView(ViewAssets.WeaponsUI, callback, unpack(args))
		elseif id == 1220 then -- 宠物吞噬
            UIManager.GetCtrl(ViewAssets.PetUI).ShowPetUI(4)
		elseif id == 1230 then -- 宠物融合
			UIManager.GetCtrl(ViewAssets.PetUI).ShowPetUI(3)
		elseif id == 1240 then -- 宠物技能
			UIManager.GetCtrl(ViewAssets.PetUI).ShowPetUI(2)
		elseif id == 1250 then -- 装备星级
			UIManager.PushView(ViewAssets.EquipmentUI,function(ctrl) ctrl.ShowTab(2) end)
		elseif id == 1260 then -- 神器
			error('没有找到 ui id=' .. id)
		elseif id == 1270 then -- 主线副本
			UIManager.PushView(ViewAssets.ChallengeUI, callback, unpack(args))
        elseif id == 1271 then -- 副本商店
			UIManager.GetCtrl(ViewAssets.NormalShopUI).OpenUI('copy')
		elseif id == 1280 then -- 组队副本
			UIManager.GetCtrl(ViewAssets.TeamDungeonUI).OpenUI()
		elseif id == 1281 then -- 快捷组队
			UIManager.PushView(ViewAssets.TeamApplyUI, callback, unpack(args))
		elseif id == 1290 then -- 机缘副本
			error('没有找到 ui id=' .. id)
		elseif id == 1300 then -- 通天塔
			error('没有找到 ui id=' .. id)
		elseif id == 1310 then -- PK系统
			error('没有找到 ui id=' .. id)
		elseif id == 1320 then -- 跨服战场1
			error('没有找到 ui id=' .. id)
		elseif id == 1330 then -- 跨服战场2
			error('没有找到 ui id=' .. id)
		elseif id == 1340 then -- 跨服战场3
			error('没有找到 ui id=' .. id)
		elseif id == 1350 then -- 竞技场
			UIManager.PushView(ViewAssets.ArenaSelect, callback, unpack(args))
		elseif id == 1351 then -- 竞技场-混战
			UIManager.PushView(ViewAssets.ArenaSelect, callback, unpack(args))
		elseif id == 1352 then -- 竞技场商店
			UIManager.GetCtrl(ViewAssets.NormalShopUI).OpenUI('arena')
		elseif id == 1360 then -- 好友
			ContactManager.PushView(ViewAssets.FriendsUI, callback, unpack(args))
		elseif id == 1370 then -- 情缘
			error('没有找到 ui id=' .. id)
		elseif id == 1380 then -- 师徒
			error('没有找到 ui id=' .. id)
		elseif id == 1390 then -- 帮会基础
			if FactionManager.InFaction() then
				UIManager.PushView(ViewAssets.FactionUI, callback, unpack(args))
	        else
				UIManager.PushView(ViewAssets.UnionListUI, callback, unpack(args))
	        end
		elseif id == 1391 then -- 帮贡商店
			UIManager.GetCtrl(ViewAssets.NormalShopUI).OpenUI('confraternity')
        elseif id == 1392 then -- 帮会大厅
			UIManager.GetCtrl(ViewAssets.FactionBuildingUI).OpenUI(1)
        elseif id == 1393 then -- 祭坛
			UIManager.GetCtrl(ViewAssets.FactionBuildingUI).OpenUI(3)
        elseif id == 1394 then -- 金库
			UIManager.GetCtrl(ViewAssets.FactionBuildingUI).OpenUI(2)
		elseif id == 1400 then -- 帮会副本
			error('没有找到 ui id=' .. id)
		elseif id == 1410 then -- 帮会战
			error('没有找到 ui id=' .. id)
		elseif id == 1420 then -- 帮会红包
			error('没有找到 ui id=' .. id)
		elseif id == 1430 then -- 帮会仓库
			error('没有找到 ui id=' .. id)
		elseif id == 1440 then -- 打坐
			error('没有找到 ui id=' .. id)
		elseif id == 1450 then -- 传功
			error('没有找到 ui id=' .. id)
		elseif id == 1460 then -- 称号
			error('没有找到 ui id=' .. id)
		elseif id == 1470 then -- 交易
			error('没有找到 ui id=' .. id)
		elseif id == 1480 then -- 成就
			error('没有找到 ui id=' .. id)
		elseif id == 1490 then -- 店铺
			error('没有找到 ui id=' .. id)
		elseif id == 1500 then -- 杂货铺
			UIManager.GetCtrl(ViewAssets.NormalShopUI).OpenUI('grocery')
		elseif id == 1501 then -- 云游商人
			UIManager.PushView(ViewAssets.WanderShopUI, callback, unpack(args))
		elseif id == 1510 then -- 生活技能
			error('没有找到 ui id=' .. id)
		elseif id == 1520 then -- 首冲
			error('没有找到 ui id=' .. id)
		elseif id == 1530 then -- 签到
			error('没有找到 ui id=' .. id)
		elseif id == 1540 then -- 社交
			UIManager.GetCtrl(ViewAssets.MailUI).OpenUI()
		elseif id == 1550 then -- 阵营
			UIManager.PushView(ViewAssets.CampUI, callback, unpack(args))
        elseif id == 1551 then -- 功勋商店
			UIManager.GetCtrl(ViewAssets.NormalShopUI).OpenUI('camp')
        elseif id == 1502 then -- 黑市
			UIManager.GetCtrl(ViewAssets.NormalShopUI).OpenUI('blackmarket')
		elseif id == 1560 then -- 挑战
			UIManager.PushView(ViewAssets.ChallengeUI, callback, unpack(args))
		elseif id == 1600 then -- 基础设置
			UIManager.PushView(ViewAssets.SystemSettingUI, callback, unpack(args))
		elseif id == 1601 then -- 高级设置
            UIManager.PushView(ViewAssets.SystemSettingUI, function(ctrl)
            	ctrl.view.btnHookset:GetComponent('Toggle').isOn = true
            end)
		elseif id == 1602 then -- 帐号设置
            UIManager.PushView(ViewAssets.SystemSettingUI, function(ctrl)
            	ctrl.view.btnHookset:GetComponent('Toggle').isOn = true
            end)
		elseif id == 1603 then -- 挂机设置
            UIManager.PushView(ViewAssets.SystemSettingUI, function(ctrl)
            	ctrl.view.btnHookset:GetComponent('Toggle').isOn = true
            end)
		else
			error('没有找到 ui id=' .. id)
		end
	end

	self.GetUIName = function(id)
		local ui = systemTable.system[id]
		if not ui then
			error('没有找到ui id='.. id)
		end
		return ui.name
	end

	return self
end

UISwitchManager = UISwitchManager or CreateUISwitchManager()
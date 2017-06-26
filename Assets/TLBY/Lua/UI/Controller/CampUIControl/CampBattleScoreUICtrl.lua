require "UI/Controller/LuaCtrlBase"

local function CreateCampBattleScoreUICtrl()
    local self = CreateCtrlBase()
    self.layer = LayerGroup.popCanvas
	
    local dataList = nil

    local BindData = function(item,key,camp)
        local data = dataList.battle_achievement_list[camp][key+1]
        item.transform:Find('level'):GetComponent('TextMeshProUGUI').text = 'LV'..data.level
        item.transform:Find('kill'):GetComponent('TextMeshProUGUI').text = data.kill
        item.transform:Find('death'):GetComponent('TextMeshProUGUI').text = data.die
        item.transform:Find('name'):GetComponent('TextMeshProUGUI').text = data.name
        item.transform:Find('score'):GetComponent('TextMeshProUGUI').text = data.score
    end
    
    self.OpenUI = function()
        MessageRPCManager.AddUser(self, 'GetDetailBattleAchievementListRet')
        local data = {}
        data.func_name = 'on_get_detail_battle_achievement_list'
        MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
    end
    
    self.GetDetailBattleAchievementListRet = function(data)
        if data.result == 0 then
            UIManager.PushView(ViewAssets.CampBattleScoreUI,nil,data.info)
        end
    end
    
    self.onLoad = function(data)
        self.AddClick(self.view.btnClose,self.close)
        
        dataList = data
        for i=1,2 do
            self.view['playerItem'..i]:SetActive(false)
            local scrollView = self.view['scrollView'..i]:GetComponent('UIMultiScroller')
            scrollView:Init(self.view['playerItem'..i],848,50,0,9,1)
            scrollView:UpdateData(#dataList.battle_achievement_list[i],function(obj,k)BindData(obj,k,i) end)
            
            local killMost = nil
            for j=1,#dataList.battle_achievement_list[i] do
                local temp = dataList.battle_achievement_list[i][j]
                if killMost==nil or killMost.kill < temp.kill then
                    killMost = temp
                end
            end
            
            self.view['score'..i]:GetComponent('TextMeshProUGUI').text = dataList.country_total_score[i]
            if killMost then
                self.view['killMost'..i]:GetComponent('TextMeshProUGUI').text = killMost.name
            else
                self.view['killMost'..i]:GetComponent('TextMeshProUGUI').text = '无'
            end
            self.view['leftBoss'..i]:GetComponent('TextMeshProUGUI').text = dataList.alive_boss_num[i]
        end

    end

    self.onUnload = function()
        MessageRPCManager.RemoveUser(self, 'GetDetailBattleAchievementListRet')
    end

    return self
end

return CreateCampBattleScoreUICtrl()


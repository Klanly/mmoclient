local uitext = GetConfig('common_char_chinese').UIText

local function CreateWorldMapUICtrl()
	local self = CreateCtrlBase()
    local sceneTable = require'Logic/Scheme/common_scene'

    local SwitchSceneHandle = function(id)
        if id == SceneManager.currentSceneId then return end
        self.close()
        local hero = SceneManager.GetEntityManager().hero
        if hero then hero:Convey(id) end
        -- if id == SceneManager.currentSceneId then return end
        -- local data = {}
		-- data.func_name = 'on_mini_map_switch_scene'
		-- data.scene_id = id
		-- MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)      --请求传送
    end

    local SwitchScene = function(id)
        if ArenaManager.IsOnMatching() then
            UIManager.ShowDialog(uitext[1135003].NR, uitext[1135004].NR, uitext[1135005].NR, nil, function()
                ArenaManager.RequestCancelMatchMixFight()
                SwitchSceneHandle(id)
            end)
        elseif SceneManager.IsOnFightServer() then
            UIManager.ShowNotice('当前场景不能传送')
        else
            SwitchSceneHandle(id)
        end
    end
    
	self.onLoad = function()
        self.AddClick(self.view.btnClose,self.close)
        for i=1,8 do
            self.view['city'..i]:SetActive(false)
        end
        for _,v in pairs(sceneTable.MainScene) do
            local role = self.view['iconRole'..v.ID]
            self.view['city'..v.ID]:SetActive(true)
            if role then 
                self.view['heroBg'..v.ID]:SetActive(v.ID == SceneManager.currentSceneId)
                role:GetComponent('Image').overrideSprite = LuaUIUtil.GetHeroIcon(MyHeroManager.heroData.vocation,MyHeroManager.heroData.sex)
            end
            
            if (v.Party == 0 or v.Party == MyHeroManager.heroData.country) and v.EnterLevel <= MyHeroManager.heroData.level  and v['Location'..MyHeroManager.heroData.country] > 0 then
                self.AddClick(self.view['city'..v.ID],function() SwitchScene(v.ID) end)
                self.view['cityName'..v.ID]:GetComponent('TextMeshProUGUI').text = LuaUIUtil.GetTextByID(v,'Name')
            else
                self.view['cityName'..v.ID]:GetComponent('TextMeshProUGUI').text = LuaUIUtil.GetTextByID(v,'Name')
                self.AddClick(self.view['city'..v.ID],function() UIManager.ShowNotice('敌对阵营区域无法传送') end)
            end
        end
        --self.view.city8:SetActive(UnityEngine.Application.isEditor)
	end
	
	self.onUnload = function()
	end
	
	self.onActive = function()
	end

	self.onDeactive = function()
	end

	return self
end

return CreateWorldMapUICtrl()
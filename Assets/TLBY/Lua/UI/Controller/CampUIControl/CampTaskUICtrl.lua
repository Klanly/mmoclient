require "UI/Controller/LuaCtrlBase"

local function CreateCampTaskUICtrl()
    local self = CreateCtrlBase()
    local taskList = {}
    local mapConfig = GetConfig("common_scene")
    local modelConfig= GetConfig('common_art_resource').Model
    local currentTabIndex = -1
    local taskTable = GetConfig('pvp_country_war').CampNpcTask
	
    local BindData = function(item,key)
        
        local statusData = taskList[currentTabIndex][key+1]
        local data = taskTable[statusData.ElementID]
        local elementData = mapConfig[mapConfig.MainScene[data.MapID].SceneSetting][data.ElementID]
        item.transform:Find('name'):GetComponent('TextMeshProUGUI').text = LuaUIUtil.GetTextByID(elementData,'Name')
        item.transform:Find('mask/icon'):GetComponent('Image').overrideSprite = ResourceManager.LoadSprite(modelConfig[elementData.ModelID].icon)
        item.transform:Find('hp'):GetComponent('Image').fillAmount = statusData.hp/statusData.max_hp
        item.transform:Find('energy'):GetComponent('Image').fillAmount = statusData.energy/statusData.energy_max
        item.transform:Find('hpValue'):GetComponent('TextMeshProUGUI').text = statusData.hp..'/'..statusData.max_hp
        item.transform:Find('energyValue'):GetComponent('TextMeshProUGUI').text = statusData.energy..'/'..statusData.energy_max
        local goBtn = item.transform:Find('btns/btnRepair/btnRepair').gameObject
        self.AddClick(goBtn,function()         
            local hero = SceneManager.GetEntityManager().hero
            hero:moveToUnit(data.ElementID,mapConfig.MainScene[data.MapID].SceneType,data.MapID,3,function(cm)
                cm.behavior:InterAct()
            end)
            UIManager.UnloadView(ViewAssets.CampUI)
        end)
    end
    
    local OnTabClick = function(index)
        currentTabIndex = index
        self.view['tab'..index]:GetComponent('Toggle').isOn = true     
        self.view.scrollView:GetComponent('UIMultiScroller'):UpdateData(#taskList[index],BindData)
    end
    
    self.onLoad = function()

        self.view.taskItem:SetActive(false)
        for i=1,2 do
            self.AddClick(self.view['tab'..i],function() OnTabClick(i) end)
        end
        self.view.scrollView:GetComponent('UIMultiScroller'):Init(self.view.taskItem,848,200,0,10,2)
        
        local data = {}
        data.func_name = 'query_country_npc_info'
        MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
        
        MessageRPCManager.AddUser(self, 'QueryCountryNpcInfoRet')
        
    end
    
    self.QueryCountryNpcInfoRet  = function(data)
        if data.npcs_status then
            taskList = {}   
            for k,v in pairs(data.npcs_status) do
                if mapConfig.MainScene[taskTable[k].MapID]['Location'..MyHeroManager.heroData.country] > 0 then
                    if taskList[taskTable[k].TaskType] == nil then
                        taskList[taskTable[k].TaskType] = {}
                    end
                    v.ElementID = k
                    table.insert(taskList[taskTable[k].TaskType],v)
                end
               
            end
            OnTabClick(1)
        end
    end

    self.onUnload = function()
        MessageRPCManager.RemoveUser(self, 'QueryCountryNpcInfoRet')
    end

    return self
end

return CreateCampTaskUICtrl()


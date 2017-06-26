require "UI/Controller/LuaCtrlBase"

local function CreateWelfareUICtrl()
    local self = CreateCtrlBase()
    local tabItems = {}
    local awardItems = {}
    local awardActivityItems = {}
    local activityDesItems = {}
    local subPage = {'dailyAwardPage','awardActivityPage','normalActivityPage','serialNumberPage'}
     
    local tableDatas = 
    {
        [1] = { ['name'] = 3128912, ['ios'] = true, ['page'] = 'awardActivityPage', ['subtab'] = {--
            [1] = {['name'] = 3128940,['award'] = 3128941,['des'] = 3128942,},
            [2] = {['name'] = 3128955,['award'] = 3128956,['des'] = 3128957,},
            [3] = {['name'] = 3128943,['award'] = 3128944,['des'] = 3128945,},
            [4] = {['name'] = 3128946,['award'] = 3128947,['des'] = 3128948,},
            [5] = {['name'] = 3128949,['award'] = 3128950,['des'] = 3128951,},
            [6] = {['name'] = 3128952,['award'] = 3128953,['des'] = 3128954,}, 
            }},
        [2] = { ['name'] = 3128909, ['ios'] = true, ['page'] = 'dailyAwardPage', ['subtab'] = {
            [1] = {['name'] = 3128913,['award'] = 3128914,['des'] = 3128915,},
            }},
        [3] = { ['name'] = 3128910, ['ios'] = true, ['page'] = 'awardActivityPage', ['subtab'] = {
            [1] = {['name'] = 3128916,['award'] = 3128917,['des'] = 3128918,},
            [2] = {['name'] = 3128925,['award'] = 3128926,['des'] = 3128927,},
            --[3] = {['name'] = 3128922,['award'] = 3128923,['des'] = 3128924,},
            [3] = {['name'] = 3128934,['award'] = 3128935,['des'] = 3128936,},
            [4] = {['name'] = 3128928,['award'] = 3128929,['des'] = 3128930,},
            [5] = {['name'] = 3128931,['award'] = 3128932,['des'] = 3128933,},           
            [6] = {['name'] = 3128919,['award'] = 3128920,['des'] = 3128921,},
            }},
        [4] = { ['name'] = 3128911, ['ios'] = false, ['page'] = 'awardActivityPage', ['subtab'] = {--国之栋梁
            [1] = {['name'] = 3128959,['award'] = 3128960,['des'] = 3128961,},
            }},
        [5] = { ['name'] = 3128958, ['ios'] = true, ['page'] = 'awardActivityPage',['subtab'] = {--冲级先锋
            [1] = {['name'] = 3128937,['award'] = 3128938,['des'] = 3128939,},
            }},            
        [6] = { ['name'] = 3128913, ['ios'] = false, ['page'] = 'serialNumberPage'},             
    }
    
    local textTable = GetConfig("common_char_chinese").TableText
    local GetText = function(id)
        return textTable[id].NR
    end
    
    local UpdateData = function(data,item)
        if item.transform:Find('bg'):GetComponent('Toggle').isOn then return end
        item.transform:Find('bg'):GetComponent('Toggle').isOn = true
        for i=1,#subPage do
            self.view[subPage[i]]:SetActive(false)
        end
        self[data.page](data)
    end
    
    self.dailyAwardPage = function(data)
        self.view.dailyAwardPage:SetActive(true)
        self.view.dailyAwardPage.transform:Find('des'):GetComponent('TextMeshProUGUI').text = GetText(data.subtab[1].des)
        self.view.dailyAwardPage.transform:Find('award'):GetComponent('TextMeshProUGUI').text = GetText(data.subtab[1].award)
    end
    self.awardActivityPage = function(data)
        self.view.awardActivityPage:SetActive(true)
        for i=1,#data.subtab do
            if awardActivityItems[i] == nil then
                awardActivityItems[i] = GameObject.Instantiate(self.view.awardActivityItem)
                
                awardActivityItems[i].transform:SetParent(self.view.awardActivityGrid.transform,false)
                awardActivityItems[i].transform.localScale = Vector3.one

            end
            awardActivityItems[i]:SetActive(true)
            awardActivityItems[i].transform:Find('nameBg/name'):GetComponent('TextMeshProUGUI').text = GetText(data.subtab[i].name)
            awardActivityItems[i].transform:Find('award'):GetComponent('TextMeshProUGUI').text = GetText(data.subtab[i].award)
            awardActivityItems[i].transform:Find('des'):GetComponent('TextMeshProUGUI').text = GetText(data.subtab[i].des)
        end
        for i=#data.subtab+1,#awardActivityItems do
            awardActivityItems[i]:SetActive(false)
        end
    end
    self.normalActivityPage = function(data)
        self.view.normalActivityPage:SetActive(true)
        for i=1,#data.subtab do
            if activityDesItems[i] == nil then
                activityDesItems[i] = GameObject.Instantiate(self.view.activityDesItem)
                activityDesItems[i].transform:SetParent(self.view.normalActivityGrid.transform,false)
                activityDesItems[i].transform.localScale = Vector3.one
            end
            activityDesItems[i]:SetActive(true)
            activityDesItems[i].transform:Find('name'):GetComponent('TextMeshProUGUI').text = GetText(data.subtab[i].name)
            activityDesItems[i].transform:Find('des'):GetComponent('TextMeshProUGUI').text = GetText(data.subtab[i].des)
        end
        for i=#data.subtab+1,#activityDesItems do
            activityDesItems[i]:SetActive(false)
        end
    end
    self.serialNumberPage = function(data)
        self.view.serialNumberPage:SetActive(true)
        local SendMsg = function()
            local data = {}
            data.func_name = 'on_use_gift_code'
            data.gift_pack_code = self.view.codeInput:GetComponent('TMP_InputField').text
            MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)            
        end
        self.AddClick(self.view.btnExchange,SendMsg)
    end    

    self.onLoad = function()
        self.view.tabItem:SetActive(false)
        self.view.awardItem:SetActive(false)
        self.view.awardActivityItem:SetActive(false)
        self.view.activityDesItem:SetActive(false)
         for i=1,#tableDatas do
            --if UnityEngine.Platform
            local tabItem = GameObject.Instantiate(self.view.tabItem)
            tabItem:SetActive(true)
            tabItem.transform:SetParent(self.view.tabs.transform,false)
            tabItem.transform.localScale = Vector3.one
            tabItem.transform:Find('tabText'):GetComponent('TextMeshProUGUI').text = GetText(tableDatas[i].name)
            tabItems[i] = tabItem
            self.AddClick(tabItem.transform:FindChild('bg').gameObject,function() UpdateData(tableDatas[i],tabItem) end)
         end
         UpdateData(tableDatas[1],tabItems[1])
    end
    
    self.onUnload = function()
        for _,v in pairs(tabItems) do
            GameObject.Destroy(v)
        end
        tabItems = {}
        for i=#awardItems,1 do
            GameObject.Destroy(awardItems[i])
        end
        awardItems = {}
        for i=#activityDesItems,1 do
            GameObject.Destroy(activityDesItems[i])
        end
        activityDesItems = {}
        for i=#awardActivityItems,1 do
            GameObject.Destroy(awardActivityItems[i])
        end
        awardActivityItems = {}
    end
    

    return self
end

return CreateWelfareUICtrl()



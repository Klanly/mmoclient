require "UI/Controller/LuaCtrlBase"

local function CreateGoldenFingerUICtrl()
	local self = CreateCtrlBase()
    
    local gmBtns = {
        { '+100万铜钱',{'add 1001 1000000'}},
        { '+1000金元宝',{'add 1002 1000'}},
        { '+新手套装',{'add_player_equipment'}},
        { '+10万经验',{'add 1004 100000'}},
        { '+1000体力',{'add 1003 1000'}},
        { '+100万经验',{'add 1004 1000000'}},
        { '+1000威望',{'set prestige 1000'}},
        { '+100万绑定铜钱',{'add 1012 1000000'}},
        { '1万MP',{'set mp 10000'}},
        { '1万HP',{'set hp 10000'}},
        { '+5等级',{'set addlevel 5'}},
    }
    
    local gmBtnsEx = {
        {
            text = '显示性能', 
            event = function()
                Util.SwitchAdvancedPerf()
            end
        },
        {
            text = '打印lua内存', 
            event = function()
                MemListener.printMem()
                MemListener.printRef()
            end
        },
        {
            text = '显示日志', 
            event = function()
                if LogConfig.hasFlag('msg') then
                    LogConfig.removeFlag('msg')
                    LogConfig.removeFlag('rpcmsg')
                    LogConfig.removeFlag('aoi')
                else
                    LogConfig.addFlag('msg')
                    LogConfig.addFlag('rpcmsg')
                    LogConfig.addFlag('aoi')
                end
            end
        },
        {
            text = '断线重连', 
            event = function()
                if SceneManager.IsOnFightServer() then
                    ConnectionManager.ReconnectFightServer()
                else
                    ConnectionManager.ReconnectMainServer()
                end
            end
        },
        -- {
        --     text = 'Bugly测试', 
        --     event = function()
        --         Util.TestBugly()
        --     end
        -- },
    }

    local btnItems = nil    
    local function OnBtnClick(index)
        for i=1, #gmBtns[index][2] do
            MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_GM, {command=gmBtns[index][2][i]})
        end
    end

    local function OnSendBtnClick()
        MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_GM, {command=self.view.command:GetComponent('TMP_InputField').text})
    end
    
	self.onLoad = function()
        ClickEventListener.Get(self.view.btnSend).onClick = OnSendBtnClick
        ClickEventListener.Get(self.view.closeBtn).onClick = self.close

        self.view.btnItem:SetActive(false)
        btnItems = {}
        for i=1,#gmBtns do
            local clone = GameObject.Instantiate(self.view.btnItem)
            clone:SetActive(true)
            table.insert(btnItems,clone)
            clone.transform:SetParent(self.view.grids.transform,false)
            clone.transform:Find('btn/Text'):GetComponent('TextMeshProUGUI').text = gmBtns[i][1]
            ClickEventListener.Get(clone.transform:Find('btn').gameObject).onClick = function() OnBtnClick(i) end
        end

        for k, v in pairs(gmBtnsEx) do
            local clone = GameObject.Instantiate(self.view.btnItem)
            clone:SetActive(true)
            table.insert(btnItems, clone)
            clone.transform:SetParent(self.view.grids.transform, false)
            clone.transform:Find('btn/Text'):GetComponent('TextMeshProUGUI').text = v.text
            ClickEventListener.Get(clone.transform:Find('btn').gameObject).onClick = v.event
        end
	end
    
    self.onUnload = function()
        for i=1,#btnItems do
            GameObject.Destroy(btnItems[i])
        end
        btnItems = {}
    end

	return self
end

return CreateGoldenFingerUICtrl()


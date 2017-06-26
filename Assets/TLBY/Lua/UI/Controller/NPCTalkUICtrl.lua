--huasong--
require "Common/basic/LuaObject"
local config = require "Logic/Scheme/common_npc"  
local log = require "basic/log"
local const = require "Common/constant"

local function createBtnItem(temp, text, func)
    local self = CreateScrollviewItem(temp)

    self.transform:FindChild('txtEnter'):GetComponent('TextMeshProUGUI').text = text

    local btn = self.transform:FindChild('btnEnter').gameObject
    ClickEventListener.Get(btn).onClick = func
    UIUtil.AddButtonEffect(btn, nil, nil)
    return self
end

local function CreateNPCTalkUICtrl( )
    local self = CreateCtrlBase()
    self.data = nil
    
    local btnItems = {}
    local dialogues = {}
    local endBtns = {} -- text, event
    local curDialogIndex = 1
    local onEndTalk = nil

    local EndTalk = function()
        if onEndTalk then
            onEndTalk()
            onEndTalk = nil
        end
    end

    local clearBtns = function()
        for k, v in ipairs(btnItems) do
            DestroyScrollviewItem(v.gameObject)
        end
        btnItems = {}
        self.view.btnGroup:SetActive(false)
    end

    local addBtn = function(text, func)
        local btn = createBtnItem(self.view.taskBtnTemplate, text, func)
        table.insert(btnItems, btn)
        self.view.btnGroup:SetActive(true)
    end

    local updateContent = function()
        if curDialogIndex == #dialogues and endBtns then -- 最后一页对话时, 显示button
            for _, btn in ipairs(endBtns) do
                addBtn(btn.text, function() 
                    EndTalk()
                    -- self.close()
                    btn.event() 
                end)
            end
        end
        if curDialogIndex <= #dialogues then
            local dialogue = dialogues[curDialogIndex]
            local con = string.split(dialogue, ":")
            if #con == 2 then
                local name = con[1]
                local dialogue = con[2]
                if name == MyHeroManager.heroData.actor_name then -- right 
                    self.view.leftGroup:SetActive(false)
                    self.view.rightGroup:SetActive(true)
                    self.view.txtRightName:GetComponent("TextMeshProUGUI").text = name
                    self.view.txtRightContent:GetComponent("TextMeshProUGUI").text = dialogue
                    self.view.imgRightHead:GetComponent('Image').sprite = LuaUIUtil.GetPuppetImage(MyHeroManager.heroData.entity_id)
                else                    
                    self.view.leftGroup:SetActive(true)
                    self.view.rightGroup:SetActive(false)
                    self.view.imgLeftHead:GetComponent('Image').sprite = LuaUIUtil.GetPuppetImage(self.data.npcuid)
                    self.view.txtLeftName:GetComponent("TextMeshProUGUI").text = name
                    self.view.txtLeftContent:GetComponent("TextMeshProUGUI").text = dialogue
                end
            else
                error("dialogue 格式错误")
            end
        else
            EndTalk()
            self.close()
        end
    end

    local OnCloseBtnClick = function()
        self.close()
    end
    local OnSkipBtnClick = function()
        EndTalk()
        OnCloseBtnClick()
    end
    local OnContiueClick = function()
        curDialogIndex = curDialogIndex + 1
        updateContent() 
    end 
    self.startTalk = function(_dialogue, _endBtns, _onEndTalk)     -- _endBtns为对话到最后时显示的btn   
        clearBtns()
        local diaFiliter = string.gsub(_dialogue, "self", MyHeroManager.heroData.actor_name)
        dialogues = {}
        if diaFiliter and string.len(diaFiliter) > 0 then
            dialogues = string.split(diaFiliter, "|")
        else
            error('no dialog')
        end
        endBtns = _endBtns
        onEndTalk = _onEndTalk
        curDialogIndex = 1
        updateContent()
    end

    local updateTalkData = function(data)
        self.startTalk(data.dialogue, data.btns)
    end
    self.reLoad = function(data)
        if not self.isLoaded then
            error('reload can called only when ctrl is loaded')
        end
        -- self.startTalk(data.dialogue, data.btns)
        updateTalkData(data)
    end

    self.onLoad = function(data)  
        UIManager.HideAll()

        ClickEventListener.Get(self.view.close).onClick = OnContiueClick
        ClickEventListener.Get(self.view.imgSkip).onClick = OnSkipBtnClick
        ClickEventListener.Get(self.view.imgContiue).onClick = OnContiueClick        
        self.data = data
        -- 加一个延迟, 因为btn.event里可能会有unload该view, 
        updateTalkData(data)      
    end

    self.onUnload = function() 
        onEndTalk = nil
        clearBtns()
        dialogues = {}
        btns = {}
        curDialogIndex = 1
        UIManager.ShowAll()
    end
    
    return self
end

return CreateNPCTalkUICtrl()
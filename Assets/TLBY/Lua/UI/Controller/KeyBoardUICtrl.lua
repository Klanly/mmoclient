--
-- Created by songhua
--
local texttable = require "Logic/Scheme/common_char_chinese"

local function CreateKeyBoardUICtrl()
    local self = CreateCtrlBase()
    local minCount = 0
    local inputCount = minCount
    local maxCount = 1
    local callbackHandler = nil
    local callbackData = nil

    local function OnBtnClick(i)
        inputCount = inputCount*10 + i
        if inputCount > maxCount then
            inputCount = maxCount
        end
        self.textSplitCount.text = inputCount
    end

    local function OnOKBtnClick()
        callbackHandler(inputCount)
        UIManager.UnloadView(ViewAssets.KeyBoardUI)
    end

    local function OnDeleteBtnClick()
        inputCount = math.floor(inputCount / 10)
        if inputCount <= 0 then
            inputCount = minCount
        end
        self.textSplitCount.text = inputCount
    end

    self.onLoad = function(data)
        ClickEventListener.Get(self.view.btnclose).onClick = self.close
        self.textSplitCount = self.view.textBreakupdigital:GetComponent("TextMeshProUGUI")
        for i=0,9 do
            ClickEventListener.Get(self.view["btn"..i]).onClick = function() OnBtnClick(i) end
        end
        ClickEventListener.Get(self.view.btnOK).onClick = OnOKBtnClick
        ClickEventListener.Get(self.view.btndelete).onClick = OnDeleteBtnClick
        
        self.UpdateData(data)
    end
    
    self.UpdateData = function(data)
        maxCount = data.maxCount
        inputCount = data.inputCount or 0
        self.textSplitCount.text = inputCount
        callbackHandler = data.callbackHandler
    end
        
    return self
end

return CreateKeyBoardUICtrl()


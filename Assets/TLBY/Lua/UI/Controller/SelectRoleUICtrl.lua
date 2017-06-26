require "UI/Controller/LuaCtrlBase"

local function CreateSelectRoleUICtrl()
	local self = CreateCtrlBase()
	self.selectData = nil
    
    local SelectItem = function(data)
        self.selectData = data
        for i=1,4 do
            self.view['vocation'..i].gameObject:SetActive(data.vocation == i)
        end
        local createCtrl = UIManager.GetCtrl(ViewAssets.CreateRoleUI)
        if not data.appearance then data.appearance = {} end 
        createCtrl.CreateModel(data.vocation, data.sex,data.appearance[901],data.appearance[902],data.appearance[903])
    end
    
    local UpdateItem = function(item,data)
        if data == nil then item:SetActive(false) return end
        
        item.transform:FindChild('country'):GetComponent('TextMeshProUGUI').text = LuaUIUtil.GetTextByID(systemLoginCreate.Camp[data.country],'Name')
        item.transform:FindChild('name'):GetComponent('TextMeshProUGUI').text = data.actor_name
        item.transform:FindChild('level'):GetComponent('TextMeshProUGUI').text = 'Lv.'..data.level
        for i=1,4 do
            item.transform:FindChild('vocation'..i).gameObject:SetActive(data.vocation == i)
        end
        ClickEventListener.Get(item.transform:FindChild('bg').gameObject).onClick = function() SelectItem(data) end
    end

 	local InitRoleItem = function(list)
 		for i = 1, 4 do
			local data = list[i]
            UpdateItem(self.view['item'..i],data)
            self.view['btnAdd'..i]:SetActive(data == nil)
			ClickEventListener.Get(self.view['btnAdd' .. i]).onClick = function()UIManager.LoadView(ViewAssets.CreateRoleUI,nil, self.data) end
		end
        self.view.item1.transform:FindChild('bg'):GetComponent('Toggle').isOn = true
        SelectItem(list[1])
 	end
	
	local OnBtnEnterClick = function()
		if not self.selectData then
			return
		end
        
		UnityEngine.PlayerPrefs.SetString("ActorName", self.selectData.actor_name)
		MessageManager.RequestLua(MSG.CS_MESSAGE_LOGIN_SELECT_ACTOR, {
			actor_name = self.selectData.actor_name,
			actor_id = self.selectData.actor_id
		})
	end
	
	local OnBtnBackClick = function()	
        SceneManager.EnterScene('ReLogin', function() UIManager.PushView(ViewAssets.LoginPanelUI) end)  
	end

	local onLogin = function(data)
		if data.result ~= 0 then
			UIManager.ShowErrorMessage(data.result)
			return
		end
		MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_LOGIN)
	end

	local onDeleRole = function(data)
		self.data = data

		if data.result ~= 0 then
			UIManager.ShowErrorMessage(data.result)
			return
		end		
		if #data.actor_list <= 0 then			--进入创建角色界面		
			UIManager.LoadView(ViewAssets.CreateRoleUI,nil, data)
		else
			InitRoleItem(data.actor_list)
		end
	end
	
	-- 当view被加载时事件
	self.onLoad = function(data)
		self.data = data

		ClickEventListener.Get(self.view.btnEnter).onClick = OnBtnEnterClick
		ClickEventListener.Get(self.view.btnBack).onClick = OnBtnBackClick
		
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LOGIN_SELECT_ACTOR, onLogin)
		MessageManager.RegisterMessage(MSG.SC_MESSAGE_LOGIN_DELETE_ACTOR, onDeleRole)
        DragEventListener.Get(self.view.btnShowAction).onDrag = nil
        self.AddClick(self.view.btnShowAction,self.ShowAction)
		InitRoleItem(data.actor_list)
	end
	
	-- 当view被卸载时事件
	self.onUnload = function ()
		MessageManager.UnregisterMessage(MSG.SC_MESSAGE_LOGIN_SELECT_ACTOR, onLogin)
		MessageManager.UnregisterMessage(MSG.SC_MESSAGE_LOGIN_DELETE_ACTOR, onDeleRole)
        local createCtrl = UIManager.GetCtrl(ViewAssets.CreateRoleUI)
	 	createCtrl.DeleteModel()
	end
    
    self.ShowAction = function(event)
        local createCtrl = UIManager.GetCtrl(ViewAssets.CreateRoleUI)
	 	createCtrl.ShowAction(event)
    end

	return self
end

return CreateSelectRoleUICtrl()

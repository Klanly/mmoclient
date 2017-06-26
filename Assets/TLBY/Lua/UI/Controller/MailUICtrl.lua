require "UI/Controller/LuaCtrlBase"
local system_friends_chat = require "Logic/Scheme/system_friends_chat"

local function CreateMailUICtrl()
	local self = CreateCtrlBase()
    
    local mailList = {}
    local attachItems = {}
    local selectMailIndex = 1
    
    
    local UpdateAttachItem = function(item,data)
        local quality = item.transform:Find('bg'):GetComponent('Image')
        quality.overrideSprite = LuaUIUtil.GetItemQuality(data.item_id)
        local icon = item.transform:Find('bg/icon'):GetComponent('Image')
        icon.overrideSprite = LuaUIUtil.GetItemIcon(data.item_id)
        item.transform:Find('bg/count'):GetComponent('TextMeshProUGUI').text = data.count
        local data1 = mailList[selectMailIndex]
        item.transform:Find('bg/got').gameObject:SetActive(data1.extract)
        if data1.extract then
            quality.material = UIGrayMaterial.GetUIGrayMaterial()
            icon.material = UIGrayMaterial.GetUIGrayMaterial()
        else
            quality.material = nil
            icon.material = nil
        end
        ClickEventListener.Remove(item.transform:Find('bg/icon').gameObject)
        ClickEventListener.Get(item.transform:Find('bg/icon').gameObject).onClick = function()
            BagManager.ShowItemTips({item_data={id=data.item_id}},true)
        end
    end
    
    local BindData = function(item,index)
        local data = mailList[index+1]
        local mail_config = system_friends_chat.Mail[data.system_mail_id]
        if mail_config == nil then
            return
        end
        local bgNormalUnread = item.transform:Find('bgNormalUnread').gameObject
        bgNormalUnread:SetActive(not data.read and selectMailIndex ~= index+1)
        local bgLight = item.transform:Find('bgLight').gameObject
        bgLight:SetActive(selectMailIndex == index+1)
        local bgNormalRead = item.transform:Find('bgNormalRead').gameObject
        bgNormalRead:SetActive(data.read and selectMailIndex ~= index+1)
        item.transform:Find('read').gameObject:SetActive(data.read)
        item.transform:Find('unread').gameObject:SetActive(not data.read)
        item.transform:Find('attach').gameObject:SetActive(#data.attachment > 0 and not data.extract)
        local timeLight = item.transform:Find('timeLight'):GetComponent('TextMeshProUGUI')
        local timeDark = item.transform:Find('timeDark'):GetComponent('TextMeshProUGUI')
        local titleLight = item.transform:Find('titleLight'):GetComponent('TextMeshProUGUI')
        local titleDark = item.transform:Find('titleDark'):GetComponent('TextMeshProUGUI')
        timeLight.gameObject:SetActive(not data.read)
        timeDark.gameObject:SetActive(data.read)
        titleLight.gameObject:SetActive(not data.read)
        titleDark.gameObject:SetActive(data.read)
        if data.read then
            item.transform:Find('bgMailbox'):GetComponent('Image').material = UIGrayMaterial.GetUIGrayMaterial()
            item.transform:Find('attach'):GetComponent('Image').material = UIGrayMaterial.GetUIGrayMaterial()
        else
            item.transform:Find('bgMailbox'):GetComponent('Image').material = nil
            item.transform:Find('attach'):GetComponent('Image').material = nil
        end
        titleLight.text = LuaUIUtil.GetTextByID(mail_config,"MailName")
        titleDark.text = LuaUIUtil.GetTextByID(mail_config,"MailName")
        timeLight.text = string.format('%d月%d日',os.date("%m",data.send_time),os.date("%d",data.send_time))
        timeDark.text = string.format('%d月%d日',os.date("%m",data.send_time),os.date("%d",data.send_time))
        
        self.AddClick(bgNormalRead,function() self.SelectMail(index+1) end)
        self.AddClick(bgNormalUnread,function() self.SelectMail(index+1) end)
    end
    
    self.OpenUI = function()
        MessageRPCManager.AddUser(self, 'GetMailsInfoReply')
        local data = {}
        data.func_name = 'on_get_mails_info'
        MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
    end

    self.GetMailsInfoReply = function(data)
        if self.isLoaded then
            self.FreshUI(data.mails)
        else
            UIManager.PushView(ViewAssets.MailUI,nil,data.mails)
        end
    end
    
	self.onLoad = function(data)
        self.view.mailRed:SetActive(false)
        selectMailIndex = 1
        self.FreshUI(data)
        
        self.AddClick(self.view.btnGetSelect,self.GetSelect)
        self.AddClick(self.view.btnGetAll,self.GetAll)
        self.AddClick(self.view.btnDelectAll,self.DelectAllNotice)
        self.AddClick(self.view.btnDeleteSelect,self.DeleteSelect)
        self.AddClick(self.view.btnClose,self.close)
        self.AddClick(self.view.btnFriend,self.OpenFriendPanel)
        MessageRPCManager.AddUser(self, 'DeleteMailReply')
        MessageRPCManager.AddUser(self, 'ClearMailsReply')
        MessageRPCManager.AddUser(self, 'GetMailAttachmentReply')
        MessageRPCManager.AddUser(self, 'GetAllMailsAttachmentReply')
	end
	
	self.onUnload = function()
        for i=#attachItems,1,-1 do
            UnityEngine.GameObject.Destroy(attachItems[i])
            table.remove(attachItems,i)
        end
        MessageRPCManager.RemoveUser(self, 'DeleteMailReply')
        MessageRPCManager.RemoveUser(self, 'ClearMailsReply')
        MessageRPCManager.RemoveUser(self, 'GetMailAttachmentReply')
        MessageRPCManager.RemoveUser(self, 'GetAllMailsAttachmentReply')
        MessageRPCManager.RemoveUser(self, 'GetMailsInfoReply')
	end
    
    local SortMail = function(a,b)
        if a.read ~= b.read then
            return b.read
        end
        return a.send_time>b.send_time
    end
    
    self.FreshUI = function(data)
        mailList = data
        table.sort(mailList,SortMail)
        self.view.pageLeft:SetActive(#mailList>0)
        self.view.pageRight:SetActive(#mailList>0)
        self.view.empty:SetActive(#mailList == 0)
        self.view.scrollView:GetComponent('UIMultiScroller'):Init(self.view.mailItem,664,109,0,7,1)
        if #mailList > 0 then
            self.SelectMail(selectMailIndex)
        end
    end
    
    self.DeleteMailReply = function(data)
        if data.result == 0 then
            self.FreshUI(data.mails)
        end
    end
    self.ClearMailsReply = function(data)
        if data.result == 0 then
            self.FreshUI(data.mails)
            UIManager.ShowNotice('邮箱清理成功')
        end
    end
    self.GetMailAttachmentReply = function(data)
        if data.result == 0 then
            self.FreshUI(data.mails)
        end
    end
    self.GetAllMailsAttachmentReply = function(data)
        if data.result == 0 then
            self.FreshUI(data.mails)
            UIManager.ShowNotice('成功领取邮件附件')
        end
    end
	
    self.OpenFriendPanel = function()
        ContactManager.PushView(ViewAssets.FriendsUI)
        self.close()
    end
    
    self.SendReadMsg = function(mailData)
        mailData.read = true
        local data = {}
        data.func_name = 'on_read_mail'
        data.mail_id = mailData.mail_id
        MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
    end

    local function AttachItemClickHandle()
    end
    
    self.SelectMail = function(index)
        if index > #mailList then
            selectMailIndex = 1
        else
            selectMailIndex = index
        end
        
        local data = mailList[selectMailIndex]
        if not data.read then
            self.SendReadMsg(data)
        end
        local mail_config = system_friends_chat.Mail[data.system_mail_id]
        if mail_config == nil then
            return
        end

        self.view.textMailCount:GetComponent('TextMeshProUGUI').text = string.format('当前邮件：%d/%d',#mailList,50)
        self.view.scrollView:GetComponent('UIMultiScroller'):UpdateData(#mailList,BindData) 
        self.view.mailTitle:GetComponent('TextMeshProUGUI').text = LuaUIUtil.GetTextByID(mail_config,"MailName")
        self.view.mailContent:GetComponent('TextMeshProUGUI').text = string.format(LuaUIUtil.GetTextByID(mail_config,"TextContent"),unpack(data.params))
        self.view.textSender:GetComponent('TextMeshProUGUI').text = '发送人:'..LuaUIUtil.GetTextByID(mail_config,"MailName")
        self.view.textDate:GetComponent('TextMeshProUGUI').text = string.format('%d年%d月%d日',os.date("%Y",data.send_time),os.date("%m",data.send_time),os.date("%d",data.send_time))
        self.view.attachItem:SetActive(false)
        for i=1,#data.attachment do
            if attachItems[i] == nil then
                attachItems[i] = GameObject.Instantiate(self.view.attachItem)
                attachItems[i].transform:SetParent(self.view.attachs.transform,false)
            end
            attachItems[i]:SetActive(true)
            UpdateAttachItem(attachItems[i],data.attachment[i])
        end
        for i=#data.attachment + 1,#attachItems do
            attachItems[i]:SetActive(false)
        end
        local contentHeight = self.view.mailContent:GetComponent('TextMeshProUGUI').preferredHeight + 210
        self.view.contentLayout:GetComponent('LayoutElement').flexibleHeight = contentHeight
        local attachHeight = 133*math.ceil(#data.attachment/6) + 87
        self.view.attachLayout:GetComponent('LayoutElement').minHeight = attachHeight
        self.view.scrollViewContent:GetComponent('RectTransform').sizeDelta = Vector2.New(100,math.max(contentHeight + attachHeight,680))
        self.view.attachLayout:SetActive(#data.attachment > 0)
        local unReadCount = self.GetUnreadMailCount()
        --self.view.unredMailCount:GetComponent('TextMeshProUGUI').text = unReadCount
        ChatManager.RefreshUnreadMailRedDot(unReadCount > 0)
        UIManager.GetCtrl(ViewAssets.MainLandUI).UpdateRedDot()
    end
    
    self.GetSelect = function()
        if #mailList == 0 then
            UIManager.ShowNotice('没有邮件')
            return
        end
        if #(mailList[selectMailIndex].attachment) == 0 then
            UIManager.ShowNotice('该邮件没有附件')
            return
        end
        if mailList[selectMailIndex].extract then
            UIManager.ShowNotice('该邮件附件已领取')
            return
        end
        local data = {}
        data.func_name = 'on_get_mail_attachment'
        data.mail_id = mailList[selectMailIndex].mail_id
        MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
    end
    self.GetAll = function()
        if #mailList == 0 then
            UIManager.ShowNotice('没有邮件')
            return
        end
        local attachCount = 0
        for k,v in pairs(mailList) do
            if #v.attachment > 0 and not v.extract then
                attachCount = attachCount+1
            end
        end
        if attachCount == 0 then
            --UIManager.ShowNotice('暂无可领取的附件')
            return 
        end
        local data = {}
        data.func_name = 'on_get_all_mails_attachments'
        MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
    end
    
    self.DelectAllNotice = function()
        if #mailList == 0 then
            UIManager.ShowNotice('没有邮件')
            return
        end
        UIManager.ShowDialog('<size=120%>是否确定一键清空已读邮件</size>\n<color=#5B040DFF>(未领取附件的邮件也会清空，请注意提取)</color>', '确定', '取消', self.DelectAll, nil)
    end
    
    self.DelectAll = function()
        local data = {}
        data.func_name = 'on_clear_mails'
        MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
    end
    self.DeleteSelect = function()
        if #mailList == 0 then
            UIManager.ShowNotice('没有邮件')
            return
        end
        local SendDelect = function(id)
            local data = {}
            data.func_name = 'on_delete_mail'
            data.mail_id = id
            MessageManager.RequestLua(constant.CS_MESSAGE_LUA_GAME_RPC, data)
        end
        local mailData = mailList[selectMailIndex]
        if #mailData.attachment > 0 and not mailData.extract then
            UIManager.ShowDialog('该邮件有附件未领取，是否删除？', '确定', '取消', function()SendDelect(mailData.mail_id) end, nil)
        else
            SendDelect(mailData.mail_id)
        end

    end
    
    self.GetUnreadMailCount = function()
        local count = 0
        for i=1,#mailList do
            if not mailList[i].read then
                count = count + 1
            end
        end       
        return count
    end
    
	return self
end

return CreateMailUICtrl()

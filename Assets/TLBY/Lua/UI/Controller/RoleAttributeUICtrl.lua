--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2016/10/9 0009
-- Time: 16:56
-- To change this template use File | Settings | File Templates.
--

require "UI/Controller/LuaCtrlBase"
local const = require "Common/constant"
local parameTable = require "Logic/Scheme/common_parameter_formula"

local texttable = require "Logic/Scheme/common_char_chinese"
local leveltable = require "Logic/Scheme/common_levels"
local PROPERTY_NAME_TO_INDEX = const.PROPERTY_NAME_TO_INDEX

local levelconfigs = leveltable.Level
local attributeTable = {
        {['value']=PROPERTY_NAME_TO_INDEX.physic_attack,['name']= 1114001,},
		{['value']=PROPERTY_NAME_TO_INDEX.physic_defence,['name']= 1114003,},
        {['value']=PROPERTY_NAME_TO_INDEX.magic_attack,['name']= 1114002,},
        {['value']=PROPERTY_NAME_TO_INDEX.magic_defence,['name']= 1114004,},
		{['value']=PROPERTY_NAME_TO_INDEX.hit,['name']= 1114005,},
        {['value']=PROPERTY_NAME_TO_INDEX.miss,['name']= 1114006,},
		{['value']=PROPERTY_NAME_TO_INDEX.crit,['name']= 1114007,},
        {['value']=PROPERTY_NAME_TO_INDEX.resist_crit,['name']= 1114008,},
        {['value']=PROPERTY_NAME_TO_INDEX.break_up,['name']= 1114010,},
		{['value']=PROPERTY_NAME_TO_INDEX.block,['name']= 1114009,},
		{['value']=PROPERTY_NAME_TO_INDEX.puncture,['name']= 1114011,},
		{['value']=PROPERTY_NAME_TO_INDEX.guardian,['name']= 1114012,},
        {['value']=PROPERTY_NAME_TO_INDEX.gold_attack,['name']= 1114013,},
        {['value']=PROPERTY_NAME_TO_INDEX.gold_defence,['name']= 1114021,},
        {['value']=PROPERTY_NAME_TO_INDEX.wood_attack,['name']= 1114014,},
        {['value']=PROPERTY_NAME_TO_INDEX.wood_defence,['name']= 1114022,},
        {['value']=PROPERTY_NAME_TO_INDEX.water_attack,['name']= 1114015,},
        {['value']=PROPERTY_NAME_TO_INDEX.water_defence,['name']= 1114023,},
        {['value']=PROPERTY_NAME_TO_INDEX.fire_attack,['name']= 1114016,},
        {['value']=PROPERTY_NAME_TO_INDEX.fire_defence,['name']= 1114024,},
        {['value']=PROPERTY_NAME_TO_INDEX.soil_attack,['name']= 1114017,},
        {['value']=PROPERTY_NAME_TO_INDEX.soil_defence,['name']= 1114025,},
        {['value']=PROPERTY_NAME_TO_INDEX.wind_attack,['name']= 1114018,},
        {['value']=PROPERTY_NAME_TO_INDEX.wind_defence,['name']= 1114026,},
        {['value']=PROPERTY_NAME_TO_INDEX.light_attack,['name']= 1114019,},
        {['value']=PROPERTY_NAME_TO_INDEX.light_defence,['name']= 1114027,},
        {['value']=PROPERTY_NAME_TO_INDEX.dark_attack,['name']= 1114020,},
        {['value']=PROPERTY_NAME_TO_INDEX.dark_defence,['name']= 1114028,},
}
local attributeItems = {}

local function CreateRoleAttributeUICtrl()
    local self = CreateCtrlBase()
    local exp_max_legthen = 500

    local function OnChangeTitleBtnClick()
    end
    
    local function OnLevelupClick()
        MessageManager.RequestLua(MSG.CS_MESSAGE_LUA_LEVEL_UP, {})
    end
    local function OnLevelUp(data)
        if data.result ~= 0 then
            UIManager.ShowErrorMessage(data.result)
        else
            --self.view.eff_level:SetActive(false)
            --self.view.eff_level:SetActive(true)
            if SceneManager.GetEntityManager().hero then
                SceneManager.GetEntityManager().hero.OnLevelUp()
            end
        end
    end
    local function OnUpdateData(data)
        self.UpdateAttribute()
    end

    self.onLoad = function()
        ClickEventListener.Get(self.view.btnchange).onClick = OnChangeTitleBtnClick

        --self.view.eff_level:SetActive(false)
        MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_LEVEL_UP, OnLevelUp)
        MessageManager.RegisterMessage(MSG.SC_MESSAGE_LUA_UPDATE, OnUpdateData)
        self.view.attributeItem:SetActive(true)
        for k,v in pairs(attributeTable) do
            attributeItems[v.value] = GameObject.Instantiate(self.view.attributeItem)
            attributeItems[v.value].transform:SetParent(self.view.Content.transform,false)
        end
        self.view.attributeItem:SetActive(false)
    end

    self.onUnload = function()
        MessageManager.UnregisterMessage(MSG.SC_MESSAGE_LUA_LEVEL_UP, OnLevelUp)
        MessageManager.UnregisterMessage(MSG.SC_MESSAGE_LUA_UPDATE, OnUpdateData)
        for k,v in pairs(attributeItems) do
            GameObject.Destroy(v)
        end
        attributeItems = {}
    end

    self.onActive = function()
        self.UpdateAttribute()
        self.UpdateInformation()
    end

    self.UpdateAttribute = function()
        local level_config = levelconfigs[MyHeroManager.heroData.level]
        if level_config then
            self.view.textexperiencedigital:GetComponent('TextMeshProUGUI').text = MyHeroManager.heroData.exp.."<size=65%>/"..level_config.Exp
            local amount = MyHeroManager.heroData.exp / level_config.Exp
            self.view.expBar:GetComponent('Slider').value = amount
            local autoLevel = parameTable.Parameter[23].Parameter
            -------- 到60后需要手动升级 -----------------------
            if MyHeroManager.heroData.level >= autoLevel and
                MyHeroManager.heroData.exp >= level_config.Exp then
                self.view.levelup:GetComponent('Image').material = nil
                ClickEventListener.Get(self.view.levelup).onClick = OnLevelupClick
            else
                self.view.levelup:GetComponent('Image').material = UIGrayMaterial.GetUIGrayMaterial()
                ClickEventListener.Get(self.view.levelup).onClick = nil
            end
        end

        --血量
        local hpRadio = SceneManager.GetEntityManager().hero.hp / SceneManager.GetEntityManager().hero.hp_max()
        if hpRadio > 1 then
            hpRadio = 1
        end
        self.view.hpBar:GetComponent('Slider').value = hpRadio
        self.view.textHpdigital:GetComponent('TextMeshProUGUI').text = SceneManager.GetEntityManager().hero.hp.."<size=65%>/".. SceneManager.GetEntityManager().hero.hp_max()
        --内力
         local mpRadio = SceneManager.GetEntityManager().hero.mp / SceneManager.GetEntityManager().hero.mp_max()
         if mpRadio > 1 then
             mpRadio = 1
         elseif SceneManager.GetEntityManager().hero.mp_max() == 0 then
            mpRadio = 0
         end
        self.view.mpBar:GetComponent('Slider').value = mpRadio
        self.view.textpowerdigital:GetComponent('TextMeshProUGUI').text = SceneManager.GetEntityManager().hero.mp.."<size=65%>/"..SceneManager.GetEntityManager().hero.mp_max()

        --self.textSpiritual.text = MyHeroManager.heroData.property[PROPERTY_NAME_TO_INDEX.spritual]
        for k,v in pairs(attributeTable) do
            attributeItems[v.value].transform:Find('name'):GetComponent('TextMeshProUGUI').text = texttable.UIText[v.name].NR
            attributeItems[v.value].transform:Find('value'):GetComponent('TextMeshProUGUI').text = MyHeroManager.heroData.property[v.value]
        end
    end
    
    self.UpdateInformation = function()
        self.view.textLevel:GetComponent('TextMeshProUGUI').text = MyHeroManager.heroData.level
        self.view.textVocation:GetComponent('TextMeshProUGUI').text = VocationConst.GetVocationNameByType(MyHeroManager.heroData.vocation)
        local peerageName = texttable.UIText[1101041].NR
        if MyHeroManager.heroData.noble_rank ~= nil and MyHeroManager.heroData.noble_rank ~= -1 then
            local titleData =  pvpCamp.NobleRank[MyHeroManager.heroData.noble_rank]
            if titleData ~= nil then
                if titleData.Name > 0 then
                    peerageName = texttable.TableText[titleData.Name].NR  --当前爵位
                else
                    peerageName = titleData.Name1  --当前爵位
                end
            end
        end
        self.view.textPeerage:GetComponent('TextMeshProUGUI').text = peerageName
        self.view.textFaction:GetComponent('TextMeshProUGUI').text = texttable.UIText[1101037].NR
        self.view.textMate:GetComponent('TextMeshProUGUI').text = texttable.UIText[1101037].NR
        self.view.textCamp:GetComponent('TextMeshProUGUI').text = LuaUIUtil.GetTextByID(systemLoginCreate.Camp[MyHeroManager.heroData.country],'Name')
        self.view.textTitle:GetComponent('TextMeshProUGUI').text = texttable.UIText[1101037].NR
    end
    
    return self
end

return CreateRoleAttributeUICtrl()


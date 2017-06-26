--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2016/9/28 0028
-- Time: 17:58
-- To change this template use File | Settings | File Templates.
--
require "Common/basic/LuaObject"
local txtTable = require "Logic/Scheme/common_char_chinese"
local const = require "Common/constant"

local PROPERTY_NAME_TO_INDEX = const.PROPERTY_NAME_TO_INDEX

local function CreateAttributeConst()
    local self = CreateObject()

    --获得属性对应名字,参数字符串physic_attack
    self.GetAttributeNameByIndex = function(data)
        if data == PROPERTY_NAME_TO_INDEX.physic_attack then
            return txtTable.UIText[1114001].NR
        elseif data == PROPERTY_NAME_TO_INDEX.magic_attack then
            return txtTable.UIText[1114002].NR
        elseif data == PROPERTY_NAME_TO_INDEX.physic_defence then
            return txtTable.UIText[1114003].NR
        elseif data == PROPERTY_NAME_TO_INDEX.magic_defence then
            return txtTable.UIText[1114004].NR
        elseif data == PROPERTY_NAME_TO_INDEX.hp_max then
            return txtTable.UIText[1114029].NR
        elseif data == PROPERTY_NAME_TO_INDEX.miss then
            return txtTable.UIText[1114006].NR
        elseif data == PROPERTY_NAME_TO_INDEX.hit then
            return txtTable.UIText[1114005].NR
        elseif data == PROPERTY_NAME_TO_INDEX.crit then
            return txtTable.UIText[1114007].NR
        elseif data == PROPERTY_NAME_TO_INDEX.resist_crit then
            return txtTable.UIText[1114008].NR
        elseif data == PROPERTY_NAME_TO_INDEX.block then
            return txtTable.UIText[1114009].NR
        elseif data == PROPERTY_NAME_TO_INDEX.break_up then
            return txtTable.UIText[1114010].NR
        elseif data == PROPERTY_NAME_TO_INDEX.puncture then
            return txtTable.UIText[1114011].NR
        elseif data == PROPERTY_NAME_TO_INDEX.guardian then
            return txtTable.UIText[1114012].NR
        elseif data == PROPERTY_NAME_TO_INDEX.gold_attack then
            return txtTable.UIText[1114013].NR
        elseif data == PROPERTY_NAME_TO_INDEX.wood_attack then
            return txtTable.UIText[1114014].NR
        elseif data == PROPERTY_NAME_TO_INDEX.water_attack then
            return txtTable.UIText[1114015].NR
        elseif data == PROPERTY_NAME_TO_INDEX.fire_attack then
            return txtTable.UIText[1114016].NR
        elseif data == PROPERTY_NAME_TO_INDEX.soil_attack then
            return txtTable.UIText[1114017].NR
        elseif data == PROPERTY_NAME_TO_INDEX.wind_attack then
            return txtTable.UIText[1114018].NR
        elseif data == PROPERTY_NAME_TO_INDEX.light_attack then
            return txtTable.UIText[1114019].NR
        elseif data == PROPERTY_NAME_TO_INDEX.dark_attack then
            return txtTable.UIText[1114020].NR
        elseif data == PROPERTY_NAME_TO_INDEX.gold_defence then
            return txtTable.UIText[1114021].NR
        elseif data == PROPERTY_NAME_TO_INDEX.wood_defence then
            return txtTable.UIText[1114022].NR
        elseif data == PROPERTY_NAME_TO_INDEX.water_defence then
            return txtTable.UIText[1114023].NR
        elseif data == PROPERTY_NAME_TO_INDEX.fire_defence then
            return txtTable.UIText[1114024].NR
        elseif data == PROPERTY_NAME_TO_INDEX.soil_defence then
            return txtTable.UIText[1114025].NR
        elseif data == PROPERTY_NAME_TO_INDEX.wind_defence then
            return txtTable.UIText[1114026].NR
        elseif data == PROPERTY_NAME_TO_INDEX.light_defence then
            return txtTable.UIText[1114027].NR
        elseif data == PROPERTY_NAME_TO_INDEX.dark_defence then
            return txtTable.UIText[1114028].NR
        elseif data == PROPERTY_NAME_TO_INDEX.fly_power then
            return txtTable.UIText[1114094].NR
        elseif data == PROPERTY_NAME_TO_INDEX.spritual then
            return txtTable.UIText[1114095].NR
        elseif data == PROPERTY_NAME_TO_INDEX.mp_max then
            return txtTable.UIText[1114096].NR
        elseif data == PROPERTY_NAME_TO_INDEX.crit_ratio then
            return txtTable.UIText[1114097].NR
        elseif data == PROPERTY_NAME_TO_INDEX.resist_petrified then
            return txtTable.UIText[1114098].NR
        elseif data == PROPERTY_NAME_TO_INDEX.ignore_resist_petrified then
            return txtTable.UIText[1114099].NR
        elseif data == PROPERTY_NAME_TO_INDEX.resist_stun then
            return txtTable.UIText[1114100].NR
        elseif data == PROPERTY_NAME_TO_INDEX.ignore_resist_stun then
            return txtTable.UIText[1114101].NR
        elseif data == PROPERTY_NAME_TO_INDEX.resist_charm then
            return txtTable.UIText[1114102].NR
        elseif data == PROPERTY_NAME_TO_INDEX.ignore_resist_charm then
            return txtTable.UIText[1114103].NR
        elseif data == PROPERTY_NAME_TO_INDEX.resist_fear then
            return txtTable.UIText[1114104].NR
        elseif data == PROPERTY_NAME_TO_INDEX.ignore_resist_fear then
            return txtTable.UIText[1114105].NR
        end
        return ""
    end

    --获得属性对应名字,参数字符串physic_attack
    self.GetElementAttributeNameByIndex = function(data)
        if data == PROPERTY_NAME_TO_INDEX.gold_attack or data == PROPERTY_NAME_TO_INDEX.gold_defence then
            return txtTable.UIText[1114086].NR
        elseif data == PROPERTY_NAME_TO_INDEX.wood_attack or data == PROPERTY_NAME_TO_INDEX.wood_defence then
            return txtTable.UIText[1114087].NR
        elseif data == PROPERTY_NAME_TO_INDEX.water_attack or data == PROPERTY_NAME_TO_INDEX.water_defence then
            return txtTable.UIText[1114088].NR
        elseif data == PROPERTY_NAME_TO_INDEX.fire_attack or data == PROPERTY_NAME_TO_INDEX.fire_defence then
            return txtTable.UIText[1114089].NR
        elseif data == PROPERTY_NAME_TO_INDEX.soil_attack or data == PROPERTY_NAME_TO_INDEX.soil_defence then
            return txtTable.UIText[1114090].NR
        elseif data == PROPERTY_NAME_TO_INDEX.wind_attack or data == PROPERTY_NAME_TO_INDEX.wind_defence then
            return txtTable.UIText[1114091].NR
        elseif data == PROPERTY_NAME_TO_INDEX.light_attack or data == PROPERTY_NAME_TO_INDEX.light_defence then
            return txtTable.UIText[1114092].NR
        elseif data == PROPERTY_NAME_TO_INDEX.dark_attack or data == PROPERTY_NAME_TO_INDEX.dark_defence then
            return txtTable.UIText[1114093].NR
        end
        return ""
    end

    self.IsElementAttribute = function(prop)
        return prop >= const.PROPERTY_NAME_TO_INDEX.gold_attack and prop <= const.PROPERTY_NAME_TO_INDEX.dark_defence
    end

    self.BasePropSort = function(a,b)
        if self.IsElementAttribute(a.prop) then
            return true
        elseif self.IsElementAttribute(b.prop) then
            return false
        elseif a.prop > b.prop then
            return true
        end
        return false
    end

    return self
end

AttributeConst = AttributeConst or CreateAttributeConst()


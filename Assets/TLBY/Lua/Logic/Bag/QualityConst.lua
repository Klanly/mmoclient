--
-- Created by IntelliJ IDEA.
-- User: Administrator
-- Date: 2016/10/8 0008
-- Time: 16:07
-- To change this template use File | Settings | File Templates.
--

require "Common/basic/LuaObject"

QUALITY = {
    QUALITY_WHITE = 1,
    QUALITY_GREEN = 2,
    QUALITY_BLUE = 3,
    QUALITY_PURPLE = 4,
    QUALITY_GOLDEN = 5,
    QUALITY_RED = 6,
}

local function CreateQualityConst()
    local self = CreateObject()
    --方形品质框
    self.GetSquareQualityIconPath = function(quality)
        if quality == QUALITY.QUALITY_WHITE then
            return "ItemQuality/white"
        elseif quality == QUALITY.QUALITY_GREEN then
            return "ItemQuality/green"
        elseif quality == QUALITY.QUALITY_BLUE then
            return "ItemQuality/blue"
        elseif quality == QUALITY.QUALITY_PURPLE then
            return "ItemQuality/purple"
        elseif quality == QUALITY.QUALITY_GOLDEN then
            return "ItemQuality/golden"
        elseif quality == QUALITY.QUALITY_RED then
            return "ItemQuality/red"
        end
        return "ItemQuality/white"
    end

    self.GetQualityColor = function(quality)
        if quality == QUALITY.QUALITY_WHITE then
            return Color.New(238/255,238/255,245/255)
        elseif quality == QUALITY.QUALITY_GREEN then
            return Color.New(151/255,202/255,90/255)
        elseif quality == QUALITY.QUALITY_BLUE then
            return Color.New(87/255,188/255,199/255)
        elseif quality == QUALITY.QUALITY_PURPLE then
            return Color.New(157/255,116/255,236/255)
        elseif quality == QUALITY.QUALITY_GOLDEN then
            return Color.New(223/255,217/255,121/255)
        elseif quality == QUALITY.QUALITY_RED then
            return Color.New(249/255,94/255,94/255)
        end
        return Color.New(238/255,238/255,245/255)
    end

    self.GetQualityColor2 = function(quality)
        if quality == QUALITY.QUALITY_WHITE then
            return Color.New(255/255,255/255,255/255)
        elseif quality == QUALITY.QUALITY_GREEN then
            return Color.New(24/255,137/255,64/255)
        elseif quality == QUALITY.QUALITY_BLUE then
            return Color.New(18/255,109/255,180/255)
        elseif quality == QUALITY.QUALITY_PURPLE then
            return Color.New(198/255,23/255,134/255)
        elseif quality == QUALITY.QUALITY_GOLDEN then
            return Color.New(202/255,101/255,27/255)
        elseif quality == QUALITY.QUALITY_RED then
            return Color.New(249/255,94/255,94/255)
        end
        return Color.New(238/255,238/255,245/255)
    end

    self.GetQualityColor2String = function(quality)
        if quality == QUALITY.QUALITY_WHITE then
            return "#ffffff"
        elseif quality == QUALITY.QUALITY_GREEN then
            return "#188940"
        elseif quality == QUALITY.QUALITY_BLUE then
            return "#126DB4"
        elseif quality == QUALITY.QUALITY_PURPLE then
            return "#C61786"
        elseif quality == QUALITY.QUALITY_GOLDEN then
            return "#CA651B"
        elseif quality == QUALITY.QUALITY_RED then
            return "#F95E5E"
        end
        return "#ffffff"
    end

    self.GetDarkOutlineColor = function()
        return Color.New(40/255,38/255,35/255)
    end

    return self
end

QualityConst = QualityConst or CreateQualityConst()







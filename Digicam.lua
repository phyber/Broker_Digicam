Broker_Digicam = LibStub("AceAddon-3.0"):NewAddon("Broker_Digicam")
local self, Broker_Digicam = Broker_Digicam, Broker_Digicam
local LDB = LibStub:GetLibrary("LibDataBroker-1.1")
local LQT = LibStub("LibQTip-1.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Broker_Digicam")
local dataobj = LDB:NewDataObject("Broker_Digicam", {
	type = "data source",
	text = "Digicam",
	icon = "Interface\\Icons\\INV_Misc_Spyglass_03",
})
local string_upper = string.upper
local string_format = string.format
local tonumber = tonumber
local GetAddOnMetadata = GetAddOnMetadata

function Broker_Digicam:SetFormat(ssFormat)
	-- Possible formats: tga, jpeg, png
	-- PNG is currently Mac only.
	-- Cycle order: tga -> jpeg -> png
	local newFormat
	
	if ssFormat == "tga" then
		newFormat = "jpeg"
	end

	if ssFormat == "jpeg" then
		if IsMacClient() then
			newFormat = "png"
		else
			newFormat = "tga"
		end
	end

	if ssFormat == "png" then
		newFormat = "tga"
	end

	if newFormat then
		SetCVar("screenshotFormat", newFormat)
	end 
	Broker_Digicam:DrawTooltip()
end

function Broker_Digicam:SetQuality(ssQuality)
	ssQuality = tonumber(ssQuality)
	-- Holt down Alt key to decrease quality
	if IsAltKeyDown() then
		if ssQuality > 0 then
			ssQuality = ssQuality - 1
			SetCVar("screenshotQuality", ssQuality)
		end
	else -- Increase quality
		if ssQuality < 10 then
			ssQuality = ssQuality + 1
			SetCVar("screenshotQuality", ssQuality)
		end
	end
	Broker_Digicam:DrawTooltip()
end

local tooltip
function Broker_Digicam:HideTooltip()
	if MouseIsOver(tooltip) then
		return
	end
	tooltip:Hide()
end

local function ColourText(text, c)
	return string_format("|cff%2x%2x%2x%s|r", c.r * 255, c.g * 255, c.b * 255, text)
end

function Broker_Digicam:DrawTooltip()
	tooltip:Hide()
	tooltip:Clear()
	local linenum
	local ssFormat = GetCVar("screenshotFormat")
	local ssQuality = GetCVar("screenshotQuality")
	local NFC = NORMAL_FONT_COLOR
	-- Header
	tooltip:AddLine(ColourText(GetAddOnMetadata("Broker_Digicam", "Title"), NFC))
	tooltip:AddLine(" ", " ")

	-- Image Format
	linenum = tooltip:AddLine(nil)
	tooltip:SetCell(linenum, 1, ColourText(L["Image Format"], NFC))
	tooltip:SetCell(linenum, 2, string_upper(ssFormat))
	tooltip:SetLineScript(linenum, "OnMouseUp", Broker_Digicam.SetFormat, ssFormat)

	-- Image Quality
	linenum = tooltip:AddLine(nil)
	tooltip:SetCell(linenum, 1, ColourText(L["Image Quality"], NFC))
	tooltip:SetCell(linenum, 2, ssQuality)
	tooltip:SetLineScript(linenum, "OnMouseUp", Broker_Digicam.SetQuality, ssQuality)

	-- Hints
	tooltip:AddLine(" ", " ")
	tooltip:AddLine(L["|cffffff00Shift-Click|r |cff00ff00broker icon to take a screenshot.|r"])
	tooltip:AddLine(L["|cffffff00Left-Click|r |cff00ff00quality to increase.|r"])
	tooltip:AddLine(L["|cffffff00Alt-Left-Click|r |cff00ff00quality to decrease.|r"])
	tooltip:Show()
end

function dataobj:OnEnter()
	-- Tooltip Setup
	if not LQT:IsAcquired("Broker_DigicamTip") then
		tooltip = LQT:Acquire("Broker_DigicamTip", 2, "LEFT", "RIGHT")
	end
	tooltip:Clear()
	tooltip:SmartAnchorTo(self)
	tooltip:SetAutoHideDelay(0.25, self)
	tooltip:SetScale(1)

	-- Draw it
	Broker_Digicam:DrawTooltip()
end

function dataobj:OnLeave()
	Broker_Digicam:HideTooltip()
end

function dataobj:OnClick(button)
	if IsShiftKeyDown() and button == "LeftButton" then
		Screenshot()
	end
end

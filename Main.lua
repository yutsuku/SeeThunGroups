local _G = getfenv()
local SeeThunGroups = _G.SeeThunGroups

SeeThunGroups.Main = {}
SeeThunGroups.Main.enabled = false

local frame = SeeThunGroups.main_frame
--[[frame:RegisterAllEvents()
frame:SetScript('OnEvent', function()
	DEFAULT_CHAT_FRAME:AddMessage(event)
end)]]
frame:SetScript('OnEvent', function()
	this[event](this)
end)

SeeThunGroups.Main.RegisterEvents = function()
	frame:RegisterEvent('ADDON_LOADED')
	frame:RegisterEvent('RAID_ROSTER_UPDATE')
	frame:RegisterEvent('RAID_TARGET_UPDATE')
end

SeeThunGroups.Main.UnregisterEvents = function()
	frame:UnregisterEvent('ADDON_LOADED')
	frame:UnregisterEvent('RAID_ROSTER_UPDATE')
	frame:UnregisterEvent('RAID_TARGET_UPDATE')
end

frame.ADDON_LOADED = function()
	SeeThunGroups.Player.Update(true)
end
frame.RAID_ROSTER_UPDATE = function()
	SeeThunGroups.Player.Update()
end
frame.RAID_TARGET_UPDATE = function()
	SeeThunGroups.Player.Update()
end

SLASH_SEETHUNGROUPS1, SLASH_SEETHUNGROUPS2, SLASH_SEETHUNGROUPS3 = '/seethungroups', '/stg', '/ctg'
function SlashCmdList.SEETHUNGROUPS(arg)
	SeeThunGroups.Main.enabled = not SeeThunGroups.Main.enabled
	if SeeThunGroups.Main.enabled then
		SeeThunGroups.Main.RegisterEvents()
		SeeThunGroups.Player.Update()
		SeeThunGroups.main_frame:Show()
	else
		SeeThunGroups.Main.UnregisterEvents()
		SeeThunGroups.main_frame:Hide()
	end
end
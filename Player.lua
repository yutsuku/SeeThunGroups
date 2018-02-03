local _G = getfenv()
local SeeThunGroups = _G.SeeThunGroups

local CLASS_ICON = {
	["PATH"]= "Interface\\Glues\\CharacterCreate\\UI-CharacterCreate-Classes",
	["WARRIOR"]	= {0, 0.25, 0, 0.25},
	["MAGE"]	= {0.25, 0.49609375, 0, 0.25},
	["ROGUE"]	= {0.49609375, 0.7421875, 0, 0.25},
	["DRUID"]	= {0.7421875, 0.98828125, 0, 0.25},
	["HUNTER"]	= {0, 0.25, 0.25, 0.5},
	["SHAMAN"]	= {0.25, 0.49609375, 0.25, 0.5},
	["PRIEST"]	= {0.49609375, 0.7421875, 0.25, 0.5},
	["WARLOCK"]	= {0.7421875, 0.98828125, 0.25, 0.5},
	["PALADIN"]	= {0, 0.25, 0.5, 0.75}
};
SeeThunGroups.CLASS_ICON = CLASS_ICON

local TARGET_ICON = {
	["PATH"]= "Interface\\TargetingFrame\\UI-RaidTargetingIcons",
	[1]	= {0, 0.25, 0, 0.25}, -- star
	[2]	= {0.25, 0.5, 0, 0.25}, -- circle
	[3]	= {0.5, 0.75, 0, 0.25}, -- diamond
	[4]	= {0.75, 1.0, 0, 0.25}, -- triangle
	[5]	= {0, 0.25, 0.25, 0.5}, -- moon
	[6]	= {0.25, 0.5, 0.25, 0.5}, -- square
	[7]	= {0.5, 0.75, 0.25, 0.5}, -- X
	[8]	= {0.75, 1.0, 0.25, 0.5}, -- skull
};
local mt = {}
setmetatable(TARGET_ICON, mt)
mt.__index = function(t, k)
	return {0, 0.25, 0.5, 0.75}
end
SeeThunGroups.TARGET_ICON = TARGET_ICON

-- name, class, targetIcon
-- only not assigned to canvas players
local raidList = {
	--[[{"Dreadsome", "WARRIOR", 2},
	{"Merjil", "WARRIOR", 3},
	{"Parderos", "WARRIOR", 4},
	{"Capslocko", "WARRIOR", 5},
	{"Freasynguard", "ROGUE", 6},
	{"Shirtmow", "ROGUE", 7},
	{"Cracklife", "ROGUE", 8},
	{"Shadoon", "WARRIOR", nil},
	{"FuckVarbuk", "WARRIOR", 1},
	{"Aidsbringer", "PRIEST", nil},
	{"Bethilac", "SHAMAN", nil},
	{"Bluepolish", "HUNTER", nil},
	{"Cowform", "DRUID", nil},
	{"Cymbeline", "HUNTER", nil},
	{"Drenty", "SHAMAN", nil},
	{"Figures", "WARLOCK", nil},
	{"Fumtech", "PRIEST", nil},
	{"Gamad", "WARRIOR", nil},
	{"Hecates", "PRIEST", nil},
	{"Igotnobindings", "WARRIOR", nil},
	{"Kaidi", "ROGUE", nil},
	{"Kovarnaya", "DRUID", nil},
	{"Lyrran", "WARLOCK", nil},
	{"Magicwhip", "MAGE", nil},
	{"Nailbiter", "PRIEST", nil},
	{"Nammimanni", "WARLOCK", nil},
	{"Necroballs", "MAGE", nil},
	{"Oddbjorg", "SHAMAN", nil},
	{"Ramonne", "PRIEST", nil},
	{"Rotchild", "HUNTER", nil},
	{"Snitches", "MAGE", nil},
	{"Sulkim", "WARLOCK", nil},
	{"Sylvannaz", "ROGUE", nil},
	{"Temeka", "MAGE", nil},
	{"Teq", "SHAMAN", nil},
	{"Tharek", "WARRIOR", nil},
	{"Turkycat", "MAGE", nil},
	{"Yuuka", "PRIEST", nil}]]
}
SeeThunGroups.raidList = raidList

-- name, class, targetIcon, canvasButtonID
local assignedList = {}
SeeThunGroups.assignedList = assignedList

SeeThunGroups.Player = {}

SeeThunGroups.Player.Clear = function()
	SeeThunGroups.raidList = {}
	SeeThunGroups.assignedList = {}
end

SeeThunGroups.Player.Update = function(wipe)
	local GetNumRaidMembers = GetNumRaidMembers()
	local name, _, class, unitid, icon
	local assignedListLength = getn(SeeThunGroups.assignedList)
	local raidListLength = getn(SeeThunGroups.raidList)
	local found
	local raidMembers = {}
	
	if wipe then
		SeeThunGroups.Player.Clear()
		for i = 1, GetNumRaidMembers, 1 do
			unitid = 'raid'..i
			_, class = UnitClass(unitid)
			name = UnitName(unitid)
			icon = GetRaidTargetIndex(unitid)
			SeeThunGroups.raidList[i] = {name, class, icon}
		end
		local playerFrame, slotFrame
		for i = 1, 40, 1 do
			playerFrame = SeeThunGroups.main_frame.canvas.player[i]
			slotFrame = SeeThunGroups.main_frame.canvas.slot[i]
			playerFrame.InUse = nil
			playerFrame.assignedListIndex = nil
			playerFrame:Hide()
			slotFrame.slotGlowIcon:Hide()
		end
	else
		for i = 1, GetNumRaidMembers, 1 do
			found = nil
			unitid = 'raid'..i
			_, class = UnitClass(unitid)
			name = UnitName(unitid)
			icon = GetRaidTargetIndex(unitid)
			raidMembers[i] = name
			
			for a = 1, assignedListLength, 1 do
				if SeeThunGroups.assignedList[a][1] == name then
					SeeThunGroups.assignedList[a][3] = icon
					found = true
					break
				end
			end
			
			for a = 1, raidListLength, 1 do
				if SeeThunGroups.raidList[a][1] == name then
					SeeThunGroups.raidList[a][3] = icon
					found = true
					break
				end
			end
			
			if not found then
				tinsert(SeeThunGroups.raidList, {name, class, icon})
			end
		end
		
		-- remove REMOVED players
		local playerFrame
		for i = 1, 40, 1 do
			found = nil
			playerFrame = SeeThunGroups.main_frame.canvas.player[i]

			if playerFrame.InUse then
				for a = 1, GetNumRaidMembers, 1 do
					if raidMembers[a] == playerFrame.text.full then
						found = true
						break
					end
				end
				
				if not found then
					for z = 1, assignedListLength, 1 do
						if SeeThunGroups.assignedList[z][1] == playerFrame.text.full then
							tremove(SeeThunGroups.assignedList, z)
							break
						end
					end
					playerFrame.InUse = false
					playerFrame:Hide()
				end
			end
		end
		
		for i = raidListLength, 1, -1 do
			found = nil
			for a = 1, GetNumRaidMembers, 1 do
				if raidMembers[a] == SeeThunGroups.raidList[i][1] then
					found = true
					break
				end
			end
			
			if not found then
				tremove(SeeThunGroups.raidList, i)
			end
		end
		
	end
	
	
	SeeThunGroups.UI.ScrollFrame.Update()
	SeeThunGroups.UI.ClearPlayers()
	SeeThunGroups.UI.PopulatePlayers()
	SeeThunGroups.UI.SortBy(SeeThunGroups.UI.sortBy)
end
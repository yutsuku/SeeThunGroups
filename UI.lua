local _G = getfenv()
local SeeThunGroups = _G.SeeThunGroups

local cos = cos
local sin = sin
local getn = getn
local ipairs = ipairs
local strsub = strsub
local unpack = unpack
local UIscale = UIParent:GetEffectiveScale()

SeeThunGroups.UI = {}
SeeThunGroups.UI.nameCharLimit = 12
SeeThunGroups.UI.nameWidth = 80
SeeThunGroups.UI.sortBy = 1 -- 1 class, 2 name
SeeThunGroups.UI.SORT_BY_CLASS = 1
SeeThunGroups.UI.SORT_BY_NAME = 2
SeeThunGroups.UI.BUTTON_TYPE_LIST = 1
SeeThunGroups.UI.BUTTON_TYPE_CANVAS = 2

SeeThunGroups.UI.SortBy = function(order)
	if order == SeeThunGroups.UI.SORT_BY_CLASS then
		SeeThunGroups.UI.sortBy = SeeThunGroups.UI.SORT_BY_CLASS
		sort(SeeThunGroups.raidList, function(a, b)
			-- if same class, sort by name
			if a[2] == b[2] then
				return a[1] < b[1]
			end
			return a[2] < b[2]
		end)
	elseif order == SeeThunGroups.UI.SORT_BY_NAME then
		SeeThunGroups.UI.sortBy = SeeThunGroups.UI.SORT_BY_NAME
		sort(SeeThunGroups.raidList, function(a, b)
			return a[1] < b[1]
		end)
	end
	SeeThunGroups.UI.ScrollFrame.Update()
	UIDropDownMenu_SetSelectedValue(SeeThunGroups.main_frame.playerList.dropdown, SeeThunGroups.UI.sortBy)
end


local main_frame = CreateFrame('Frame', 'SeeThunGroupsFrame', UIParent)
SeeThunGroups.main_frame = main_frame
main_frame:SetAllPoints()
main_frame:SetBackdrop({
	bgFile=[[Interface\TutorialFrame\TutorialFrameBackground]],
	--edgeFile=[[Interface\TutorialFrame\TutorialFrameBorder]],
	tile = false,
	tileSize = 16,
	--edgeSize = 32,
	--insets = { left = 5, right = 5, top = 24, bottom = 5 }
})
main_frame:SetClampedToScreen(true)
main_frame:EnableMouse(true)
main_frame:SetFrameStrata('DIALOG')
main_frame:Hide()
main_frame:SetScript('OnHide', function()
	SeeThunGroups.Main.enabled = false
end)

local closeButton = CreateFrame('Button', nil, main_frame, 'UIPanelCloseButton')
main_frame.closeButton = closeButton
closeButton:SetPoint('TOPRIGHT', 3, 4)

local playerList = CreateFrame('Frame', nil, main_frame)
main_frame.playerList = playerList
playerList:SetPoint('TOPLEFT', 10, -10)
playerList:SetWidth(196)
playerList:SetHeight(400)
playerList:SetBackdrop({
	bgFile=[[Interface\DialogFrame\UI-DialogBox-Background]],
	--bgFile=[[Interface\Buttons\WHITE8X8]],
	edgeFile=[[Interface\DialogFrame\UI-DialogBox-Border]],
	tile = false,
	tileSize = 32,
	edgeSize = 32,
	insets = { left = 5, right = 5, top = 5, bottom = 5 }
})

do
	local label
	label = playerList:CreateFontString(nil, nil, 'GameFontNormalSmall')
	playerList.labelSortBy = playerList
	label:SetPoint('BOTTOMLEFT', 20, 60)
	label:SetText('Sort by')
	
	label = playerList:CreateFontString(nil, nil, 'GameFontDarkGraySmall')
	playerList.labelVersion = playerList
	label:SetPoint('BOTTOM', 0, 16)
	label:SetText('SeeThunGroups v'..GetAddOnMetadata('SeeThunGroups', 'Version'))
end

do
	local dropdown = CreateFrame('Frame', 'STGDropdown', playerList, 'UIDropDownMenuTemplate')
	playerList.dropdown = dropdown
	dropdown:SetPoint('BOTTOMLEFT', 0, 28)
	UIDropDownMenu_Initialize(dropdown, function()
		local info
		info = {}
		info.text = 'Class'
		info.value = SeeThunGroups.UI.SORT_BY_CLASS
		info.arg1 = info.value
		info.func = SeeThunGroups.UI.SortBy
		UIDropDownMenu_AddButton(info)
		
		info = {}
		info.text = 'Name'
		info.value = SeeThunGroups.UI.SORT_BY_NAME
		info.arg1 = info.value
		info.func = SeeThunGroups.UI.SortBy
		UIDropDownMenu_AddButton(info)
	end)
	
	UIDropDownMenu_SetWidth(60, dropdown)
	UIDropDownMenu_SetSelectedID(dropdown, 1)
end

do
	local resetButton = CreateFrame('Button', nil, playerList, 'UIPanelButtonTemplate')
	playerList.resetButton = resetButton
	resetButton:SetWidth(80)
	resetButton:SetHeight(24)
	resetButton:SetPoint('BOTTOMRIGHT', -14, 34)
	resetButton:SetText('RESET')
	resetButton:SetScript('OnClick', function()
		SeeThunGroups.Player.Update(true)
	end)
end

playerList.buttons = {}
playerList.isMovingPlayer = nil
playerList.newPlayerSlot = nil
playerList.newPlayerSlotOtherPlayer = nil

playerList:SetScript('OnUpdate', function()
	if this.isMovingPlayer then
		this.newPlayerSlot = nil
		this.newPlayerSlotOtherPlayer = nil
		local isGlowing
		for i = 1, 40, 1 do
			if MouseIsOver(main_frame.canvas.slot[i]) then
				main_frame.canvas.slot[i].slotGlowIcon:Show()
				this.newPlayerSlot = main_frame.canvas.slot[i]
				this.newPlayerSlotOtherPlayer = main_frame.canvas.player[i]
				if this.isMovingPlayer.type == SeeThunGroups.UI.BUTTON_TYPE_LIST then
					if not this.newPlayerSlotOtherPlayer.InUse then
						if this.isMovingPlayer.glow then
							this.isMovingPlayer.glow:Show()
						end
						isGlowing = true
					end
				else
					if this.isMovingPlayer.glow then
						this.isMovingPlayer.glow:Show()
					end
					isGlowing = true
				end
				
			else
				if not isGlowing and this.isMovingPlayer.glow then
					this.isMovingPlayer.glow:Hide()
				end
				if this.isMovingPlayer.slotFrame ~= main_frame.canvas.slot[i] then
					main_frame.canvas.slot[i].slotGlowIcon:Hide()
				end
			end
		end
	end
end)


for i=1, 9, 1 do
	local button = CreateFrame('Button', nil, playerList)
	button.type = SeeThunGroups.UI.BUTTON_TYPE_LIST
	button:EnableMouse(true)
	button:SetMovable(true)
	button:RegisterForDrag('LeftButton')
	button:SetID(i)
	button:SetWidth(140)
	button:SetHeight(32)
	button:SetBackdrop({
		bgFile=[[Interface\RaidFrame\UI-RaidFrame-GroupBg]],
		edgeFile=[[Interface\Glues\Common\TextPanel-Border]],
		tile = true,
		tileSize = 128,
		edgeSize = 16,
		insets = { left = 5, right = 2, top = 2, bottom = 2 }
	})

	do
		local name = button:CreateFontString(nil, 'OVERLAY', 'GameFontNormalSmall')
		button.name = name
		name:SetWidth(88)
		name:SetHeight(32)
		name:SetPoint('LEFT', button, 36, 0)
		name:SetJustifyH('LEFT')
		name:SetText('name'..i)
		name.offset = 36
		name.offsetIcon = 36 + 16
	end
	
	do
		local classIcon = button:CreateTexture(nil, 'ARTWORK')
		button.classIcon = classIcon
		classIcon:SetPoint('LEFT', 0, 0)
		classIcon:SetWidth(32)
		classIcon:SetHeight(32)
		classIcon:SetTexture(SeeThunGroups.CLASS_ICON.PATH)
	end
	do
		local targetIcon = button:CreateTexture(nil, 'OVERLAY')
		button.targetIcon = targetIcon
		targetIcon:SetPoint('RIGHT', button.classIcon, 'RIGHT', 18, 0)
		targetIcon:SetWidth(16)
		targetIcon:SetHeight(16)
		targetIcon:SetTexture(SeeThunGroups.TARGET_ICON.PATH)
	end
	do
		local glow = button:CreateTexture(nil, 'OVERLAY')
		button.glow = glow
		glow:SetPoint('TOPLEFT', button, -20, 5)
		glow:SetWidth(180)
		glow:SetHeight(45)
		glow:SetTexture([[Interface\AddOns\SeeThunGroups\Textures\glow]])
		glow:SetBlendMode('ADD')
		glow:Hide()
	end
	
	button:SetPoint('TOPLEFT', playerList, 14, -14 - (i*2) - (i*32) + 32)
	playerList.buttons[i] = button
	
	button:SetScript('OnDragStart', function()
		SeeThunGroups.UI.MovePlayer(this)
		local point, relativeTo, relativePoint, xOfs, yOfs = this:GetPoint()
		this.__point = point
		this.__relativeTo = relativeTo
		this.__relativePoint = relativePoint
		this.__xOfs = xOfs
		this.__yOfs = yOfs
		this:ClearAllPoints()
		this:StartMoving()
	end)
	
	button:SetScript('OnDragStop', function()
		SeeThunGroups.UI.MovePlayer()
		this:StopMovingOrSizing()
		
		if playerList.newPlayerSlot and not playerList.newPlayerSlotOtherPlayer.InUse then
			this:SetPoint(this.__point, this.__relativeTo, this.__relativePoint, this.__xOfs, this.__yOfs)
			SeeThunGroups.UI.playerListButtonToCanvas(this)
		else
			this:SetPoint(this.__point, this.__relativeTo, this.__relativePoint, this.__xOfs, this.__yOfs)
			this.glow:Hide()
		end
	end)
end

do
	local scrollframe = CreateFrame('ScrollFrame', 'SeeThunGroupsScrollFrame', playerList, 'FauxScrollFrameTemplate')
	playerList.scrollframe = scrollframe
	SeeThunGroups.UI.ScrollFrame = scrollframe
	scrollframe:SetWidth(playerList:GetWidth()-40)
	scrollframe:SetHeight(302)
	scrollframe:SetPoint('TOPLEFT', playerList, 0, -15)
	scrollframe:EnableMouse(true)
	
	local t1 = scrollframe:CreateTexture(nil, 'BACKGROUND')
	scrollframe.t1 = t1
	t1:SetTexture([[Interface\PaperDollInfoFrame\UI-Character-ScrollBar]])
	t1:SetWidth(31)
	t1:SetHeight(226)
	t1:SetPoint('TOPLEFT', scrollframe, 'TOPRIGHT', -2, 5)
	t1:SetTexCoord(0, 0.484375, 0, 0.8828125)
	
	local t2 = scrollframe:CreateTexture(nil, 'BACKGROUND')
	scrollframe.t2 = t2
	t2:SetTexture([[Interface\PaperDollInfoFrame\UI-Character-ScrollBar]])
	t2:SetWidth(31)
	t2:SetHeight(106)
	t2:SetPoint('BOTTOMLEFT', scrollframe, 'BOTTOMRIGHT', -2, -2)
	t2:SetTexCoord(0.515625, 1.0, 0, 0.4140625)
	
	scrollframe.Update = function()
		local offset = FauxScrollFrame_GetOffset(scrollframe)

		for i=1, 9, 1 do
			local name, class, index, button
			
			index = offset + i
			button = playerList.buttons[i]
			button.index = index
			button.slot = i
			
			if index > getn(SeeThunGroups.raidList) then
				button:Hide()
			else						
				button.name:SetText(SeeThunGroups.raidList[index][1])
				local icon = SeeThunGroups.CLASS_ICON[SeeThunGroups.raidList[index][2]]
				button.classIcon:SetTexCoord(icon[1], icon[2], icon[3], icon[4])
				icon = SeeThunGroups.TARGET_ICON[SeeThunGroups.raidList[index][3]]
				button.targetIcon:SetTexCoord(icon[1], icon[2], icon[3], icon[4])
				
				if SeeThunGroups.raidList[index][3] then
					button.name:SetPoint('LEFT', button, button.name.offsetIcon, 0)
				else
					button.name:SetPoint('LEFT', button, button.name.offset, 0)
				end
				
				button:Show()
			end
		end
		-- Function to handle the update of manually calculated scrollframes.  Used mostly for listings with an indeterminate number of items
		-- function FauxScrollFrame_Update(frame, numItems, numToDisplay, valueStep, button, smallWidth, bigWidth, highlightFrame, smallHighlightWidth, bigHighlightWidth )
		FauxScrollFrame_Update(scrollframe, getn(SeeThunGroups.raidList), 9, 32)
	end
	
	scrollframe:SetScript('OnVerticalScroll', function()
		-- function FauxScrollFrame_OnVerticalScroll(itemHeight, updateFunction)
		FauxScrollFrame_OnVerticalScroll(32, scrollframe.Update)
	end)
	scrollframe:SetScript('OnShow', function()
		scrollframe.Update()
	end)
	
	scrollframe.Update()
end

local canvas = CreateFrame('Frame', nil, main_frame)
SeeThunGroups.main_frame.canvas = canvas
canvas:SetAllPoints()
canvas.player = {}
canvas.slot = {}

local t

t = canvas:CreateTexture(nil, 'BACKGROUND')
canvas.background = t
t:SetTexture([[Interface\AddOns\SeeThunGroups\Textures\bg]])
t:SetPoint('CENTER', canvas)
t:SetWidth(UIParent:GetHeight() * UIscale)
t:SetHeight(UIParent:GetHeight() * UIscale)

t = canvas:CreateTexture(nil, 'ARTWORK')
canvas.cthun_icon = t
t:SetTexture([[Interface\AddOns\SeeThunGroups\Textures\eye]])
t:SetPoint('CENTER', 0, 0)
t:SetWidth(250)
t:SetHeight(250)

local startAngleBase = {
	22.5,
	22.5 + (22.5 / 2),
	22.5 + (22.5 / 2)
}
local itemOffset = {
	canvas.background:GetHeight() / 5 - 32,
	canvas.background:GetHeight() / 3 - 32,
	canvas.background:GetHeight() / 2 - 32 - 16
}

-- prepare canvas
do
	local __ringItemCount = 8
	local slotFrame
	local playerFrame
	local classIcon
	local targetIcon
	local glow
	local slotIcon
	local slotGlowIcon
	local text
	local startAngle
	local uid = 1
	
	for ringNumber = 1, 3, 1 do
		startAngle = startAngleBase[ringNumber]
		
		if ringNumber > 1 then
			__ringItemCount = 16
		end
		
		for ringItemCount = 1, __ringItemCount, 1 do
			canvas.player[uid] = {}
			canvas.slot[uid] = {}

			slotFrame = CreateFrame('Frame', nil, canvas)
			slotFrame:SetID(uid)
			slotFrame:SetWidth(32)
			slotFrame:SetHeight(32)
			slotFrame:SetFrameLevel(slotFrame:GetFrameLevel()-1)
			
			slotIcon = slotFrame:CreateTexture(nil, 'BORDER')
			slotGlowIcon = slotFrame:CreateTexture(nil, 'BORDER')
			
			playerFrame = CreateFrame('Frame', nil, canvas)
			playerFrame.type = SeeThunGroups.UI.BUTTON_TYPE_CANVAS
			playerFrame:SetID(uid)
			playerFrame:SetWidth(32)
			playerFrame:SetHeight(32)
			playerFrame:EnableMouse(true)
			playerFrame:SetMovable(true)
			playerFrame:RegisterForDrag('LeftButton')
			playerFrame:SetFrameLevel(slotFrame:GetFrameLevel() + 1)
			playerFrame.InUse = nil
			
			classIcon = playerFrame:CreateTexture(nil, 'BORDER')
			targetIcon = playerFrame:CreateTexture(nil, 'ARTWORK')
			glow = playerFrame:CreateTexture(nil, 'ARTWORK')
			text = playerFrame:CreateFontString()
			
			canvas.player[uid] = playerFrame
			canvas.slot[uid] = slotFrame
			
			playerFrame.targetIcon = targetIcon
			playerFrame.classIcon = classIcon
			playerFrame.glow = glow
			playerFrame.text = text
			
			slotFrame.slotIcon = slotIcon
			slotFrame.slotGlowIcon = slotGlowIcon
			
			do
				classIcon:SetPoint('CENTER', 0, 0)
				classIcon:SetWidth(32)
				classIcon:SetHeight(32)
				classIcon:SetTexture(SeeThunGroups.CLASS_ICON.PATH)
				classIcon:SetTexCoord(unpack(SeeThunGroups.CLASS_ICON.WARRIOR))
			end
			do
				targetIcon:SetPoint('TOP', 0, 8)
				targetIcon:SetWidth(16)
				targetIcon:SetHeight(16)
				targetIcon:SetTexture(SeeThunGroups.TARGET_ICON.PATH)
			end	
			
			do
				glow:SetPoint('CENTER', 0, 0)
				glow:SetWidth(32)
				glow:SetHeight(32)
				glow:SetTexture([[Interface\Buttons\CheckButtonHilight]])
				glow:SetBlendMode('ADD')
				glow:Hide()
			end
			
			do
				slotIcon:SetPoint('CENTER', 0, 0)
				slotIcon:SetWidth(32)
				slotIcon:SetHeight(32)
				slotIcon:SetTexture([[Interface\Buttons\UI-EmptySlot]])
				
				slotGlowIcon:SetPoint('CENTER', 0, 0)
				slotGlowIcon:SetWidth(32)
				slotGlowIcon:SetHeight(32)
				slotGlowIcon:SetTexture([[Interface\Buttons\CheckButtonGlow]])
				slotGlowIcon:SetBlendMode('ADD')
				slotGlowIcon:Hide()
			end
			
			text.full = nil
			text:SetWidth(SeeThunGroups.UI.nameWidth)
			text:SetHeight(32)
			text:SetPoint('BOTTOM', 0, -16)
			text:SetFontObject(SeeThunGroups.font)
			text:SetText()
			
			do
				local x, y
				x = 0
				y = 0
				x = x + (itemOffset[ringNumber] * cos(-startAngle))
				y = y + (itemOffset[ringNumber] * sin(-startAngle)) 
				slotFrame:SetPoint('CENTER', x, y)
				playerFrame:SetPoint('CENTER', x, y)
				startAngle = startAngle - (360 / __ringItemCount)
			end
			
			playerFrame:SetScript('OnDragStart', function()
				GameTooltip:Hide()
				SeeThunGroups.UI.MovePlayer(this)
				this:SetFrameLevel(this:GetFrameLevel()+1)
				this:StartMoving()
			end)
			
			playerFrame:SetScript('OnDragStop', function()
				SeeThunGroups.UI.MovePlayer()
				this:SetFrameLevel(this:GetFrameLevel()-1)
				this:StopMovingOrSizing()
				this:ClearAllPoints()
				
				if playerList.newPlayerSlot and playerList.newPlayerSlotOtherPlayer.assignedListIndex ~= this.assignedListIndex then
					if playerList.newPlayerSlotOtherPlayer.InUse then
						-- swap players
						local point, relativeTo, relativePoint, xOfs, yOfs = canvas.slot[this:GetID()]:GetPoint()
						this:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs)
						this.glow:Hide()
						
						local otherPlayer = canvas.player[playerList.newPlayerSlotOtherPlayer:GetID()]
						otherPlayer.glow:Hide()
						
						local assignedListIndex, text, classIcon, targetIcon
						assignedListIndex = this.assignedListIndex
						text = this.text.full
						classIcon = {this.classIcon:GetTexCoord()}
						targetIcon = {this.targetIcon:GetTexCoord()}
						
						this.assignedListIndex = otherPlayer.assignedListIndex
						this.text.full = otherPlayer.text.full
						this.text:SetText(strsub(this.text.full, 1, SeeThunGroups.UI.nameCharLimit))
						this.classIcon:SetTexCoord(otherPlayer.classIcon:GetTexCoord())
						this.targetIcon:SetTexCoord(otherPlayer.targetIcon:GetTexCoord())
						
						otherPlayer.assignedListIndex = assignedListIndex
						otherPlayer.text.full = text
						otherPlayer.text:SetText(strsub(text, 1, SeeThunGroups.UI.nameCharLimit))
						otherPlayer.classIcon:SetTexCoord(unpack(classIcon))
						otherPlayer.targetIcon:SetTexCoord(unpack(targetIcon))
						
					else
						local point, relativeTo, relativePoint, xOfs, yOfs = canvas.slot[this:GetID()]:GetPoint()
						local playerFrame = canvas.player[playerList.newPlayerSlotOtherPlayer:GetID()]
						this:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs)
						this.glow:Hide()
						this.InUse = nil
						this:Hide()
						
						playerFrame.InUse = true 
						playerFrame.assignedListIndex = this.assignedListIndex
						playerFrame.text.full = this.text.full
						playerFrame.text:SetText(strsub(playerFrame.text.full, 1, SeeThunGroups.UI.nameCharLimit))
						playerFrame.classIcon:SetTexCoord(this.classIcon:GetTexCoord())
						playerFrame.targetIcon:SetTexCoord(this.targetIcon:GetTexCoord())
						playerFrame:Show()
						
						this.assignedListIndex = nil
						
						SeeThunGroups.assignedList[playerFrame.assignedListIndex][4] = playerList.newPlayerSlot:GetID()
					end
				else
					local point, relativeTo, relativePoint, xOfs, yOfs = canvas.slot[this:GetID()]:GetPoint()
					this:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs)
					this.glow:Hide()
				end
			end)
			
			playerFrame:SetScript("OnEnter", function()
				if this.text and this.text.full and not playerList.isMovingPlayer then
					GameTooltip:SetOwner(this, "ANCHOR_CURSOR")
					GameTooltip:SetText(this.text.full)
					GameTooltip:Show()
				end
			end)
			playerFrame:SetScript("OnLeave", function()
				GameTooltip:Hide()
			end)
			
			uid = uid + 1

		end
		
	end
end

SeeThunGroups.UI.playerListButtonToCanvas = function(button)
	local playerFrame = playerList.newPlayerSlotOtherPlayer
	local point, relativeTo, relativePoint, xOfs, yOfs = playerList.newPlayerSlot:GetPoint()
	
	playerFrame:ClearAllPoints()
	playerFrame:SetPoint(point, relativeTo, relativePoint, xOfs, yOfs)
	playerFrame.InUse = true
	
	local t = SeeThunGroups.raidList[button.index]
	t[4] = playerList.newPlayerSlot:GetID()
	tinsert(SeeThunGroups.assignedList, t);
	local assignedListIndex = getn(SeeThunGroups.assignedList)
	tremove(SeeThunGroups.raidList, button.index)
	button.glow:Hide()
	
	playerFrame.assignedListIndex = assignedListIndex
	playerFrame.text.full = t[1]
	playerFrame.text:SetText(strsub(t[1], 1, SeeThunGroups.UI.nameCharLimit))
	local icon = SeeThunGroups.TARGET_ICON[t[3]]
	playerFrame.targetIcon:SetTexCoord(icon[1], icon[2], icon[3], icon[4])
	icon = SeeThunGroups.CLASS_ICON[t[2]]
	playerFrame.classIcon:SetTexCoord(icon[1], icon[2], icon[3], icon[4])
	
	playerFrame:Show()
	SeeThunGroups.UI.ScrollFrame.Update()
end

SeeThunGroups.UI.MovePlayer = function(button)
	playerList.isMovingPlayer = button
end

SeeThunGroups.UI.ClearPlayers = function()
	local playerFrame
	for index = 1, 40, 1 do
		playerFrame = canvas.player[index]
		playerFrame:Hide()
	end
	for index = 1, 9, 1 do
		playerList.buttons[index]:EnableMouse(true)
		playerList.buttons[index]:SetMovable(true)
	end
end

SeeThunGroups.UI.PopulatePlayers = function()
	local startAngle
	local playerFrame
	local classIcon
	local targetIcon
	local slotFrame
	local text
	
	for index, player in ipairs(SeeThunGroups.assignedList) do
	if player[4] then
		playerFrame = canvas.player[player[4]]
		slotFrame = canvas.slot[player[4]]
		slotFrame.inUse = playerFrame
		playerFrame:EnableMouse(true)
		classIcon = playerFrame.classIcon
		targetIcon = playerFrame.targetIcon
		text = playerFrame.text
			
		do
			local icon = SeeThunGroups.CLASS_ICON[player[2]]
			classIcon:SetTexCoord(icon[1], icon[2], icon[3], icon[4])
			classIcon:Show()
		end
		do
			local icon = SeeThunGroups.TARGET_ICON[player[3]]
			targetIcon:SetTexCoord(icon[1], icon[2], icon[3], icon[4])
			targetIcon:Show()
		end	
		
		text.full = player[1]
		text:SetText(strsub(player[1], 1, SeeThunGroups.UI.nameCharLimit))
		
		playerFrame:SetScript("OnEnter", function()
			if this.text and this.text.full then
				GameTooltip:SetOwner(this, "ANCHOR_CURSOR")
				GameTooltip:SetText(this.text.full)
				GameTooltip:Show()
			end
		end)
		playerFrame:SetScript("OnLeave", function()
			GameTooltip:Hide()
		end)
		
		playerFrame:Show()

	end
	end

end

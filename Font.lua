local _G = getfenv()
local SeeThunGroups = _G.SeeThunGroups

local font = CreateFont('STGFont')
do
	font:SetFontObject(GameFontNormal)
	local name, size, flags = font:GetFont()
	font:SetFont(name, 18, 'OUTLINE')
end

SeeThunGroups.font = font

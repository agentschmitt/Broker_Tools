if not LibStub then return end

local LibQTip = LibStub('LibQTip-1.0')
local LibSecureFrame = LibStub('LibSecureFrame-1.0')
local LibIcon = LibStub('LibDBIcon-1.0')
local LibDataBroker = LibStub:GetLibrary('LibDataBroker-1.1')

local _

local CreateFrame = CreateFrame
local GetNumGroupMembers = GetNumGroupMembers
local SendChatMessage = SendChatMessage
local UnitInRaid = UnitInRaid

local UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT = UIDROPDOWNMENU_DEFAULT_TEXT_HEIGHT

local addonName, addonTable = ...
local L = addonTable.L
local items = addonTable.items
local spells = addonTable.spells
local mounts = addonTable.mounts
local itemLinks = addonTable.itemLinks

local updateItems = addonTable.updateItems
local updateMountSpells = addonTable.updateMountSpells
local updateSpells = addonTable.updateSpells
local getItemCD = addonTable.getItemCD
local getSpellCD = addonTable.getSpellCD
local getTextWithCooldown = addonTable.getTextWithCooldown

local LDB = LibDataBroker:NewDataObject(addonName, {
    type = 'data source',
    text = L['P'],
    icon = 'Interface\\Icons\\inv_misc_head_clockworkgnome_01',
})
local tooltip
local frame = CreateFrame('frame')

frame:SetScript('OnEvent', function(self, event, ...) if self[event] then return self[event](self, event, ...) end end)
frame:RegisterEvent('PLAYER_LOGIN')
frame:RegisterEvent('SKILL_LINES_CHANGED')

local function tableCount(table)
    local count = 0
    for _ in pairs(table) do count = count + 1 end
    return count
end

local function ToggleMinimap()
    local hide = not ToolsDB.minimap.hide
    ToolsDB.minimap.hide = hide
    if hide then
        LibIcon:Hide('Broker_Tools')
        print ('tools removed from minimap')
    else
        LibIcon:Show('Broker_Tools')
        print ('tools added to minimap')
    end
end

local function UpdateIcon(icon)
    LDB.icon = icon
end

local function AddItemToMenu(itemID, location)
    local link = itemLinks[itemID]

    if (link ~= nil and link.hasItem) then
        local cooldown = getItemCD(itemID)
        
        local name        
        if location ~= nil then
            name = link.name .. ": " .. location
        else
            name = link.name
        end

        local text = getTextWithCooldown(name, cooldown)    
        local lineIndex = tooltip:AddLine(("|T%s:16|t%s"):format(link.icon, ' '..text))
        
        tooltip:SetCellScript(lineIndex, 1, "OnEnter", function(self)
            LibSecureFrame:Activate(link.secure, self, tooltip)
        end)

        tooltip:SetCellScript(lineIndex, 1, "OnMouseDown", function(self)
            UpdateIcon(link.icon)
        end)

        return true
    else
        return false
    end
end

local function AddSpellToMenu(link)
    local text

    if (not link.isUsable) then
        text = getTextWithCooldown(link.name, -1)
    else
        local cooldown = getSpellCD(link.name)
        text = getTextWithCooldown(link.name, cooldown)
    end

    local lineIndex = tooltip:AddLine(("|T%s:16|t%s"):format(link.icon, ' '..text))
    
    tooltip:SetCellScript(lineIndex, 1, "OnEnter", function(self)
        LibSecureFrame:Activate(link.secure, self, tooltip)
    end)

    tooltip:SetCellScript(lineIndex, 1, "OnMouseDown", function(self)
        UpdateIcon(link.icon)
    end)
end

local function AddSpellsToMenu(links)
    local addedItem = false

    for _, link in pairs(links) do
        AddSpellToMenu(link)
        addedItem = true
    end

    return addedItem
end

local function AddItemsToMenu(itemIDs, text)
    local addedItem = false

    for i = 1, #itemIDs do
        local itemID = itemIDs[i]
        if (AddItemToMenu(itemID, text)) then
            addedItem = true
        end
    end

    return addedItem
end

local function ShowItems()
    return AddItemsToMenu(items)
end

local function ShowMountSpells()
    local links = updateMountSpells()
    return AddSpellsToMenu(links)
end

local function ShowSpells()
    local links = updateSpells()
    return AddSpellsToMenu(links)
end

local function ShowTooltip(self)
   -- Acquire a tooltip with 1 columns, aligned to left
   tooltip = LibQTip:Acquire(addonName.."tip", 1, "LEFT") 
   self.tooltip = tooltip
   tooltip:EnableMouse(true)
   tooltip:SetAutoHideDelay(.2, self)
 
  -- Use smart anchoring code to anchor the tooltip to our frame
   tooltip:SmartAnchorTo(self)
   tooltip:Clear()

   -- add content
   local added = false

   if added then tooltip:AddLine(" ") end
   added = ShowMountSpells()  
   if added then tooltip:AddLine(" ") end   
   added = ShowSpells()
   if added then tooltip:AddLine(" ") end
   added = ShowItems()

   tooltip:Show()
end

local function HideTooltip(self)
    LibQTip:Release(self.tooltip)
end

function frame:PLAYER_LOGIN()
    if (not ToolsDB) then
        ToolsDB = {}
        ToolsDB.minimap = {}
        ToolsDB.minimap.hide = false
        ToolsDB.version = 1
    end

    if LibIcon then
        LibIcon:Register('Broker_Tools', LDB, ToolsDB.minimap)
    end

    updateItems()

    self:UnregisterEvent('PLAYER_LOGIN')
end

function frame:SKILL_LINES_CHANGED()
    updateSpells()
end

function LDB.OnClick(self, button)
    if button == "RightButton" then
        HideTooltip(self)
    end
end

function LDB.OnEnter(self)
    ShowTooltip(self)
end

-- slash command definition
SlashCmdList['BROKER_TOOlS_SLASHCMD'] = function(msg)
    ToggleMinimap()
end
SLASH_BROKER_TOOlS_SLASHCMD1 = '/tools'

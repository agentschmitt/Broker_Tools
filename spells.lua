local addonName, addonTable = ...

-- add mountID, not spellID
local mounts = {
    { 284, 'TRUE' }, -- Mammut Repair
    { 460, 'TRUE' }, -- Yak Transmog + Repair
    { 1039, 'TRUE' } -- Brutosaurus Auctionhouse
}

local spells = {
    { 83958, 'TRUE' }, -- Guild Bank
    { 69046, 'TRUE' }, -- Goblin Bank
    { 255661, 'TRUE' }, -- Nightborne Mail
}

addonTable.mounts = mounts
addonTable.spells = spells
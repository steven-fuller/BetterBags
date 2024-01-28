local addonName = ... ---@type string

---@class BetterBags: AceAddon
local addon = LibStub('AceAddon-3.0'):GetAddon(addonName)

---@class itemTooltips: AceModule
local itemTooltips = addon:NewModule('ItemTooltips')

---@class Constants: AceModule
local const = addon:GetModule('Constants')

---@class Events: AceModule
local events = addon:GetModule('Events')

---@class Debug: AceModule
local debug = addon:GetModule('Debug')


---@enum TooltipDataItemBinding
const.TOOLTIP_DATA_ITEM_BINDING = {
  [Enum.TooltipDataItemBinding.Quest] = 0,
  [Enum.TooltipDataItemBinding.Account] = 1,
  [Enum.TooltipDataItemBinding.BnetAccount] = 2,
  [Enum.TooltipDataItemBinding.Soulbound] = 3,
  [Enum.TooltipDataItemBinding.BindToAccount] = 4,
  [Enum.TooltipDataItemBinding.BindToBnetAccount] = 5,
  [Enum.TooltipDataItemBinding.BindOnPickup] = 6,
  [Enum.TooltipDataItemBinding.BindOnEquip] = 7,
  [Enum.TooltipDataItemBinding.BindOnUse] = 8,
}
  
---@enum TooltipDataLineType
const.TOOLTIP_DATA_LINE_TYPE = {
  [Enum.TooltipDataLineType.NestedBlock] = 19,
  [Enum.TooltipDataLineType.ItemBinding] = 20,
}

---@class BindingMap
---@type table<number, string>
const.BINDING_MAP = {
  [Enum.TooltipDataItemBinding.Quest] = "Quest",
  [Enum.TooltipDataItemBinding.Account] = "Account Bound",
  [Enum.TooltipDataItemBinding.BnetAccount] = "BNetAccount", -- Obsolete
  [Enum.TooltipDataItemBinding.Soulbound] = "Soulbound",
  [Enum.TooltipDataItemBinding.BindToAccount] = "Bind to Account", 
  [Enum.TooltipDataItemBinding.BindToBnetAccount] = "Bind to BNet Account", -- Obsolete
  [Enum.TooltipDataItemBinding.BindOnPickup] = "Bind on Pickup",
  [Enum.TooltipDataItemBinding.BindOnEquip] = "Bind on Equip",
  [Enum.TooltipDataItemBinding.BindOnUse] = "Bind on Use",
}

function itemTooltips:OnInitialize()
  --dataInstanceIDtobagAndSlot = {} -- place to store dataInstanceID if we need to refresh
  --events:RegisterEvent("TOOLTIP_DATA_UPDATE") - doesn't seem necessary with current items:RefreshAll()
end

function itemTooltips:OnEnable()
  self:Update()
end

function itemTooltips:Update()
end

---@param bagid number
---@param slotid number
---@return Enum.ItemBinding|nil
function itemTooltips:GetItemBinding(bagid, slotid)
  local tooltipData = C_TooltipInfo.GetBagItem(bagid, slotid)
  if not tooltipData then return nil end
  local binding = itemTooltips:GetItemBindingFromTooltipData(tooltipData)
  if binding then 
    return const.BINDING_MAP[binding] 
  end
  return nil
end

---@param tooltipData tooltipData
---@return Enum.TooltipDataItemBinding|nil
function itemTooltips:GetItemBindingFromTooltipData(tooltipData)
  for i = 2, 6 do  -- small asumption on where binding shows
    local line = tooltipData.lines[i]
    if (not line) then
      break
    end
    if line.type == Enum.TooltipDataLineType.NestedBlock then
      return nil
    end
    if line.type == Enum.TooltipDataLineType.ItemBinding then
      return line.bonding
    end
  end
  return nil
end

itemTooltips:Enable()
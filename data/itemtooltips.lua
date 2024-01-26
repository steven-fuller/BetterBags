local addonName = ... ---@type string

---@class BetterBags: AceAddon
local addon = LibStub('AceAddon-3.0'):GetAddon(addonName)

---@class itemTooltips: AceModule

local itemTooltips = addon:NewModule('ItemTooltips')

---@class Events: AceModule
local events = addon:GetModule('Events')

function itemTooltips:OnInitialize()
end

function itemTooltips:OnEnable()
  self:Update()
end

function itemTooltips:Update()
 -- todo: Do we need to deal with TOOLTIP_DATA_UPDATE or does itemMixin:IsItemDataCached() gather tooltips?
end

---@param tooltipData tooltipData
---@return Enum.TooltipDataItemBinding|nil
function itemTooltips:GetItemBinding(tooltipData)
  if not tooltipData then return nil end
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
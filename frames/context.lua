local addonName = ... ---@type string

---@class BetterBags: AceAddon
local addon = LibStub('AceAddon-3.0'):GetAddon(addonName)

---@class Context: AceModule
---@field frame Frame
local context = addon:NewModule('Context')

---@class Constants: AceModule
local const = addon:GetModule('Constants')

---@class Database: AceModule
local database = addon:GetModule('Database')

---@class SliderFrame: AceModule
local slider = addon:GetModule('Slider')

---@class Categories: AceModule
local categories = addon:GetModule('Categories')

---@class Localization: AceModule
local L =  addon:GetModule('Localization')

local LibDD = LibStub:GetLibrary("LibUIDropDownMenu-4.0")

---@class (exact) MenuList
---@field text string
---@field value? any
---@field checked? boolean|function
---@field isNotRadio? boolean
---@field isTitle? boolean
---@field disabled? boolean
---@field tooltipTitle? string
---@field tooltipText? string
---@field func? function
---@field notCheckable? boolean
---@field hasArrow? boolean
---@field menuList? MenuList[]
---@field keepShownOnClick? boolean
---@field tooltipOnButton? boolean
local menuListProto = {}

function context:OnInitialize()
  --self:CreateContext()
end

function context:OnEnable()
  local frame = LibDD:Create_UIDropDownMenu("BetterBagsContextMenu", UIParent)
  LibDD:EasyMenu_Initialize(frame, 4, {})
  self.frame = frame
end

---@param menuList MenuList[]
function context:Show(menuList)
  LibDD:EasyMenu(menuList, self.frame, 'cursor', 0, 0, 'MENU')
end

function context:Hide()
  LibDD:HideDropDownMenu(1)
end

local function addDivider(menuList)
  table.insert(menuList, {
    text = "",
    isTitle = true,
    hasArrow = false,
    notCheckable = true,
    iconOnly = true,
    isUninteractable = true,
    icon = "Interface\\Common\\UI-TooltipDivider-Transparent",
    iconInfo = {
      tCoordLeft = 0,
			tCoordRight = 1,
			tCoordTop = 0,
			tCoordBottom = 1,
			tSizeX = 0,
			tSizeY = 8,
			tFitDropDownSizeX = true
    },
  })
end

---@param menu MenuList[]
local function enableTooltips(menu)
  for _, m in ipairs(menu) do
    m.tooltipOnButton = true
    if m.menuList then
      enableTooltips(m.menuList)
    end
  end
end

---@param bag Bag
---@return MenuList[]
function context:CreateContextMenu(bag)
  ---@type MenuList[]
  local menuList = {}

  -- Context Menu title.
  table.insert(menuList, {
    text = L:G("BetterBags Menu"),
    isTitle = true,
    notCheckable = true
  })

  -- View menu for switching between one bag and section grid.
  table.insert(menuList, {
    text = L:G("View"),
    hasArrow = true,
    notCheckable = true,
    menuList = {
      {
        text = L:G("One Bag"),
        keepShownOnClick = false,
        checked = function() return database:GetBagView(bag.kind) == const.BAG_VIEW.ONE_BAG end,
        tooltipTitle = L:G("One Bag"),
        tooltipText = L:G("This view will display all items in a single bag, regardless of category."),
        func = function()
          context:Hide()
          database:SetBagView(bag.kind, const.BAG_VIEW.ONE_BAG)
          bag:ClearRecentItems()
          bag:Wipe()
          bag:Refresh()
        end
      },
      {
        text = L:G("Section Grid"),
        keepShownOnClick = false,
        checked = function() return database:GetBagView(bag.kind) == const.BAG_VIEW.SECTION_GRID end,
        tooltipTitle = L:G("Section Grid"),
        tooltipText = L:G("This view will display items in sections, which are categorized by type, expansion, trade skill, and more."),
        func = function()
          context:Hide()
          database:SetBagView(bag.kind, const.BAG_VIEW.SECTION_GRID)
          bag.drawOnClose = true
          bag.currentItemCount = -1
          bag:ClearRecentItems()
          bag:Wipe()
          bag:Refresh()
        end
      },
      {
        text = L:G("List"),
        keepShownOnClick = false,
        checked = function() return database:GetBagView(bag.kind) == const.BAG_VIEW.LIST end,
        tooltipTitle = L:G("List"),
        tooltipText = L:G("This view will display items in a list, which is categorized by type, expansion, trade skill, and more."),
        func = function()
          context:Hide()
          database:SetBagView(bag.kind, const.BAG_VIEW.LIST)
          bag:ClearRecentItems()
          bag:Wipe()
          bag:Refresh()
        end
      }
    }
  })

  local columnSlider = slider:CreateDropdownSlider()
  columnSlider:SetMinMaxValues(1, 20)
  columnSlider:SetValue(database:GetBagSizeInfo(bag.kind, database:GetBagView(bag.kind)).columnCount)
  columnSlider.OnMouseUp = function()
    context:Hide()
  end
  columnSlider.OnValueChanged = function(_, value)
    if database:GetBagSizeInfo(bag.kind, database:GetBagView(bag.kind)).columnCount == value then return end
    database:SetBagViewSizeColumn(bag.kind, database:GetBagView(bag.kind), value)
    bag:Wipe()
    bag:Refresh()
  end

  local itemsPerRowSlider = slider:CreateDropdownSlider()
  itemsPerRowSlider:SetMinMaxValues(3, 20)
  itemsPerRowSlider:SetValue(database:GetBagSizeInfo(bag.kind, database:GetBagView(bag.kind)).itemsPerRow)
  itemsPerRowSlider.OnMouseUp = function()
    context:Hide()
  end
  itemsPerRowSlider.OnValueChanged = function(_, value)
    if database:GetBagSizeInfo(bag.kind, database:GetBagView(bag.kind)).itemsPerRow == value then return end
    database:SetBagViewSizeItems(bag.kind, database:GetBagView(bag.kind), value)
    bag:Wipe()
    bag:Refresh()
  end

  local scaleSlider = slider:CreateDropdownSlider()
  scaleSlider:SetMinMaxValues(60, 100)
  scaleSlider:SetValue(database:GetBagSizeInfo(bag.kind, database:GetBagView(bag.kind)).scale)
  scaleSlider.OnMouseUp = function()
    context:Hide()
  end
  scaleSlider.OnValueChanged = function(_, value)
    if database:GetBagSizeInfo(bag.kind, database:GetBagView(bag.kind)).scale == value then return end
    bag.frame:SetScale(value / 100)
    database:SetBagViewSizeScale(bag.kind, database:GetBagView(bag.kind), value)
  end

  local opacitySlider = slider:CreateDropdownSlider()
  opacitySlider:SetMinMaxValues(60, 100)
  opacitySlider:SetValue(database:GetBagSizeInfo(bag.kind, database:GetBagView(bag.kind)).opacity)
  opacitySlider.OnMouseUp = function()
    context:Hide()
  end
  opacitySlider.OnValueChanged = function(_, value)
    if database:GetBagSizeInfo(bag.kind, database:GetBagView(bag.kind)).opacity == value then return end
    bag.frame.Bg:SetAlpha(value / 100)
    database:SetBagViewSizeOpacity(bag.kind, database:GetBagView(bag.kind), value)
  end

  -- Create the size menu.
  table.insert(menuList, {
    text = L:G("Size"),
    hasArrow = true,
    notCheckable = true,
    menuList = {
      {
        text = L:G("Items per Row"),
        notCheckable = true,
        hasArrow = true,
        menuList = {
          {
            text = L:G("Items per Row"),
            notCheckable = true,
            customFrame = itemsPerRowSlider:GetFrame(),
          }
        }
      },
      {
        text = L:G("Columns"),
        notCheckable = true,
        hasArrow = true,
        menuList = {
          {
            text = L:G("Columns"),
            notCheckable = true,
            customFrame = columnSlider:GetFrame(),
          }
        }
      },
      {
        text = L:G("Opacity"),
        notCheckable = true,
        hasArrow = true,
        menuList = {
          {
            text = L:G("Opacity"),
            notCheckable = true,
            customFrame = opacitySlider:GetFrame(),
          }
        }

      },
      {
        text = L:G("Scale"),
        notCheckable = true,
        hasArrow = true,
        menuList = {
          {
            text = L:G("Scale"),
            notCheckable = true,
            customFrame = scaleSlider:GetFrame(),
          }
        }
      }
    }
  })

  if bag.kind == const.BAG_KIND.BANK then
    table.insert(menuList, {
      text = L:G("Deposit All Reagents"),
      notCheckable = true,
      tooltipTitle = L:G("Deposit All Reagents"),
      tooltipText = L:G("Click to deposit all reagents into your reagent bank."),
      func = function()
        PlaySound(SOUNDKIT.IG_BACKPACK_CLOSE)
        DepositReagentBank()
      end
    })
  end

  -- Show bag slot toggle.
  table.insert(menuList, {
    text = L:G("Show Bags"),
    checked = function() return bag.slots:IsShown() end,
    tooltipTitle = L:G("Show Bags"),
    tooltipText = L:G("Click to toggle the display of the bag slots."),
    func = function()
      if bag.slots:IsShown() then
        bag.slots:Hide()
      else
        bag.slots:Draw()
        bag.slots:Show()
      end
    end
  })

  if bag.kind == const.BAG_KIND.BACKPACK then
    -- Show the Blizzard bag button toggle.
    table.insert(menuList, {
      text = L:G("Show Bag Button"),
      tooltipTitle = L:G("Show Bag Button"),
      tooltipText = L:G("Click to toggle the display of the Blizzard bag button."),
      checked = function()
        local sneakyFrame = _G["BetterBagsSneakyFrame"] ---@type Frame
        return BagsBar:GetParent() ~= sneakyFrame
      end,
      func = function()
        local sneakyFrame = _G["BetterBagsSneakyFrame"] ---@type Frame
        local isShown = BagsBar:GetParent() ~= sneakyFrame
        if isShown then
          BagsBar:SetParent(sneakyFrame)
        else
          BagsBar:SetParent(UIParent)
        end
        database:SetShowBagButton(not isShown)
      end
    })
  end

  table.insert(menuList, {
    text = L:G("Close Menu"),
    notCheckable = true,
    func = function()
      context:Hide()
    end
  })
  enableTooltips(menuList)
  return menuList
end

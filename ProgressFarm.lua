local items = {
  "Mena de cobalto",
  "Mena de saronita",
  "Mena de obsidium",
  "Mena de elementium",
  "Tierra volátil",
  "Fuego volátil",
  "Agua volátil"
}

local trackedItems = {}
local selectedItem = nil
local progressBarCount = 0

local frame = CreateFrame("Frame", "ProgressFarmFrame", UIParent, "BasicFrameTemplateWithInset")
frame:SetSize(300, 250)
frame:SetPoint("TOPLEFT")
frame:Hide()

-- Añade la capacidad de mover el marco
frame:SetMovable(true)
frame:EnableMouse(true)
frame:RegisterForDrag("LeftButton")
frame:SetScript("OnDragStart", frame.StartMoving)
frame:SetScript("OnDragStop", frame.StopMovingOrSizing)

frame.title = frame:CreateFontString(nil, "OVERLAY")
frame.title:SetFontObject("GameFontHighlight")
frame.title:SetPoint("CENTER", frame.TitleBg, "CENTER", 5, 0)
frame.title:SetText("ProgressFarm")

local selectedItemText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
selectedItemText:SetPoint("TOP", frame, "TOP", 0, -40)
selectedItemText:SetText("Selecciona un objeto")

local dropdown = CreateFrame("Frame", nil, frame, "UIDropDownMenuTemplate")
dropdown:SetPoint("TOP", selectedItemText, "BOTTOM", 0, -10)
UIDropDownMenu_SetWidth(dropdown, 150)

local maxInputBox = CreateFrame("EditBox", nil, frame, "InputBoxTemplate")
maxInputBox:SetSize(50, 30)
maxInputBox:SetPoint("TOP", dropdown, "BOTTOM", 0, -10)
maxInputBox:SetNumeric(true)
maxInputBox:SetAutoFocus(false)
maxInputBox:SetText("0")
maxInputBox:Hide()

local farmButton = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
farmButton:SetPoint("TOP", maxInputBox, "BOTTOM", 0, -10)
farmButton:SetSize(140, 40)
farmButton:SetText("Farmear")
farmButton:SetNormalFontObject("GameFontNormalLarge")
farmButton:SetHighlightFontObject("GameFontHighlightLarge")
farmButton:Disable()

local progressBarContainer = _G["progressBarContainer"]
progressBarContainer:SetSize(300, 400)
progressBarContainer:SetPoint("CENTER")
progressBarContainer:Hide()

-- Añadir la capacidad de mover el contenedor
progressBarContainer:SetMovable(true)
progressBarContainer:EnableMouse(true)
progressBarContainer:RegisterForDrag("LeftButton")
progressBarContainer:SetScript("OnDragStart", progressBarContainer.StartMoving)
progressBarContainer:SetScript("OnDragStop", progressBarContainer.StopMovingOrSizing)

local function CreateProgressBar(item, maxCount, index)
  local progressBarPanel = CreateFrame("Frame", nil, progressBarContainer)
  progressBarPanel:SetSize(280, 60)
  progressBarPanel:SetPoint("TOP", 0, -(index * 70) - 10)

  local progressBarName = progressBarPanel:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  progressBarName:SetPoint("TOP", progressBarPanel, "TOP", 0, -10)
  progressBarName:SetText(item)

  local progressBar = CreateFrame("StatusBar", nil, progressBarPanel, "TextStatusBar")
  progressBar:SetSize(200, 20)
  progressBar:SetPoint("TOP", progressBarName, "BOTTOM", 0, -10)
  progressBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
  progressBar:SetStatusBarColor(0, 1, 0) -- Verde
  progressBar:SetMinMaxValues(0, maxCount)
  progressBar:SetValue(0)

  local progressBarBg = progressBar:CreateTexture(nil, "BACKGROUND")
  progressBarBg:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Background")
  progressBarBg:SetAllPoints(true)

  local progressText = progressBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
  progressText:SetFont("Fonts\\FRIZQT__.TTF", 10)
  progressText:SetPoint("CENTER", progressBar)

  local deleteButton = CreateFrame("Button", nil, progressBarPanel, "UIPanelButtonTemplate")
  deleteButton:SetSize(20, 20)
  deleteButton:SetText("-")
  deleteButton:SetPoint("LEFT", progressBar, "RIGHT", 10, 0)

  deleteButton:SetScript("OnClick", function()
    progressBarPanel:Hide()
    trackedItems[item] = nil
    -- Reajustar las posiciones de las barras de progreso
    local newIndex = 0
    for _, panel in pairs(trackedItems) do
      panel:SetPoint("TOP", 0, -(newIndex * 70) - 10)
      newIndex = newIndex + 1
    end
    progressBarCount = newIndex -- Actualizar el contador
  end)

  progressBarPanel:SetScript("OnUpdate", function(self)
    local currentCount = GetItemCount(item)
    progressBar:SetValue(currentCount)
    progressText:SetText(currentCount .. " / " .. maxCount)
    if currentCount >= maxCount then
      self:SetScript("OnUpdate", nil)
      print("¡Has alcanzado el máximo de " .. item .. "!")
    end
  end)

  return progressBarPanel
end

local function ValidateForm()
  if selectedItem and tonumber(maxInputBox:GetText()) and tonumber(maxInputBox:GetText()) > 0 then
    farmButton:Enable()
  else
    farmButton:Disable()
  end
end

local function UpdateDropdown()
  local info = UIDropDownMenu_CreateInfo()
  for _, item in ipairs(items) do
    info.text = item
    info.func = function()
      selectedItem = item
      UIDropDownMenu_SetText(dropdown, item)
      selectedItemText:SetText("Has seleccionado: " .. selectedItem)
      maxInputBox:Show()
      ValidateForm()
    end
    UIDropDownMenu_AddButton(info)
  end
end

UIDropDownMenu_Initialize(dropdown, UpdateDropdown)
UIDropDownMenu_SetText(dropdown, "Seleccionar Objeto")

SLASH_PROGRESSFARM1 = "/farm"
SlashCmdList["PROGRESSFARM"] = function()
  frame:Show()
end

maxInputBox:SetScript("OnTextChanged", ValidateForm)

function frame:Reset()
  selectedItem = nil
  selectedItemText:SetText("")
  maxInputBox:SetText("0")
  maxInputBox:Hide()
  farmButton:Disable()
end

function frame:FarmAccept()
  selectedItem = nil
  selectedItemText:SetText("")
  maxInputBox:SetText("0")
  maxInputBox:Hide()
  farmButton:Disable()
end

farmButton:SetScript("OnClick", function()
  PlaySound(856)
  local maxCount = tonumber(maxInputBox:GetText())
  if not trackedItems[selectedItem] then
    print(progressBarCount) -- Esto imprimirá el número correcto de barras de progreso
    local progressBarPanel = CreateProgressBar(selectedItem, maxCount, progressBarCount)
    trackedItems[selectedItem] = progressBarPanel
    progressBarPanel:Show()
    progressBarCount = progressBarCount + 1 -- Incrementar el contador
  end
  progressBarContainer:Show()
  frame:FarmAccept()
end)

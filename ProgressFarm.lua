local items = {
  "Mena de cobalto",
  "Mena de saronita",
  "Mena de obsidium",
  "Mena de elementium"
}

local selectedItem = nil

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
selectedItemText:SetPoint("TOP", frame, "TOP", 0, -40)  -- Ajusta el punto de anclaje aquí
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

local progressBar = CreateFrame("StatusBar", nil, frame, "TextStatusBar")
progressBar:SetSize(200, 20)
progressBar:SetPoint("TOP", maxInputBox, "BOTTOM", 0, -20)
progressBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
progressBar:SetStatusBarColor(0, 1, 0) -- Verde
progressBar:SetMinMaxValues(0, 1)
progressBar:SetValue(0)
progressBar:Hide()

local progressBarBg = progressBar:CreateTexture(nil, "BACKGROUND")
progressBarBg:SetTexture("Interface\\DialogFrame\\UI-DialogBox-Background")
progressBarBg:SetAllPoints(true)

local progressText = progressBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
progressText:SetFont("Fonts\\FRIZQT__.TTF", 10)
progressText:SetPoint("CENTER", progressBar)

local farmButton = CreateFrame("Button", nil, frame, "GameMenuButtonTemplate")
farmButton:SetPoint("TOP", progressBar, "BOTTOM", 0, -10)
farmButton:SetSize(140, 40)
farmButton:SetText("Farmear")
farmButton:SetNormalFontObject("GameFontNormalLarge")
farmButton:SetHighlightFontObject("GameFontHighlightLarge")
farmButton:Disable()

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
  progressBar:Hide()
  progressBar:SetValue(0)
end

farmButton:SetScript("OnClick", function()
  local maxCount = tonumber(maxInputBox:GetText())
  progressBar:SetMinMaxValues(0, maxCount)
  progressBar:Show()
  local itemCount = GetItemCount(selectedItem)
  progressBar:SetValue(itemCount)
  progressText:SetText(itemCount .. " / " .. maxCount)
  frame:SetScript("OnUpdate", function(self)
    local currentCount = GetItemCount(selectedItem)
    progressBar:SetValue(currentCount)
    progressText:SetText(currentCount .. " / " .. maxCount)
    if currentCount >= maxCount then
      self:SetScript("OnUpdate", nil)
      print("¡Has alcanzado el máximo de " .. selectedItem .. "!")
    end
  end)
end)
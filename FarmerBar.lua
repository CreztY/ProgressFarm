local items = {
  "Mena de cobalto",
  "Mena de saronita"
}

local selectedItem = nil


local frame = CreateFrame("Frame", "ProgressFarmFrame", UIParent, "BasicFrameTemplateWithInset")
frame:SetSize(300, 250)
frame:SetPoint("TOPLEFT")
frame:Hide()

frame.title = frame:CreateFontString(nil, "OVERLAY")
frame.title:SetFontObject("GameFontHighlight")
frame.title:SetPoint("CENTER", frame.TitleBg, "CENTER", 5, 0)
frame.title:SetText("ProgressFarm")

local selectedItemText = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
selectedItemText:SetPoint("TOP", frame, "BOTTOM", 0, -10)
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
progressBar:SetMinMaxValues(0, 1)
progressBar:SetValue(0)
progressBar:Hide()

local progressText = progressBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
progressText:SetPoint("CENTER", progressBar)
progressBar.text = progressText

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

SLASH_FARMERBAR1 = "/farm"
SlashCmdList["FARMERBAR"] = function()
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

local module = {}

local browserBundleIDs = {
  ["com.google.Chrome"] = true,
  ["com.talon-sec.Work"] = true,
}

local function accessibilityLabel(element)
  local labels = {}
  for _, attribute in ipairs({"AXTitle", "AXDescription", "AXHelp", "AXValue"}) do
    local value = element:attributeValue(attribute)
    if type(value) == "string" and value:match("%S") then
      table.insert(labels, value)
    end
  end

  return table.concat(labels, " "):lower()
end

local function browserChromeElements(root)
  local elements = {}

  local function visit(element, depth)
    if depth > 12 or element:attributeValue("AXRole") == "AXWebArea" then
      return
    end

    table.insert(elements, element)
    for _, child in ipairs(element:attributeValue("AXChildren") or {}) do
      visit(child, depth + 1)
    end
  end

  visit(root, 0)
  return elements
end

local function pressFirst(elements, predicate)
  for _, element in ipairs(elements) do
    if predicate(element, accessibilityLabel(element)) then
      local pressed = element:performAction("AXPress")
      if pressed then
        return true
      end
    end
  end

  return false
end

local function isTranslationPopup(window)
  local title = tostring(window:attributeValue("AXTitle") or ""):lower()
  return title == "translate this page?" or title == "translated"
end

local function closeTranslationPopup(application)
  hs.timer.doAfter(0.25, function()
    local appElement = hs.axuielement.applicationElement(application)
    for _, window in ipairs(appElement:attributeValue("AXWindows") or {}) do
      if isTranslationPopup(window) then
        pressFirst(browserChromeElements(window), function(element, label)
          return element:attributeValue("AXRole") == "AXButton" and label == "close"
        end)
        return
      end
    end
  end)
end

local function finishTranslationToggle(application, attemptsRemaining)
  hs.timer.doAfter(0.2, function()
    local appElement = hs.axuielement.applicationElement(application)
    local translateWindow
    for _, window in ipairs(appElement:attributeValue("AXWindows") or {}) do
      if isTranslationPopup(window) then
        translateWindow = window
        break
      end
    end

    if not translateWindow then
      if attemptsRemaining > 1 then
        finishTranslationToggle(application, attemptsRemaining - 1)
      else
        hs.alert.show("Translation unavailable on this page", 1)
      end
      return
    end

    local elements = browserChromeElements(translateWindow)

    if pressFirst(elements, function(element, label)
      local role = element:attributeValue("AXRole")
      return (role == "AXButton" or role == "AXMenuItem")
        and (label:find("show original", 1, true) or label == "original")
    end) then
      closeTranslationPopup(application)
      return
    end

    local languageControls = {}
    for _, element in ipairs(elements) do
      local role = element:attributeValue("AXRole")
      if (role == "AXRadioButton" or role == "AXTab")
        and element:attributeValue("AXEnabled") ~= false then
        table.insert(languageControls, element)
      end
    end

    if #languageControls == 2 then
      for _, element in ipairs(languageControls) do
        if element:attributeValue("AXSelected") == false then
          element:performAction("AXPress")
          closeTranslationPopup(application)
          return
        end
      end
    end

    if pressFirst(elements, function(element, label)
      return element:attributeValue("AXRole") == "AXButton" and label == "translate"
    end) then
      closeTranslationPopup(application)
      return
    end

    hs.alert.show("Translation unavailable on this page", 1)
  end)
end

local function toggleBrowserTranslation()
  local application = hs.application.frontmostApplication()
  local appElement = hs.axuielement.applicationElement(application)
  for _, window in ipairs(appElement:attributeValue("AXWindows") or {}) do
    if isTranslationPopup(window) then
      finishTranslationToggle(application, 8)
      return
    end
  end

  local window = application:focusedWindow()
  if not window then
    hs.alert.show("Chrome window not found", 1)
    return
  end

  local elements = browserChromeElements(hs.axuielement.windowElement(window))
  local translateControl

  for _, element in ipairs(elements) do
    local label = accessibilityLabel(element)
    local role = element:attributeValue("AXRole")
    if role == "AXButton" and label:find("translat", 1, true) then
      translateControl = element
      break
    end
  end

  if translateControl then
    translateControl:performAction("AXPress")
    finishTranslationToggle(application, 8)
    return
  end

  if pressFirst(elements, function(element)
    local description = tostring(element:attributeValue("AXDescription") or ""):lower()
    return element:attributeValue("AXRole") == "AXPopUpButton"
      and (description == "chrome" or description == "prisma browser")
  end) then
    hs.timer.doAfter(0.25, function()
      local menuElements = browserChromeElements(hs.axuielement.applicationElement(application))
      if pressFirst(menuElements, function(element, label)
        return element:attributeValue("AXRole") == "AXMenuItem"
          and label:match("^translate") ~= nil
      end) then
        finishTranslationToggle(application, 8)
      else
        hs.alert.show("Translation unavailable on this page", 1)
      end
    end)
    return
  end

  hs.alert.show("Chrome translation control not found", 1)
end

module.hotkey = hs.hotkey.new({"ctrl"}, "t", toggleBrowserTranslation)

local function updateTranslationHotkey(application)
  if application and browserBundleIDs[application:bundleID()] then
    module.hotkey:enable()
  else
    module.hotkey:disable()
  end
end

module.watcher = hs.application.watcher.new(function(_, eventType, application)
  if eventType == hs.application.watcher.activated then
    updateTranslationHotkey(application)
  end
end):start()

updateTranslationHotkey(hs.application.frontmostApplication())

return module

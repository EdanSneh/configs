local applications = {
  {name = "Cursor", bundleID = "com.todesktop.230313mzl4w4u92"},
  {name = "Prisma", bundleID = "com.talon-sec.Work"},
}

local keyDown = hs.eventtap.event.types.keyDown
local keyboardEventAutorepeat = hs.eventtap.event.properties.keyboardEventAutorepeat
local alertCanvas
local alertTimer

return hs.eventtap.new({keyDown}, function(event)
  local keyCode = event:getKeyCode()
  local direction
  local switchApplication = false
  if keyCode == hs.keycodes.map.right then
    direction = 1
    switchApplication = true
  elseif keyCode == hs.keycodes.map.left then
    direction = -1
    switchApplication = true
  elseif keyCode == hs.keycodes.map.down then
    direction = 1
  elseif keyCode == hs.keycodes.map.up then
    direction = -1
  else
    return false
  end

  local flags = event:getFlags()
  if not flags.ctrl or flags.cmd or flags.alt or flags.shift then
    return false
  end

  local frontmostApplication = hs.application.frontmostApplication()
  local currentBundleID = frontmostApplication and frontmostApplication:bundleID()
  if not switchApplication then
    for _, application in ipairs(applications) do
      if application.bundleID == currentBundleID then
        if event:getProperty(keyboardEventAutorepeat) ~= 1 then
          local modifiers = direction > 0 and {"cmd"} or {"cmd", "shift"}
          hs.eventtap.keyStroke(modifiers, "`", 0)
        end
        return true
      end
    end

    return false
  end

  if event:getProperty(keyboardEventAutorepeat) == 1 then
    return true
  end

  local targetIndex = direction > 0 and 1 or #applications

  for index, application in ipairs(applications) do
    if application.bundleID == currentBundleID then
      targetIndex = ((index - 1 + direction) % #applications) + 1
      break
    end
  end

  local targetApplication = applications[targetIndex]
  if alertTimer then
    alertTimer:stop()
  end
  if alertCanvas then
    alertCanvas:delete()
  end

  local screenFrame = hs.screen.mainScreen():frame()
  local alertWidth = 260
  alertCanvas = hs.canvas.new({
    x = screenFrame.x + (screenFrame.w - alertWidth) / 2,
    y = screenFrame.y + 12,
    w = alertWidth,
    h = 52,
  }):appendElements(
    {
      type = "rectangle",
      action = "fill",
      fillColor = {white = 0.1, alpha = 0.9},
      roundedRectRadii = {xRadius = 14, yRadius = 14},
    },
    {
      type = "text",
      text = "Switching to " .. targetApplication.name,
      textColor = {white = 1},
      textSize = 20,
      textAlignment = "center",
      frame = {x = 8, y = 12, w = alertWidth - 16, h = 28},
    }
  ):level("floating"):behavior({"canJoinAllSpaces", "stationary"}):show()

  alertTimer = hs.timer.doAfter(1, function()
    alertCanvas:delete()
    alertCanvas = nil
    alertTimer = nil
  end)

  hs.application.launchOrFocusByBundleID(targetApplication.bundleID)
  return true
end):start()

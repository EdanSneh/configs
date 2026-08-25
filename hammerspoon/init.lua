-- Map mouse button 3 to cmd+option+ctrl+t (Ghostty toggle_visibility)
local eventTypes = hs.eventtap.event.types
local eventProperties = hs.eventtap.event.properties

local function handleMouseEvent(event)
  local buttonNumber = event:getProperty(eventProperties.mouseEventButtonNumber)
  if buttonNumber == 3 then
    hs.eventtap.keyStroke({"cmd", "alt", "ctrl"}, "t")
    return true, event
  end
  if buttonNumber == 5 or buttonNumber == 4 then
    hs.eventtap.keyStroke({"option"}, "space")
    return true, event
  end

  return false, event
end

-- FIX: Assigned to a global variable (no 'local' keyword) so Lua won't delete it
mouseWatcher = hs.eventtap.new({eventTypes.otherMouseDown}, handleMouseEvent):start()


-- --- Debug: show which mouse button is pressed ---
-- local function showMouseButton(event)
--   local buttonNumber = event:getProperty(eventProperties.mouseEventButtonNumber)
--   hs.alert.show("Mouse Button: " .. tostring(buttonNumber), 0.5)
--   return false, event
-- end
-- eventtap.new({eventTypes.leftMouseDown, eventTypes.rightMouseDown, eventTypes.otherMouseDown}, showMouseButton):start()

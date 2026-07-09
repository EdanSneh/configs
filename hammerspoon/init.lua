-- Map mouse button 3 to cmd+option+ctrl+t (Ghostty toggle_visibility)
local eventtap = hs.eventtap
local eventTypes = hs.eventtap.event.types
local eventProperties = hs.eventtap.event.properties

local function handleMouseEvent(event)
  local buttonNumber = event:getProperty(eventProperties.mouseEventButtonNumber)
  if buttonNumber == 3 then
    hs.eventtap.keyStroke({"cmd", "alt", "ctrl"}, "t")
    return true, event
  end
  return false, event
end

eventtap.new({eventTypes.otherMouseDown}, handleMouseEvent):start()

-- scroll through tabs with CTRL
eventtapMiddleMouseDown = hs.eventtap.new({ hs.eventtap.event.types.scrollWheel }, function(event)
  local scrollUp = event:getProperty(hs.eventtap.event.properties.scrollWheelEventDeltaAxis1) > 0
  if hs.eventtap.checkKeyboardModifiers().ctrl then
      if scrollUp then
        -- print('scroll up')
        hs.eventtap.event.newKeyEvent({"ctrl", "shift"}, "tab", true):post()
      else
        -- print('scroll down')
        hs.eventtap.event.newKeyEvent({"ctrl"}, "tab", true):post()
      end
  end
end)
eventtapMiddleMouseDown:start()

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Left", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  if f.x == max.x and f.y == max.y and f.h == max.h and f.w ~= max.w then
    f.w = max.w
  elseif f.x == max.x and f.h ~= max.h and f.w ~= max.w then
    f.y = max.y
    f.h = max.h
  else
    f.x = max.x
    f.w = max.w / 2
  end

  win:setFrame(f)
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Right", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  if f.x == max.x + math.floor(max.w / 2) and f.y == max.y and f.h == max.h then
    f.x = max.x
    f.w = max.w
  elseif f.x == max.x + math.floor(max.w / 2) and f.h ~= max.h and f.w ~= max.w then
    f.y = max.y
    f.h = max.h
  else
    f.x = max.x + math.floor(max.w / 2)
    f.w = max.w / 2
  end

  win:setFrame(f)
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Up", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  if f.x == max.x and f.y == max.y and f.w == max.w and f.h ~= max.h then
    f.h = max.h
  elseif f.y == max.y and f.h ~= max.h then
    f.x = max.x
    f.w = max.w
  else
    f.y = max.y
    f.h = max.h / 2
  end

  win:setFrame(f)
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "Down", function()
  local win = hs.window.focusedWindow()
  local f = win:frame()
  local screen = win:screen()
  local max = screen:frame()

  if f.x == max.x and f.y == math.floor(max.y / 2) and f.w == max.w then
    f.y = max.y
    f.h = max.h
  elseif f.y == math.floor(max.y / 2) and f.h ~= max.h then
    f.x = max.x
    f.w = max.w
  else
    f.y = max.y + math.floor(max.h / 2)
    f.h = max.h / 2
  end

  win:setFrame(f)
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, ".", function()
  local win = hs.window.focusedWindow()
  win:moveOneScreenEast()
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, ",", function()
  local win = hs.window.focusedWindow()
  win:moveOneScreenWest()
end)

hs.hotkey.bind({"cmd", "alt", "ctrl"}, "/", function()
  local win = hs.window.focusedWindow()
  win:sendToBack()
end)


--

local currentWindowSet = {}
local windowCycler = nil

local wf = hs.window.filter.new(function(win)
    local fw = hs.window.focusedWindow()
    return (
      win:isStandard() and
      win:application() == fw:application()
    )
  end)

local function makeWinCycler(windows)
  local i = 0
  return function()
    local function nextWindow()
      i = i % #windows + 1
      return windows[i]
    end
    local nextWin = nextWindow()
    if nextWin == hs.window.focusedWindow() then
      nextWin = nextWindow()
    end
    return nextWin
  end
end

local function updateWindowCycler()
  if not hs.fnutils.contains(currentWindowSet, hs.window.focusedWindow()) then
    currentWindowSet = wf:getWindows()
    windowCycler = makeWinCycler(currentWindowSet)
  end
end

hs.hotkey.bind({"alt", "shift"}, "tab", function()
    updateWindowCycler()
    windowCycler():focus()
  end)

--


caffeine = hs.menubar.new()
function setCaffeineDisplay(state)
    if state then
        caffeine:setTitle("AWAKE")
    else
        caffeine:setTitle("SLEEPY")
    end
end

function caffeineClicked()
    setCaffeineDisplay(hs.caffeinate.toggle("displayIdle"))
end

if caffeine then
    caffeine:setClickCallback(caffeineClicked)
    setCaffeineDisplay(hs.caffeinate.get("displayIdle"))
end

lockIcon = hs.image.imageFromPath("~/.hammerspoon/icons/lock.png")
lockIcon = lockIcon:setSize({w=18,h=18})

locker = hs.menubar.new()
locker:setIcon(lockIcon)
locker:setClickCallback(hs.caffeinate.startScreensaver)

-- HF week
week = hs.menubar.new()

function setHFWeek(eventType)
    if eventType == hs.caffeinate.watcher.screensDidUnlock then
        -- add two days to get HF week from ISO week
        print('updating week - event type: '..eventType)
        week:setTitle(os.date("%Y-W%V", os.time() + 60*60*24*2))
    else
        print('not updating week - event type: '..eventType)
    end
end

if week then
    week_watcher = hs.caffeinate.watcher.new(setHFWeek):start()
    setHFWeek(hs.caffeinate.watcher.screensDidUnlock)
end


-- auto reloading

function reloadConfig(files)
    doReload = false
    for _, file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        hs.reload()
    end
end
myWatcher = hs.pathwatcher.new("~/.hammerspoon/", reloadConfig):start()
hs.alert.show("Hammerspoon config loaded")

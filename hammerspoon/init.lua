-- Hammerspoon設定

--------------------------------------------------------------------------------
-- MiroWindowsManager（Spectacle代替）
--------------------------------------------------------------------------------
hs.loadSpoon("MiroWindowsManager")

-- キーバインド: Ctrl + Option
spoon.MiroWindowsManager:bindHotkeys({
    up         = {{"ctrl", "alt"}, "up"},
    down       = {{"ctrl", "alt"}, "down"},
    left       = {{"ctrl", "alt"}, "left"},
    right      = {{"ctrl", "alt"}, "right"},
    fullscreen = {{"ctrl", "alt"}, "return"},
    nextscreen = {{"ctrl", "alt"}, "n"},
})

--------------------------------------------------------------------------------
-- 英数入力自動切り替え
--------------------------------------------------------------------------------
-- 特定のアプリに切り替えた時、自動的に英数入力に切り替える

-- 英数入力に切り替えたいアプリのリスト
local englishApps = {
    "Ghostty",
    "Terminal",
    "iTerm2",
    "Warp",
    "Raycast",
    "Zed",
    "Code",
    "Visual Studio Code",
}

-- アプリ切り替え監視
function applicationWatcher(appName, eventType, appObject)
    if eventType == hs.application.watcher.activated then
        for _, name in ipairs(englishApps) do
            if appName == name then
                -- 英数入力に切り替え（日本語環境では "ABC" または "英数"）
                hs.keycodes.setLayout("ABC")
                return
            end
        end
    end
end

appWatcher = hs.application.watcher.new(applicationWatcher)
appWatcher:start()

--------------------------------------------------------------------------------
-- 左右のCommandキー単押しで英数/かなを切り替える
--------------------------------------------------------------------------------
local static_isOtherKeyPressed = false
local static_prevCmdState = false

local commandKeyHandler = hs.eventtap.new({hs.eventtap.event.types.flagsChanged, hs.eventtap.event.types.keyDown}, function(event)
   local eventType = event:getType()
   local flags = event:getFlags()
   local keyCodeNum = event:getKeyCode()

   -- 他のキーが押されたら「単押し」判定を無効化する
   if eventType == hs.eventtap.event.types.keyDown then
      static_isOtherKeyPressed = true
      return false
   end

   -- flagsChanged イベントの処理
   if eventType == hs.eventtap.event.types.flagsChanged then
      -- Commandキーが押された時
      if flags.cmd and not static_prevCmdState then
         static_isOtherKeyPressed = false
         static_prevCmdState = true
      -- Commandキーが離された時
      elseif not flags.cmd and static_prevCmdState then
         if not static_isOtherKeyPressed then
            if keyCodeNum == 55 then -- 左Command
               print("左Command単押し -> 英数")
               hs.eventtap.event.newKeyEvent({}, 102, true):post()
               hs.eventtap.event.newKeyEvent({}, 102, false):post()
            elseif keyCodeNum == 54 then -- 右Command
               print("右Command単押し -> かな")
               hs.eventtap.event.newKeyEvent({}, 104, true):post()
               hs.eventtap.event.newKeyEvent({}, 104, false):post()
            end
         end
         static_prevCmdState = false
         static_isOtherKeyPressed = false
      end
   end
   return false
end)

commandKeyHandler:start()
print("Command key handler started")

-- 設定リロード時の通知
hs.alert.show("Hammerspoon config loaded")

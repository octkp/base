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

-- 設定リロード時の通知
hs.alert.show("Hammerspoon config loaded")

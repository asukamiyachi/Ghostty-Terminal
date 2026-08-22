-- ============================================
-- Terminal Capture
-- Step 5
--
-- Cmd + V
--   -> 今回の開始地点を記録
--
-- Cmd単独
--   ↓
-- 英数
--   ↓
-- Space
--   -> 今回のコマンド群 + 出力をコピー
-- ============================================

local M = {}

local keySequence =
    require("common.key_sequence")

local TERMINAL_BUNDLE_IDS = {
    ["com.apple.Terminal"] = true,
    ["com.mitchellh.ghostty"] = true,
}


M.state = {
    baselineText = nil,
    pastedText = nil,
    armed = false,
}


-- ============================================
-- Terminal判定
-- ============================================

local function frontmostIsTerminal()

    local app =
        hs.application.frontmostApplication()

    if app == nil then
        return false
    end

    return TERMINAL_BUNDLE_IDS[app:bundleID()] == true
end


-- ============================================
-- AX属性取得
-- ============================================

local function safeAttribute(
    element,
    name
)

    if not element then
        return nil
    end


    local ok, value =
        pcall(function()

            return
                element:attributeValue(name)

        end)


    if ok then
        return value
    end


    return nil
end


-- ============================================
-- TerminalのAXツリーから
-- 最大のテキスト領域を取得
-- ============================================

local function findLargestText(
    element,
    depth,
    result
)

    depth = depth or 0

    result =
        result or {
            text = nil,
            length = 0,
        }


    if not element
        or depth > 15
    then

        return result
    end


    local value =
        safeAttribute(
            element,
            "AXValue"
        )


    if type(value) == "string"
        and #value > result.length
    then

        result.text = value
        result.length = #value

    end


    local children =
        safeAttribute(
            element,
            "AXChildren"
        )


    if type(children) == "table" then

        for _, child in ipairs(children) do

            findLargestText(
                child,
                depth + 1,
                result
            )

        end

    end


    return result
end


-- ============================================
-- Terminal全文取得
-- ============================================

function M.readTerminal()

    if not frontmostIsTerminal() then

        return nil,
            "Terminalが前面ではありません"
    end


    local app =
        hs.application.frontmostApplication()


    local root =
        hs.axuielement.applicationElement(
            app
        )


    if not root then

        return nil,
            "Accessibility情報を取得できません"
    end


    local result =
        findLargestText(root)


    if not result.text
        or result.text == ""
    then

        return nil,
            "Terminal本文を取得できません"
    end


    return result.text, nil
end


-- ============================================
-- Cmd+Vの直前を記録
-- ============================================

function M.markPasteStart()

    local text, err =
        M.readTerminal()


    if not text then

        print(
            "[Terminal Capture] "
            .. tostring(err)
        )

        return
    end


    M.state.baselineText =
        text


    M.state.pastedText =
        hs.pasteboard.getContents()


    M.state.armed =
        true


    print(
        "[Terminal Capture] Start recorded"
    )

end


-- ============================================
-- plain text検索
-- 最後の出現位置
-- ============================================

local function findLastPlain(
    text,
    target
)

    if not target
        or target == ""
    then

        return nil
    end


    local last =
        nil


    local start =
        1


    while true do

        local position =
            string.find(
                text,
                target,
                start,
                true
            )


        if not position then
            break
        end


        last =
            position


        start =
            position + 1
    end


    return last
end


-- ============================================
-- 最後の現在プロンプトを除去
--
-- 例:
--
-- miyachiasuka@Mac .hammerspoon %
-- ============================================

local function stripFinalPrompt(text)

    -- 最後の改行を除去
    text =
        text:gsub(
            "[\r\n]+$",
            ""
        )


    local before, lastLine =
        text:match(
            "^(.*)\n([^\n]*)$"
        )


    if not before
        or not lastLine
    then

        return text
    end


    -- UTF-8 NBSPを普通のスペースに変換
    local normalized =
        lastLine:gsub(
            "\194\160",
            " "
        )


    -- username@hostname path %
    -- のようなzshプロンプトだけ除去
    if normalized:match(
        "^[^%s@]+@[^%s]+%s+.-%s+%%[%s]*$"
    )
    then

        return before
    end


    return text
end


-- ============================================
-- 今回分抽出
-- ============================================

function M.extractSession()

    if not M.state.armed then

        return nil,
            "先にTerminalへ⌘Vしてください"
    end


    local current, err =
        M.readTerminal()


    if not current then
        return nil, err
    end


    local baseline =
        M.state.baselineText


    local delta =
        nil


    -- ========================================
    -- 通常ケース
    --
    -- baseline + 新規出力
    -- ========================================

    if baseline
        and current:sub(
            1,
            #baseline
        ) == baseline
    then

        delta =
            current:sub(
                #baseline + 1
            )

    end


    -- ========================================
    -- fallback
    --
    -- 貼り付けたコマンド文字列を
    -- 現在のTerminalから探す
    -- ========================================

    if not delta
        or delta == ""
    then

        local pasted =
            M.state.pastedText


        if type(pasted) == "string"
            and pasted ~= ""
        then

            local position =
                findLastPlain(
                    current,
                    pasted
                )


            if position then

                delta =
                    current:sub(
                        position
                    )

            end

        end

    end


    if not delta
        or delta == ""
    then

        return nil,
            "今回の実行範囲を特定できませんでした"
    end


    delta =
        stripFinalPrompt(delta)


    return delta, nil
end


-- ============================================
-- クリップボードへコピー
-- ============================================

function M.copySession()

    local text, err =
        M.extractSession()


    if not text then

        hs.alert.show(
            tostring(err),
            2
        )

        return
    end


    hs.pasteboard.setContents(
        text
    )


    hs.alert.show(
        "今回のコマンド + 出力をコピー",
        1
    )


    print(
        "[Terminal Capture] Copied "
        .. tostring(#text)
        .. " bytes"
    )

end


-- ============================================
-- Cmd+V監視
-- ============================================

M.pasteWatcher =
    hs.eventtap.new(

        {
            hs.eventtap.event.types.keyDown
        },

        function(event)

            if not frontmostIsTerminal() then
                return false
            end


            local flags =
                event:getFlags()


            local keyCode =
                event:getKeyCode()


            if keyCode ==
                hs.keycodes.map["v"]

                and flags.cmd

                and not flags.ctrl
                and not flags.alt
            then

                M.markPasteStart()

            end


            -- 本来のCmd+Vは通す
            return false
        end
    )


M.pasteWatcher:start()


-- ============================================
-- Cmd → 英数 → Space
-- ============================================

M.copySequence =
    keySequence.new({

        timeout = 1.0,

        condition =
            function()

                return
                    frontmostIsTerminal()

            end,

        action =
            function()

                M.copySession()

            end,
    })


print(
    "Terminal Capture Step 5 loaded"
)

print(
    "Cmd+V -> record start"
)

print(
    "Cmd -> Eisu -> Space -> copy"
)


return M

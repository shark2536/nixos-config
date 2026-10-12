import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland
import Quickshell.Hyprland
import "../components/ui" as UI
import "../lib" as Theme

// Emoji picker: grows out of the bar to a card above the pointer and types straight
// into the focused app (wtype), so a click never touches the clipboard and can be spammed.
//
// The window never takes keyboard focus, which is what keeps the app underneath focused.
// Only the search box asks for it, and hands it back to the app when search ends.
PanelWindow {
    id: win

    // Handed in by shell.qml. Every Bar handle is optional: without it the picker still works.
    property var bar: null
    readonly property var surfaceRef: bar ? bar.barSurface : null
    readonly property var themeRef: bar ? bar.barTheme : null
    readonly property var modesRef: bar ? bar.barModeManager : null
    readonly property var settingsRef: bar ? bar.barSettings : null

    readonly property string wtypeBin: "/run/current-system/sw/bin/wtype"

    // ---- state ----
    property bool shown: false
    property bool searching: false
    property bool hasEntered: false
    property real progress: 0          // 0 = the bar's shape, 1 = the card above the pointer
    property string query: ""
    property int category: 1           // 0 = recent
    property string hoverName: ""
    property string pendingEmoji: ""
    property var savedToplevel: null

    property var allEmoji: []
    property var emojiIndex: ({})
    property var byGroup: [[], [], [], [], [], [], [], [], [], []]
    // `recent` is what the grid shows; `recentDraft` collects clicks. They are merged on close
    // and on tab switch, so the grid never reorders under the pointer while you spam.
    property var recent: []
    property var recentDraft: []

    // ---- geometry (filled in by present()) ----
    property var targetScreen: null
    property real u: 1
    property real pad: 14
    property real startX: 0
    property real startY: 0
    property real startW: 0
    property real startH: 0
    property real startR: 0
    property real endX: 0
    property real endY: 0
    property real endW: 400
    property real endH: 460
    property real endR: 24

    readonly property var tabGlyphs: ["🕘", "😀", "👋", "🐱", "🍔", "✈️", "⚽", "💡", "🔣", "🏁"]

    readonly property color textPrimary: themeRef ? themeRef.textPrimary : Qt.rgba(0.95, 0.93, 0.98, 0.95)
    readonly property color textSecondary: themeRef ? themeRef.textSecondary : Qt.rgba(0.72, 0.72, 0.82, 0.90)
    readonly property color textFaint: themeRef ? themeRef.textFaint : Qt.rgba(0.72, 0.72, 0.82, 0.50)
    readonly property color glow: themeRef ? themeRef.glowPrimary : Qt.rgba(0.65, 0.55, 0.85, 1.0)
    readonly property color inset: themeRef ? themeRef.surfaceInsetCard : Qt.rgba(0, 0, 0, 0.45)
    readonly property color insetHover: themeRef ? themeRef.surfaceInsetCardHover : Qt.rgba(0, 0, 0, 0.65)

    readonly property var shownEmoji: {
        const q = win.query.trim().toLowerCase()
        if (q !== "") {
            const hits = []
            for (const it of win.allEmoji) {
                if (it.k.indexOf(q) >= 0) {
                    hits.push(it)
                    if (hits.length >= 240) break
                }
            }
            return hits
        }
        if (win.category === 0) {
            const items = []
            for (const e of win.recent) {
                const it = win.emojiIndex[e]
                if (it) items.push(it)
            }
            return items
        }
        return win.byGroup[win.category] || []
    }

    // ---- window ----
    screen: win.targetScreen
    anchors.top: true
    anchors.bottom: true
    anchors.left: true
    anchors.right: true
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: win.searching ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    color: "transparent"
    visible: win.shown || win.progress > 0.001
    // Only the card takes input; everything else on the screen stays click-through.
    mask: Region { item: card }

    // A click outside while searching releases the grab, and focus goes where the click went.
    HyprlandFocusGrab {
        windows: [win]
        active: win.searching
        onCleared: win.searching = false
    }

    Connections {
        target: win.modesRef
        ignoreUnknownSignals: true

        function onEmojiToggleRequested() {
            win.toggle()
        }

        function onCurrentModeChanged() {
            if (win.shown && win.modesRef && win.modesRef.currentMode !== "normal") win.close()
        }
    }

    // ---- actions ----
    function toggle() {
        if (win.shown) win.close()
        else win.open()
    }

    function open() {
        if (win.shown || cursorProc.running) return
        if (win.modesRef && win.modesRef.currentMode !== "normal") win.modesRef.closeAllModes()
        win.savedToplevel = ToplevelManager.activeToplevel
        cursorProc.running = true
    }

    function present(pos) {
        const screens = Quickshell.screens
        let scr = (win.bar && win.bar.screen) ? win.bar.screen : (screens.length > 0 ? screens[0] : null)
        if (pos) {
            for (let i = 0; i < screens.length; i++) {
                const s = screens[i]
                if (pos.x >= s.x && pos.x < s.x + s.width && pos.y >= s.y && pos.y < s.y + s.height) {
                    scr = s
                    break
                }
            }
        }
        if (!scr) return

        win.u = Math.max(0.8, Math.min(2.2, scr.width / Theme.Metrics.baseWidth))
        const u = win.u
        win.pad = Math.round(14 * u)
        win.endW = Math.round(392 * u)
        win.endH = Math.round(452 * u)
        win.endR = Math.round(Theme.Motion.radiusPanel * u)

        const lx = pos ? pos.x - scr.x : scr.width / 2
        const ly = pos ? pos.y - scr.y : scr.height / 2
        const margin = Math.round(8 * u)
        const gap = Math.round(16 * u)

        const onBarScreen = win.bar && win.bar.screen === scr && win.modesRef && win.settingsRef
        const barBottom = onBarScreen ? win.modesRef.normalBarSize.height : 0

        let ty = ly - win.endH - gap
        if (ty < barBottom + margin) ty = ly + Math.round(26 * u) + gap   // no room above: go below
        win.endY = Math.max(margin, Math.min(ty, scr.height - win.endH - margin))
        win.endX = Math.max(margin, Math.min(lx - win.endW / 2, scr.width - win.endW - margin))

        if (onBarScreen && !win.bar.barHidden) {
            // The bar's resting shape, so the card appears to leave the bar.
            const n = win.modesRef.normalBarSize
            win.startX = n.leftMargin
            win.startY = n.topMargin
            win.startW = scr.width - n.leftMargin - n.rightMargin
            win.startH = n.height - n.topMargin - n.bottomMargin
            win.startR = Math.min(win.settingsRef.barRadius, Math.min(win.startW, win.startH) / 2)
        } else {
            win.startW = Math.round(48 * u)
            win.startH = Math.round(48 * u)
            win.startX = lx - win.startW / 2
            win.startY = ly - win.startH / 2
            win.startR = win.startW / 2
        }

        anim.stop()
        win.targetScreen = scr
        win.progress = 0
        win.hasEntered = false
        win.hoverName = ""
        win.query = ""
        searchInput.text = ""
        win.recent = win.recentDraft
        win.category = win.recent.length > 0 ? 0 : 1
        win.shown = true
        win.animateTo(1, Theme.Motion.reduced ? 1 : Theme.Motion.dur(1200))
        idleTimer.restart()
    }

    function close() {
        if (!win.shown) return
        if (win.searching) win.endSearch(true)
        win.commitRecent()
        win.shown = false
        idleTimer.stop()
        win.animateTo(0, Theme.Motion.reduced ? 1 : Theme.Motion.dur(700))
    }

    function animateTo(value, ms) {
        anim.stop()
        anim.to = value
        anim.duration = Math.max(1, ms)
        anim.start()
    }

    function beginSearch() {
        if (win.searching || !win.shown) return
        const t = ToplevelManager.activeToplevel
        if (t) win.savedToplevel = t
        win.searching = true
        focusTimer.restart()
    }

    function endSearch(clear) {
        if (clear) {
            win.query = ""
            searchInput.text = ""
        }
        if (!win.searching) return
        win.searching = false
        refocusTimer.restart()
    }

    function typeEmoji(e) {
        idleTimer.restart()
        win.rememberEmoji(e)
        if (win.searching) {
            // The picker still holds focus: give it back to the app first, then type.
            win.pendingEmoji = e
            win.endSearch(false)
            typeTimer.restart()
            return
        }
        Quickshell.execDetached([win.wtypeBin, e])
    }

    function rememberEmoji(e) {
        const next = [e]
        for (const x of win.recentDraft) {
            if (x !== e && next.length < 36) next.push(x)
        }
        win.recentDraft = next
        saveTimer.restart()
    }

    function commitRecent() {
        if (win.recent !== win.recentDraft) win.recent = win.recentDraft
    }

    function selectCategory(index) {
        idleTimer.restart()
        win.commitRecent()
        win.query = ""
        searchInput.text = ""
        win.category = index
        grid.positionViewAtBeginning()
    }

    function loadEmoji(text) {
        let list = []
        try {
            list = JSON.parse(text)
        } catch (e) {
            console.warn("emoji: unreadable data file: " + e)
            return
        }
        const index = {}
        const groups = [[], [], [], [], [], [], [], [], [], []]
        for (const it of list) {
            index[it.e] = it
            if (groups[it.g]) groups[it.g].push(it)
        }
        win.emojiIndex = index
        win.byGroup = groups
        win.allEmoji = list
    }

    function loadRecent(text) {
        try {
            const list = JSON.parse(text)
            if (Array.isArray(list)) {
                win.recentDraft = list.slice(0, 36)
                win.recent = win.recentDraft
            }
        } catch (e) {
        }
    }

    // ---- data ----
    FileView {
        id: dataFile
        path: Quickshell.shellDir + "/data/emoji.json"
        onLoaded: win.loadEmoji(String(dataFile.text()))
    }

    // Same state folder keybinds.lua already uses.
    readonly property string recentPath: {
        const xdg = Quickshell.env("XDG_STATE_HOME")
        const base = (xdg && xdg !== "") ? xdg : (Quickshell.env("HOME") + "/.local/state")
        return base + "/mugen-shell/emoji-recent.json"
    }

    FileView {
        id: recentFile
        path: win.recentPath
        printErrors: false
        onLoaded: win.loadRecent(String(recentFile.text()))
    }

    Timer {
        id: saveTimer
        interval: 700
        onTriggered: recentFile.setText(JSON.stringify(win.recentDraft))
    }

    // hyprctl reports layout-global coordinates, which is what picks the monitor.
    Process {
        id: cursorProc
        command: ["hyprctl", "cursorpos", "-j"]
        stdout: StdioCollector {
            onStreamFinished: {
                let pos = null
                try {
                    const p = JSON.parse(text)
                    if (isFinite(p.x) && isFinite(p.y)) pos = p
                } catch (e) {
                    // Older hyprctl prints "x, y" instead of JSON.
                    const m = String(text).match(/(-?\d+(?:\.\d+)?)\D+(-?\d+(?:\.\d+)?)/)
                    if (m) pos = { x: parseFloat(m[1]), y: parseFloat(m[2]) }
                }
                win.present(pos)
            }
        }
    }

    // ---- timers ----
    NumberAnimation {
        id: anim
        target: win
        property: "progress"
        easing.type: Easing.InOutCubic
    }

    Timer {
        id: focusTimer
        interval: 120
        onTriggered: searchInput.forceActiveFocus()
    }

    Timer {
        id: refocusTimer
        interval: 90
        onTriggered: {
            try {
                if (win.savedToplevel) win.savedToplevel.activate()
            } catch (e) {
                console.warn("emoji: could not refocus the previous window: " + e)
            }
        }
    }

    Timer {
        id: typeTimer
        interval: 220
        onTriggered: {
            if (win.pendingEmoji === "") return
            Quickshell.execDetached([win.wtypeBin, win.pendingEmoji])
            win.pendingEmoji = ""
        }
    }

    Timer {
        id: idleTimer
        interval: (win.settingsRef && win.settingsRef.autoCloseTimerInterval > 0)
            ? Math.max(8000, win.settingsRef.autoCloseTimerInterval) : 30000
        onTriggered: {
            if (win.searching) idleTimer.restart()
            else win.close()
        }
    }

    // Closes shortly after the pointer leaves, but only once it has been over the card.
    Timer {
        id: leaveTimer
        interval: 1200
        running: win.shown && win.hasEntered && !cardHover.hovered && !win.searching
        onTriggered: win.close()
    }

    // ---- card ----
    Item {
        id: card
        x: win.startX + (win.endX - win.startX) * win.progress
        y: win.startY + (win.endY - win.startY) * win.progress
        width: win.startW + (win.endW - win.startW) * win.progress
        height: win.startH + (win.endH - win.startH) * win.progress
        opacity: Math.min(1, win.progress * 5)
        clip: true

        HoverHandler {
            id: cardHover
            onHoveredChanged: {
                if (hovered) win.hasEntered = true
            }
        }

        UI.MugenSurface {
            id: surf
            anchors.fill: parent
            theme: win.themeRef
            baseRadius: win.startR + (win.endR - win.startR) * win.progress
            baseColor: win.surfaceRef ? win.surfaceRef.baseColor : surf.defaultBase
            showBorder: win.surfaceRef ? win.surfaceRef.showBorder : true
        }

        Item {
            id: content
            x: 0
            y: 0
            width: win.endW
            height: win.endH
            opacity: Math.max(0, Math.min(1, (win.progress - 0.55) / 0.4))
            visible: content.opacity > 0

            // search + close
            Rectangle {
                id: searchBox
                x: win.pad
                y: win.pad
                width: content.width - 2 * win.pad
                height: Math.round(38 * win.u)
                radius: Math.round(Theme.Motion.radiusCard * win.u)
                color: win.inset
                border.width: win.searching ? 1 : 0
                border.color: win.glow

                TapHandler {
                    onTapped: win.beginSearch()
                }

                TextInput {
                    id: searchInput
                    anchors.left: parent.left
                    anchors.right: closeButton.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: Math.round(14 * win.u)
                    anchors.rightMargin: Math.round(6 * win.u)
                    color: win.textPrimary
                    font.pixelSize: Math.round(15 * win.u)
                    clip: true
                    onTextEdited: win.query = searchInput.text
                    Keys.onEscapePressed: win.endSearch(true)
                    Keys.onReturnPressed: win.endSearch(false)
                    Keys.onEnterPressed: win.endSearch(false)
                }

                Text {
                    anchors.left: parent.left
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: Math.round(14 * win.u)
                    visible: searchInput.text === ""
                    text: "Cari emoji  (mantap, love, fire…)"
                    color: win.textFaint
                    font.pixelSize: Math.round(14 * win.u)
                }

                Text {
                    id: closeButton
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.rightMargin: Math.round(12 * win.u)
                    text: "✕"
                    color: win.textSecondary
                    opacity: closeHover.hovered ? 1 : 0.6
                    font.pixelSize: Math.round(14 * win.u)

                    Behavior on opacity {
                        NumberAnimation { duration: Theme.Motion.micro }
                    }

                    HoverHandler { id: closeHover }
                    TapHandler {
                        onTapped: win.close()
                    }
                }
            }

            // category tabs
            Row {
                id: tabs
                x: win.pad
                y: searchBox.y + searchBox.height + Math.round(8 * win.u)
                height: Math.round(34 * win.u)
                readonly property real tabWidth: (content.width - 2 * win.pad) / win.tabGlyphs.length

                Repeater {
                    model: win.tabGlyphs

                    delegate: Item {
                        id: tab
                        required property int index
                        required property string modelData
                        readonly property bool active: win.query === "" && win.category === tab.index

                        width: tabs.tabWidth
                        height: tabs.height

                        Text {
                            anchors.centerIn: parent
                            text: tab.modelData
                            font.family: "Noto Color Emoji"
                            font.pixelSize: Math.round(18 * win.u)
                            opacity: tab.active ? 1 : (tabHover.hovered ? 0.85 : 0.5)

                            Behavior on opacity {
                                NumberAnimation { duration: Theme.Motion.micro }
                            }
                        }

                        Rectangle {
                            anchors.horizontalCenter: parent.horizontalCenter
                            anchors.bottom: parent.bottom
                            width: tab.active ? Math.round(18 * win.u) : 0
                            height: Math.max(2, Math.round(2 * win.u))
                            radius: height / 2
                            color: win.glow

                            Behavior on width {
                                NumberAnimation { duration: Theme.Motion.fast; easing.type: Easing.OutCubic }
                            }
                        }

                        HoverHandler { id: tabHover }
                        TapHandler {
                            onTapped: win.selectCategory(tab.index)
                        }
                    }
                }
            }

            // emoji grid
            GridView {
                id: grid
                x: win.pad
                y: tabs.y + tabs.height + Math.round(6 * win.u)
                width: content.width - 2 * win.pad
                height: content.height - grid.y - footer.height - Math.round(14 * win.u)
                cellWidth: grid.width / 8
                cellHeight: Math.round(46 * win.u)
                clip: true
                boundsBehavior: Flickable.StopAtBounds
                model: win.shownEmoji

                delegate: Item {
                    id: cell
                    required property var modelData

                    width: grid.cellWidth
                    height: grid.cellHeight

                    HoverHandler {
                        id: cellHover
                        onHoveredChanged: {
                            if (hovered) win.hoverName = cell.modelData.n
                        }
                    }

                    Rectangle {
                        anchors.fill: parent
                        anchors.margins: Math.round(2 * win.u)
                        radius: Math.round(Theme.Motion.radiusSmall * win.u)
                        color: win.insetHover
                        opacity: cellHover.hovered ? 1 : 0

                        Behavior on opacity {
                            NumberAnimation { duration: Theme.Motion.micro }
                        }
                    }

                    Text {
                        anchors.centerIn: parent
                        text: cell.modelData.e
                        font.family: "Noto Color Emoji"
                        font.pixelSize: Math.round(26 * win.u)
                        scale: cellTap.pressed ? 0.8 : (cellHover.hovered ? 1.2 : 1)

                        Behavior on scale {
                            NumberAnimation { duration: Theme.Motion.micro; easing.type: Easing.OutCubic }
                        }
                    }

                    TapHandler {
                        id: cellTap
                        onTapped: win.typeEmoji(cell.modelData.e)
                    }
                }
            }

            Text {
                anchors.centerIn: grid
                visible: win.shownEmoji.length === 0
                horizontalAlignment: Text.AlignHCenter
                text: win.query !== "" ? "Tidak ada hasil"
                    : (win.category === 0 ? "Belum ada emoji terakhir.\nPakai dulu, nanti muncul di sini." : "")
                color: win.textFaint
                font.pixelSize: Math.round(13 * win.u)
            }

            Text {
                id: footer
                x: win.pad
                y: content.height - footer.height - Math.round(12 * win.u)
                width: content.width - 2 * win.pad
                height: Math.round(18 * win.u)
                elide: Text.ElideRight
                text: win.query !== "" ? (win.shownEmoji.length + " hasil") : win.hoverName
                color: win.textSecondary
                font.pixelSize: Math.round(12 * win.u)
            }
        }
    }
}

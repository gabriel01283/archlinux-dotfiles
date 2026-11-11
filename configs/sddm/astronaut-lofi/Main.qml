import QtQuick 2.15
import QtQuick.Controls 2.15

Rectangle {
    id: root

    width: 1920
    height: 1080
    color: "#100c24"

    property date currentTime: new Date()
    property bool loginPending: false
    property string loginUser: userModel.lastUser || "gabriel"
    property string pendingPower: ""
    property string message: ""
    property bool sessionMenuVisible: false

    Image {
        anchors.fill: parent
        source: "background.png"
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.currentTime = new Date()
    }

    Timer {
        id: powerTimeout
        interval: 7000
        repeat: false
        onTriggered: root.pendingPower = ""
    }

    // ========================================
    // RELÓGIO E DATA
    // ========================================

    Column {
        id: clockGroup

        anchors.left: parent.left
        anchors.leftMargin: root.width * 0.065

        anchors.top: parent.top
        anchors.topMargin: root.height * 0.15

        spacing: 18

        Text {
            text: Qt.formatTime(root.currentTime, "HH:mm")
            color: "#e9b8ed"

            font.family: "Sans"
            font.pixelSize: Math.min(82, root.width * 0.055)
            font.weight: Font.Light
        }

        Text {
            text: {
                var d = root.currentTime
                var days = [
                    "domingo", "segunda-feira", "terça-feira",
                    "quarta-feira", "quinta-feira", "sexta-feira",
                    "sábado"
                ]
                var months = [
                    "janeiro", "fevereiro", "março", "abril",
                    "maio", "junho", "julho", "agosto",
                    "setembro", "outubro", "novembro", "dezembro"
                ]

                return days[d.getDay()] + ", " +
                       d.getDate() + " de " +
                       months[d.getMonth()] + " de " +
                       d.getFullYear()
            }

            color: "#e6c8ec"
            font.family: "Sans"
            font.pixelSize: 16
        }
    }

    // ========================================
    // PAINEL DE LOGIN
    // ========================================

    Rectangle {
        id: panel

        width: 420
        height: 310
        radius: 22

        anchors.right: parent.right
        anchors.rightMargin: root.width * 0.055
        anchors.verticalCenter: parent.verticalCenter

        color: "#bc170e30"

        border.width: 1
        border.color: "#bbd7a5d7"

        // USUÁRIO CENTRALIZADO

        Text {
            id: username

            text: root.loginUser

            anchors.horizontalCenter: parent.horizontalCenter
            y: 26

            width: parent.width - 48
            height: 34

            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter

            color: "#f7e0ff"

            font.family: "Sans"
            font.pixelSize: 24
            font.weight: Font.Light
        }

        // CAMPO DE SENHA

        Rectangle {
            id: passwordBox

            width: parent.width - 48
            height: 50
            radius: 12

            anchors.horizontalCenter: parent.horizontalCenter
            y: 77

            color: "#83130a25"

            border.width: 1
            border.color: password.activeFocus
                          ? "#edb5f4"
                          : "#be89c4"

            TextField {
                id: password

                anchors.left: parent.left
                anchors.right: submitButton.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                anchors.leftMargin: 15

                background: null

                placeholderText: "Senha"
                placeholderTextColor: "#c8b0d3"

                color: "#fff2ff"

                font.family: "Sans"
                font.pixelSize: 16

                echoMode: TextInput.Password

                enabled: !root.loginPending
                focus: true

                onAccepted: root.submitLogin()
            }

            Rectangle {
                id: submitButton

                width: 40
                height: 40
                radius: 10

                anchors.right: parent.right
                anchors.rightMargin: 5
                anchors.verticalCenter: parent.verticalCenter

                color: submitMouse.containsMouse
                       ? "#ad6fbe"
                       : "#704780"

                Text {
                    anchors.centerIn: parent

                    text: "→"
                    color: "#ffffff"
                    font.pixelSize: 23
                }

                MouseArea {
                    id: submitMouse

                    anchors.fill: parent
                    hoverEnabled: true

                    enabled: !root.loginPending

                    onClicked: root.submitLogin()
                }
            }
        }

        // ====================================
        // DIVISÓRIAS E LOGO ARCH
        // ====================================

        Row {
            id: logoRow

            anchors.horizontalCenter: parent.horizontalCenter
            y: 149

            spacing: 14

            Rectangle {
                width: 142
                height: 1
                color: "#b687aecd"
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                width: 36
                height: 40

                text: "󰣇"

                color: "#f4a7ec"

                font.family: "Symbols Nerd Font"
                font.pixelSize: 34

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            Rectangle {
                width: 142
                height: 1
                color: "#b687aecd"
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        // ====================================
        // BOTÕES DE ENERGIA
        // ====================================

        Row {
            id: powerRow
            anchors.horizontalCenter: parent.horizontalCenter
            y: 207
            spacing: 22

            Repeater {
                model: [
                    { "action": "suspend" },
                    { "action": "reboot" },
                    { "action": "poweroff" },
                    { "action": "sessions" }
                ]

                Rectangle {
                    id: powerButton
                    property string actionName: modelData.action
                    width: 54
                    height: 54
                    radius: 12
                    color: controlMouse.containsMouse ? "#9863a9" : "#734273"
                    border.width: 1
                    border.color: "#a66ca8"

                    // Desenho vetorial: o ícone ocupa o centro geométrico do botão.
                    Canvas {
                        id: powerIcon
                        width: 30
                        height: 30
                        anchors.centerIn: parent
                        anchors.verticalCenterOffset: powerButton.actionName === "suspend" ? 2 : 0

                        onPaint: {
                            var c = getContext("2d")
                            c.clearRect(0, 0, width, height)
                            c.strokeStyle = "#f2b2ef"
                            c.fillStyle = "#f2b2ef"
                            c.lineWidth = 2.2
                            c.lineCap = "round"
                            c.lineJoin = "round"

                            if (powerButton.actionName === "suspend") {
                                c.beginPath()
                                c.moveTo(18, 3)
                                c.bezierCurveTo(10, 5, 7, 10, 9, 17)
                                c.bezierCurveTo(11, 23, 18, 24, 22, 20)
                                c.bezierCurveTo(15, 20, 12, 15, 13, 10)
                                c.bezierCurveTo(14, 7, 16, 5, 18, 3)
                                c.closePath()
                                c.fill()
                            } else if (powerButton.actionName === "reboot") {
                                c.beginPath()
                                c.moveTo(24, 15)
                                c.bezierCurveTo(24, 20, 20, 24, 15, 24)
                                c.bezierCurveTo(10, 24, 6, 20, 6, 15)
                                c.bezierCurveTo(6, 10, 10, 6, 15, 6)
                                c.bezierCurveTo(19, 6, 22, 8, 24, 11)
                                c.stroke()
                                c.beginPath()
                                c.moveTo(24, 6)
                                c.lineTo(24, 11)
                                c.lineTo(19, 11)
                                c.stroke()
                            } else if (powerButton.actionName === "poweroff") {
                                c.beginPath()
                                c.arc(15, 16, 9, -0.75, Math.PI + 0.75, false)
                                c.stroke()
                                c.beginPath()
                                c.moveTo(15, 3)
                                c.lineTo(15, 16)
                                c.stroke()
                            } else if (powerButton.actionName === "sessions") {
                                c.beginPath()
                                for (var i = 0; i < 32; i++) {
                                    var a = -Math.PI / 2 + i * Math.PI / 16
                                    var r = (i % 4 === 1 || i % 4 === 2) ? 11.6 : 8.6
                                    var x = 15 + r * Math.cos(a)
                                    var y = 15 + r * Math.sin(a)
                                    if (i === 0) c.moveTo(x, y)
                                    else c.lineTo(x, y)
                                }
                                c.closePath()
                                c.stroke()
                                c.beginPath()
                                c.arc(15, 15, 3.6, 0, Math.PI * 2)
                                c.stroke()
                            }
                        }
                    }

                    MouseArea {
                        id: controlMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (powerButton.actionName === "sessions") {
                                root.sessionMenuVisible = !root.sessionMenuVisible
                                root.pendingPower = ""
                            } else {
                                root.requestPower(powerButton.actionName)
                            }
                        }
                    }
                }
            }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            y: 276

            width: parent.width - 30
            height: 22

            horizontalAlignment: Text.AlignHCenter

            color: "#f6cef0"
            font.family: "Sans"
            font.pixelSize: 12

            elide: Text.ElideRight

            text: root.pendingPower !== ""
                  ? "Clique novamente para " +
                    root.powerLabel(root.pendingPower)
                  : root.message
        }
    }

    // ========================================
    // SELEÇÃO DE SESSÃO
    // ========================================

    ComboBox {
        id: sessions

        model: sessionModel
        textRole: "name"

        currentIndex: Math.max(0, sessionModel.lastIndex)

        visible: root.sessionMenuVisible

        width: panel.width

        anchors.right: panel.right
        anchors.bottom: panel.top
        anchors.bottomMargin: 10

        onActivated: root.sessionMenuVisible = false
    }

    // ========================================
    // FUNÇÕES
    // ========================================

    function powerLabel(action) {
        if (action === "suspend") return "suspender"
        if (action === "reboot") return "reiniciar"
        return "desligar"
    }

    function requestPower(action) {
        if (action === "suspend" && !sddm.canSuspend) { root.message = "Suspensão indisponível"; return }
        if (action === "reboot" && !sddm.canReboot) { root.message = "Reinício indisponível"; return }
        if (action === "poweroff" && !sddm.canPowerOff) { root.message = "Desligamento indisponível"; return }

        if (root.pendingPower !== action) {
            root.pendingPower = action
            root.message = ""
            powerTimeout.restart()
            return
        }

        powerTimeout.stop()
        root.pendingPower = ""

        if (action === "suspend") {
            sddm.suspend()
        } else if (action === "reboot") {
            sddm.reboot()
        } else if (action === "poweroff") {
            sddm.powerOff()
        }
    }

    function submitLogin() {
        if (root.loginPending || password.text.length === 0)
            return

        root.loginPending = true
        root.message = "Entrando..."

        sddm.login(
            root.loginUser,
            password.text,
            sessions.currentIndex
        )
    }

    Connections {
        target: sddm

        function onLoginFailed() {
            root.loginPending = false
            password.text = ""
            root.message = "Senha incorreta"
            password.forceActiveFocus()
        }
    }
}

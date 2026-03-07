import "."
import QtQuick
import SddmComponents
import QtQuick.Effects
import QtMultimedia
import "components"

Item {
    id: root
    state: Config.lockScreenDisplay ? "lockState" : "loginState"

    // TODO: Add own translations: https://github.com/sddm/sddm/wiki/Localization
    property var textConstants: TranslationManager
    property bool capsLockOn: false
    
    // AccountsService integration
    property bool useAccountsServiceBackgrounds: config.boolValue("use-accounts-service-backgrounds")
    
    Component.onCompleted: {
        if (keyboard)
            capsLockOn = keyboard.capsLock;
    }
    onCapsLockOnChanged: {
        loginScreen.updateCapsLock();
    }

    states: [
        State {
            name: "lockState"
            PropertyChanges {
                target: lockScreen
                opacity: 1.0
            }
            PropertyChanges {
                target: loginScreen
                opacity: 0.0
            }
            PropertyChanges {
                target: loginScreen.loginContainer
                scale: 0.5
            }
            PropertyChanges {
                target: backgroundEffect
                blurMax: Config.lockScreenBlur
                brightness: Config.lockScreenBrightness
                saturation: Config.lockScreenSaturation
            }
        },
        State {
            name: "loginState"
            PropertyChanges {
                target: lockScreen
                opacity: 0.0
            }
            PropertyChanges {
                target: loginScreen
                opacity: 1.0
            }
            PropertyChanges {
                target: loginScreen.loginContainer
                scale: 1.0
            }
            PropertyChanges {
                target: backgroundEffect
                blurMax: Config.loginScreenBlur
                brightness: Config.loginScreenBrightness
                saturation: Config.loginScreenSaturation
            }
        }
    ]
    transitions: Transition {
        enabled: Config.enableAnimations
        PropertyAnimation {
            duration: 150
            properties: "opacity"
        }
        PropertyAnimation {
            duration: 400
            properties: "blurMax"
        }
        PropertyAnimation {
            duration: 400
            properties: "brightness"
        }
        PropertyAnimation {
            duration: 400
            properties: "saturation"
        }
    }

    Item {
        id: mainFrame
        property variant geometry: screenModel.geometry(screenModel.primary)
        x: geometry.x
        y: geometry.y
        width: geometry.width
        height: geometry.height

        // Background container with crossfade support
        Item {
            id: backgroundContainer
            anchors.fill: parent
            
            property string currentBackground: ""
            property bool displayColor: root.state === "lockState" && Config.lockScreenUseBackgroundColor || root.state === "loginState" && Config.loginScreenUseBackgroundColor
            property bool frontLayerActive: true
            
            // Fallback color background
            Rectangle {
                id: backgroundColor
                anchors.fill: parent
                z: -10
                color: root.state === "lockState" && Config.lockScreenUseBackgroundColor ? Config.lockScreenBackgroundColor : root.state === "loginState" && Config.loginScreenUseBackgroundColor ? Config.loginScreenBackgroundColor : "black"
                visible: parent.displayColor
            }
            
            // Background layer A (back layer, z: 0)
            Image {
                id: backgroundImageA
                anchors.fill: parent
                cache: false
                mipmap: true
                opacity: 1.0
                z: 0
                
                fillMode: {
                    if (Config.backgroundFillMode === "stretch") {
                        return Image.Stretch;
                    } else if (Config.backgroundFillMode === "fit") {
                        return Image.PreserveAspectFit;
                    } else {
                        return Image.PreserveAspectCrop;
                    }
                }
                
                Behavior on opacity {
                    enabled: Config.enableAnimations
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.InOutQuad
                    }
                }
            }
            
            // Background layer B (front layer, z: 1)
            Image {
                id: backgroundImageB
                anchors.fill: parent
                cache: false
                mipmap: true
                opacity: 0.0
                z: 1
                
                fillMode: {
                    if (Config.backgroundFillMode === "stretch") {
                        return Image.Stretch;
                    } else if (Config.backgroundFillMode === "fit") {
                        return Image.PreserveAspectFit;
                    } else {
                        return Image.PreserveAspectCrop;
                    }
                }
                
                Behavior on opacity {
                    enabled: Config.enableAnimations
                    NumberAnimation {
                        duration: 400
                        easing.type: Easing.InOutQuad
                    }
                }
            }
            
            function getCurrentBackground() {
                // Use AccountsService background if available and enabled
                if (root.useAccountsServiceBackgrounds && loginScreen.userName) {
                    var userBg = AccountsService.getUserBackground(loginScreen.userName)
                    if (userBg && userBg.length > 0) {
                        return userBg
                    }
                }
                
                // Fallback to configured backgrounds
                return root.state === "lockState" ? Config.lockScreenBackground : Config.loginScreenBackground
            }
            
            function resolveSource(path) {
                if (!path || path.length === 0)
                    return "";

                // Absolute filesystem path
                if (path.startsWith("/"))
                    return "file://" + path;

                // Already a file URL
                if (path.startsWith("file://"))
                    return path;

                // Relative → theme backgrounds dir
                return "backgrounds/" + path;
            }
            
            function switchBackground(newBg) {
                var newSource = resolveSource(newBg)
                var currentSource = frontLayerActive ? backgroundImageA.source.toString() : backgroundImageB.source.toString()
                
                if (newSource === currentSource) {
                    return
                }
                
                if (frontLayerActive) {
                    // A is visible, crossfade to B
                    backgroundImageB.source = newSource
                    backgroundImageB.opacity = 1.0
                    backgroundImageA.opacity = 0.0
                    frontLayerActive = false
                } else {
                    // B is visible, crossfade to A
                    backgroundImageA.source = newSource
                    backgroundImageA.opacity = 1.0
                    backgroundImageB.opacity = 0.0
                    frontLayerActive = true
                }
            }
            
            Component.onCompleted: {
                var initialBg = getCurrentBackground()
                currentBackground = initialBg
                var initialSource = resolveSource(initialBg)
                
                backgroundImageA.source = initialSource
                backgroundImageA.opacity = 1.0
                backgroundImageB.opacity = 0.0
                frontLayerActive = true
            }
            
            Connections {
                target: loginScreen
                function onUserNameChanged() {
                    var newBg = backgroundContainer.getCurrentBackground()
                    if (newBg !== backgroundContainer.currentBackground) {
                        backgroundContainer.currentBackground = newBg
                        backgroundContainer.switchBackground(newBg)
                    }
                }
            }
        }
        
        // Apply effects to the entire background container
        MultiEffect {
            id: backgroundEffect
            source: backgroundContainer
            anchors.fill: parent
            blurEnabled: backgroundContainer.visible && blurMax > 0
            blur: blurMax > 0 ? 1.0 : 0.0
            autoPaddingEnabled: false
        }

        Item {
            id: screenContainer
            anchors.fill: parent
            anchors.top: parent.top

            LockScreen {
                id: lockScreen
                z: root.state === "lockState" ? 2 : 1
                anchors.fill: parent
                focus: root.state === "lockState"
                enabled: root.state === "lockState"
                onLoginRequested: {
                    root.state = "loginState";
                    loginScreen.safeStateChange("normal");
                    focusRetryTimer.retryCount = 0;
                    focusRetryTimer.start();
                }
            }

            Timer {
                id: focusRetryTimer
                interval: 50
                repeat: true
                property int retryCount: 0
                property int maxRetries: 20

                onTriggered: {
                    retryCount++;

                    loginScreen.resetFocus();

                    var focusReached = false;
                    if (loginScreen.userNeedsPassword) {
                        focusReached = loginScreen.password.input.activeFocus;
                    } else {
                        focusReached = loginScreen.loginButton.activeFocus;
                    }

                    if (focusReached || retryCount >= maxRetries) {
                        stop();
                    }
                }
            }

            LoginScreen {
                id: loginScreen
                z: root.state === "loginState" ? 2 : 1
                anchors.fill: parent
                enabled: root.state === "loginState"
                opacity: 0.0
                onClose: {
                    root.state = "lockState";
                }
            }
        }
    }
}

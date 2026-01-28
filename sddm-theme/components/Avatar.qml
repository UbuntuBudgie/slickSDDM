import QtQuick
import QtQuick.Effects
import QtQuick.Controls

Rectangle {
    id: avatar
    property string shape: Config.avatarShape
    property string source: ""
    property string username: ""
    property bool active: false
    property int squareRadius: (shape == "circle") ? this.width : (Config.avatarBorderRadius === 0 ? 1 : Config.avatarBorderRadius * Config.generalScale)
    property bool drawStroke: (active && Config.avatarActiveBorderSize > 0) || (!active && Config.avatarInactiveBorderSize > 0)
    property color strokeColor: active ? Config.avatarActiveBorderColor : Config.avatarInactiveBorderColor
    property int strokeSize: active ? (Config.avatarActiveBorderSize * Config.generalScale) : (Config.avatarInactiveBorderSize * Config.generalScale)
    property string tooltipText: ""
    property bool showTooltip: false
    
    property string fallbackAvatar: ""
    property bool useFallback: false
    property bool checkedForFallback: false

    signal clicked
    signal clickedOutside

    radius: squareRadius
    color: "transparent"
    antialiasing: true

    // Function to check if the source is SDDM's default avatar
    function isDefaultSDDMAvatar(sourcePath) {
        if (!sourcePath || sourcePath.length === 0) return true;
        
        var path = sourcePath.toString();
        
        // SDDM's common default avatar paths
        var defaultPaths = [
            "/usr/share/sddm/faces/.face.icon",
            "/usr/share/pixmaps/faces/.face.icon",
            "/.face.icon",
            ".face.icon"
        ];
        
        for (var i = 0; i < defaultPaths.length; i++) {
            if (path.indexOf(defaultPaths[i]) !== -1) {
                return true;
            }
        }
        
        return false;
    }

    // Function to get a consistent fallback avatar based on username
    function getFallbackAvatar(username) {
        if (!username || username.length === 0) {
            return Config.getIcon("user-default");
        }
        
        // Generate a hash from username for consistent avatar selection
        var hash = 0;
        for (var i = 0; i < username.length; i++) {
            hash = ((hash << 5) - hash) + username.charCodeAt(i);
            hash = hash & hash;
        }
        hash = Math.abs(hash);
        
        // Use absolute paths to avoid resolution issues
        var faceFiles = [
            "file:///usr/share/sddm/themes/ubuntu-budgie-login/faces/face-1.png",
            "file:///usr/share/sddm/themes/ubuntu-budgie-login/faces/face-2.png",
            "file:///usr/share/sddm/themes/ubuntu-budgie-login/faces/face-3.png",
            "file:///usr/share/sddm/themes/ubuntu-budgie-login/faces/face-4.png",
            "file:///usr/share/sddm/themes/ubuntu-budgie-login/faces/face-5.png",
            "file:///usr/share/sddm/themes/ubuntu-budgie-login/faces/face-6.png",
            "file:///usr/share/sddm/themes/ubuntu-budgie-login/faces/face-7.png",
            "file:///usr/share/sddm/themes/ubuntu-budgie-login/faces/face-8.png",
            "file:///usr/share/sddm/themes/ubuntu-budgie-login/faces/face-9.png",
            "file:///usr/share/sddm/themes/ubuntu-budgie-login/faces/face-10.png",
            "file:///usr/share/sddm/themes/ubuntu-budgie-login/faces/face-11.png",
            "file:///usr/share/sddm/themes/ubuntu-budgie-login/faces/face-12.png",
            "file:///usr/share/sddm/themes/ubuntu-budgie-login/faces/face-13.png",
            "file:///usr/share/sddm/themes/ubuntu-budgie-login/faces/face-14.png",
            "file:///usr/share/sddm/themes/ubuntu-budgie-login/faces/face-15.png"
        ];
        
        var selectedIndex = hash % faceFiles.length;
        return faceFiles[selectedIndex];
    }

    // Timer to check and replace default avatar after initial load
    Timer {
        interval: 50
        running: true
        repeat: false
        onTriggered: {
            if (!avatar.checkedForFallback && avatar.username) {
                avatar.checkedForFallback = true;
                
                // Check if we should use a fallback avatar
                if (isDefaultSDDMAvatar(faceImage.source)) {
                    avatar.fallbackAvatar = avatar.getFallbackAvatar(avatar.username);
                    avatar.useFallback = true;
                    faceImage.source = avatar.fallbackAvatar;
                }
            }
        }
    }

    // Background
    Rectangle {
        anchors.fill: parent
        radius: avatar.squareRadius
        color: Config.passwordInputBackgroundColor
        opacity: Config.passwordInputBackgroundOpacity
        visible: true
    }

    Image {
        id: faceImage
        source: parent.source
        anchors.fill: parent
        mipmap: true
        antialiasing: true
        visible: false
        smooth: true

        fillMode: Image.PreserveAspectCrop
        horizontalAlignment: Image.AlignHCenter
        verticalAlignment: Image.AlignVCenter

        onStatusChanged: {
            if (status === Image.Error) {
                // If image fails to load, try fallback
                if (!avatar.useFallback && avatar.username) {
                    avatar.fallbackAvatar = avatar.getFallbackAvatar(avatar.username);
                    avatar.useFallback = true;
                    source = avatar.fallbackAvatar;
                } else {
                    // If fallback also fails, use the default icon
                    source = Config.getIcon("user-default");
                    faceEffects.colorization = 1;
                }
            } else if (status === Image.Ready) {
                // Image loaded successfully
                faceEffects.colorization = 0;
            }
        }

        // Border
        Rectangle {
            anchors.fill: parent
            radius: avatar.squareRadius
            color: "transparent"
            border.width: avatar.strokeSize
            border.color: avatar.strokeColor
            antialiasing: true
        }
    }
    
    MultiEffect {
        id: faceEffects
        anchors.fill: faceImage
        source: faceImage
        antialiasing: true
        maskEnabled: true
        maskSource: faceImageMask
        maskSpreadAtMin: 1.0
        maskThresholdMax: 1.0
        maskThresholdMin: 0.5
        colorization: 0
        colorizationColor: avatar.strokeColor === Config.passwordInputBackgroundColor && (1.0 - Config.passwordInputBackgroundOpacity < 0.3) ? Config.passwordInputContentColor : avatar.strokeColor
    }

    Item {
        id: faceImageMask

        height: this.width
        layer.enabled: true
        layer.smooth: true
        visible: false
        width: faceImage.width

        Rectangle {
            height: this.width
            radius: avatar.squareRadius
            width: faceImage.width
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.ArrowCursor

        function isCursorInsideAvatar() {
            if (avatar.shape === "square")
                return true;

            // Ellipse center and radius
            var centerX = width / 2;
            var centerY = height / 2;
            var radiusX = centerX;
            var radiusY = centerY;

            // Distance from center
            var dx = (mouseArea.mouseX - centerX) / radiusX;
            var dy = (mouseArea.mouseY - centerY) / radiusY;

            // Check if pointer is inside the ellipse
            return (dx * dx + dy * dy) <= 1.0;
        }

        // Handle both clicked (for tap-to-click) and released (for traditional clicks)
        onClicked: function (mouse) {
            var isInside = isCursorInsideAvatar();
            if (isInside) {
                avatar.clicked();
            } else {
                avatar.clickedOutside();
            }
            mouse.accepted = isInside;
        }

        function updateHover() {
            if (isCursorInsideAvatar()) {
                cursorShape = Qt.PointingHandCursor;
            } else {
                cursorShape = Qt.ArrowCursor;
            }
        }

        onMouseXChanged: updateHover()
        onMouseYChanged: updateHover()

        ToolTip {
            parent: mouseArea
            enabled: Config.tooltipsEnable && !Config.tooltipsDisableUser && avatar.enabled
            property bool shouldShow: enabled && (avatar.showTooltip || (mouseArea.containsMouse && mouseArea.isCursorInsideAvatar() && avatar.tooltipText !== ""))
            visible: shouldShow && loginScreen && loginScreen.opacity > 0
            delay: 300
            contentItem: Text {
                font.family: Config.tooltipsFontFamily
                font.pixelSize: Config.tooltipsFontSize * Config.generalScale
                text: avatar.tooltipText
                color: Config.tooltipsContentColor
            }
            background: Rectangle {
                color: Config.tooltipsBackgroundColor
                opacity: Config.tooltipsBackgroundOpacity
                border.width: 0
                radius: Config.tooltipsBorderRadius * Config.generalScale
            }
        }
    }
}

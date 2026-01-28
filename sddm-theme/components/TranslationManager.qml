pragma Singleton

import QtQuick

QtObject {
    id: translationManager
    
    // Qt translation system - uses qsTr() for translatable strings
    // Translations are loaded automatically by SDDM from .qm files in translations/
    
    // Basic strings
    readonly property string pressAnyKey: qsTr("Press any key")
    readonly property string username: qsTr("Username")
    readonly property string password: qsTr("Password")
    readonly property string login: qsTr("Login")
    readonly property string loggingIn: qsTr("Logging in")
    readonly property string loginFailed: qsTr("Login failed")
    readonly property string promptUser: qsTr("Enter your username")
    readonly property string capslockWarning: qsTr("Caps Lock is on")
    
    // Power menu
    readonly property string suspend: qsTr("Suspend")
    readonly property string reboot: qsTr("Reboot")
    readonly property string shutdown: qsTr("Shutdown")
    
    // Tooltips and UI
    readonly property string changeSession: qsTr("Change session")
    readonly property string changeKeyboardLayout: qsTr("Change keyboard layout")
    readonly property string toggleVirtualKeyboard: qsTr("Toggle virtual keyboard")
    readonly property string powerOptions: qsTr("Power options")
    readonly property string closeUserSelection: qsTr("Close user selection")
    readonly property string selectUser: qsTr("Select user")
    
    // Error messages
    readonly property string noKeyboardLayoutsConfigured: qsTr("No keyboard layouts configured. Please configure layouts in /etc/sddm.conf.d/*.conf")
    readonly property string noUsersFound: qsTr("SDDM could not find any user. Type your username below:")
    
    // Parameterized strings
    // Use .arg() for string substitution in translations
    function selectUserNamed(name) {
        return qsTr("Select user %1").arg(name)
    }
}

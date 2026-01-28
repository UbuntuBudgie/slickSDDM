pragma Singleton

import QtQuick

QtObject {
    // This is a compatibility wrapper that redirects to TranslationManager
    readonly property string pressAnyKey: TranslationManager.pressAnyKey
    readonly property string username: TranslationManager.username
    readonly property string password: TranslationManager.password
    readonly property string login: TranslationManager.login
    readonly property string loggingIn: TranslationManager.loggingIn
    readonly property string loginFailed: TranslationManager.loginFailed
    readonly property string promptUser: TranslationManager.promptUser
    readonly property string capslockWarning: TranslationManager.capslockWarning
    readonly property string suspend: TranslationManager.suspend
    readonly property string reboot: TranslationManager.reboot
    readonly property string shutdown: TranslationManager.shutdown
}

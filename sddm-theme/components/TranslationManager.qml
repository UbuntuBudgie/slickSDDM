pragma Singleton

import QtQuick

QtObject {
    id: translationManager
    
    property string currentLocale: Qt.locale().name.substring(0, 2)
    property var translations: ({})
    property bool loaded: false
    
    Component.onCompleted: {
        loadTranslations()
    }
    
    function loadTranslations() {
        // Try to load the translation file for current locale
        var xhr = new XMLHttpRequest()
        var url = Qt.resolvedUrl("../translations/" + currentLocale + ".json")
        
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        translations[currentLocale] = JSON.parse(xhr.responseText)
                        loaded = true
                        console.log("Loaded translations for locale:", currentLocale)
                    } catch (e) {
                        console.error("Failed to parse translation file for", currentLocale, ":", e)
                        // Try loading English as ultimate fallback
                        loadEnglishFallback()
                    }
                } else {
                    console.log("Translation file not found for locale:", currentLocale)
                    // Try loading English as ultimate fallback
                    loadEnglishFallback()
                }
            }
        }
        
        xhr.open("GET", url)
        xhr.send()
    }
    
    function loadEnglishFallback() {
        // If user's locale isn't available, try to load English
        if (currentLocale === "en") {
            console.warn("English translation file not found - using hardcoded fallbacks")
            loaded = true
            return
        }
        
        var xhr = new XMLHttpRequest()
        var url = Qt.resolvedUrl("../translations/en.json")
        
        xhr.onreadystatechange = function() {
            if (xhr.readyState === XMLHttpRequest.DONE) {
                if (xhr.status === 200) {
                    try {
                        translations["en"] = JSON.parse(xhr.responseText)
                        currentLocale = "en"
                        loaded = true
                        console.log("Using English translations as fallback")
                    } catch (e) {
                        console.error("Failed to parse English translation file:", e)
                        loaded = true
                    }
                } else {
                    console.warn("English translation file not found - using hardcoded fallbacks")
                    loaded = true
                }
            }
        }
        
        xhr.open("GET", url)
        xhr.send()
    }
    
    function tr(key, fallback) {
        if (translations[currentLocale] && translations[currentLocale][key]) {
            return translations[currentLocale][key]
        }
        return fallback || key
    }
    
    function trWith(key, fallback, replacements) {
        var text = tr(key, fallback)
        if (replacements) {
            for (var key in replacements) {
                text = text.replace("{" + key + "}", replacements[key])
            }
        }
        return text
    }
    
    // Pre-defined translations
    readonly property string pressAnyKey: tr("pressAnyKey", "Press any key")
    readonly property string username: tr("username", "Username")
    readonly property string password: tr("password", "Password")
    readonly property string login: tr("login", "Login")
    readonly property string loggingIn: tr("loggingIn", "Logging in")
    readonly property string loginFailed: tr("loginFailed", "Login failed")
    readonly property string promptUser: tr("promptUser", "Enter your username")
    readonly property string capslockWarning: tr("capslockWarning", "Caps Lock is on")
    readonly property string suspend: tr("suspend", "Suspend")
    readonly property string reboot: tr("reboot", "Reboot")
    readonly property string shutdown: tr("shutdown", "Shutdown")
    readonly property string changeSession: tr("changeSession", "Change session")
    readonly property string changeKeyboardLayout: tr("changeKeyboardLayout", "Change keyboard layout")
    readonly property string toggleVirtualKeyboard: tr("toggleVirtualKeyboard", "Toggle virtual keyboard")
    readonly property string powerOptions: tr("powerOptions", "Power options")
    readonly property string closeUserSelection: tr("closeUserSelection", "Close user selection")
    readonly property string selectUser: tr("selectUser", "Select user")
    readonly property string noKeyboardLayoutsConfigured: tr("noKeyboardLayoutsConfigured", "No keyboard layouts configured. Please configure layouts in /etc/sddm.conf.d/*.conf")
    readonly property string noUsersFound: tr("noUsersFound", "SDDM could not find any user. Type your username below:")
    
    // Helper for parameterized strings
    function selectUserNamed(name) {
        return trWith("selectUserNamed", "Select user {name}", {"name": name})
    }
}

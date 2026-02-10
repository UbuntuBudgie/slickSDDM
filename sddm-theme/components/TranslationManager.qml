pragma Singleton

import QtQuick

QtObject {
    id: translationManager
    
    // Embedded translations for SDDM
    // Since SDDM cannot load external .qm files, all translations are embedded here
    // and selected based on Qt.locale().name at runtime
    
    readonly property string currentLocale: Qt.locale().name
    
    // All translations embedded
    readonly property var translations: ({
        'ca': {
            'capslockWarning': "El blocatge de majúscules està activat.",
            'changeKeyboardLayout': "Canvia la disposició del teclat.",
            'changeSession': "Canvia de sessió",
            'closeUserSelection': "Tanca la selecció d'usuari.",
            'loggingIn': "S'entra a la sessió",
            'login': "Entrada",
            'loginFailed': "Ha fallat entrar a la sessió.",
            'noKeyboardLayoutsConfigured': "No hi ha cap disposició de teclat configurada. Establiu les disposicions a /etc/sddm.conf.d/*.conf",
            'noUsersFound': "L'SDDM no ha pogut trobar cap usuari. Escriviu el nom d'usuari a continuació:",
            'password': "Contrasenya",
            'powerOptions': "Opcions d'energia",
            'pressAnyKey': "Premeu qualsevol tecla.",
            'promptUser': "Escriviu el nom d'usuari",
            'reboot': "Reinicia't",
            'selectUser': "Seleccioneu l'usuari",
            'selectUserNamed': "Selecciona l'usuari {name}",
            'shutdown': "Atura't",
            'suspend': "Suspèn-te",
            'toggleVirtualKeyboard': "Activa / desactiva el teclat virtual",
            'username': "Nom d'usuari",
        },
        'de_DE': {
            'capslockWarning': "Feststelltaste ist aktiviert",
            'changeKeyboardLayout': "Tastaturbelegung ändern",
            'changeSession': "Sitzung ändern",
            'closeUserSelection': "Benutzerauswahl schließen",
            'loggingIn': "Anmeldung läuft",
            'login': "Anmelden",
            'loginFailed': "Anmeldung fehlgeschlagen",
            'noKeyboardLayoutsConfigured': "Keine Tastaturbelegungen konfiguriert. Bitte konfigurieren Sie Layouts in /etc/sddm.conf.d/*.conf",
            'noUsersFound': "SDDM konnte keinen Benutzer finden. Geben Sie unten Ihren Benutzernamen ein:",
            'password': "Passwort",
            'powerOptions': "Energieoptionen",
            'pressAnyKey': "Drücken Sie eine beliebige Taste",
            'promptUser': "Geben Sie Ihren Benutzernamen ein",
            'reboot': "Neu starten",
            'selectUser': "Benutzer auswählen",
            'selectUserNamed': "Benutzer {name} auswählen",
            'shutdown': "Herunterfahren",
            'suspend': "Bereitschaft",
            'toggleVirtualKeyboard': "Virtuelle Tastatur umschalten",
            'username': "Benutzername",
        },
        'en': {
            'capslockWarning': "Capslock Warning",
            'closeUserSelection': "Close User Selection",
            'loggingIn': "Logging In",
            'login': "Login",
            'loginFailed': "Login Failed",
            'noKeyboardLayoutsConfigured': "No Keyboard Layouts Configured",
            'password': "Password",
            'pressAnyKey': "Press Any Key",
            'promptUser': "Prompt User",
            'reboot': "Reboot",
            'selectUser': "Select User",
            'shutdown': "Shutdown",
            'suspend': "Suspend",
            'username': "Username",
        },
        'en_GB': {
            'capslockWarning': "Caps Lock is on",
            'changeKeyboardLayout': "Change keyboard layout",
            'changeSession': "Change session",
            'closeUserSelection': "Close user selection",
            'loggingIn': "Logging in",
            'login': "Login",
            'loginFailed': "Login failed",
            'noKeyboardLayoutsConfigured': "No keyboard layouts configured. Please configure layouts in /etc/sddm.conf.d/*.conf",
            'noUsersFound': "SDDM could not find any user. Type your username below:",
            'password': "Password",
            'powerOptions': "Power options",
            'pressAnyKey': "Press any key",
            'promptUser': "Enter your username",
            'reboot': "Reboot",
            'selectUser': "Select user",
            'selectUserNamed': "Select user {name}",
            'shutdown': "Shutdown",
            'suspend': "Suspend",
            'toggleVirtualKeyboard': "Toggle virtual keyboard",
            'username': "Username",
        },
        'es': {
            'capslockWarning': "Bloq Mayús está activado",
            'changeKeyboardLayout': "Cambiar distribución de teclado",
            'changeSession': "Cambiar sesión",
            'closeUserSelection': "Cerrar selección de usuario",
            'loggingIn': "Iniciando sesión",
            'login': "Acceder",
            'loginFailed': "Error al iniciar sesión",
            'noKeyboardLayoutsConfigured': "No hay distribuciones de teclado configuradas. Configure las distribuciones en /etc/sddm.conf.d/*.conf",
            'noUsersFound': "SDDM no pudo encontrar ningún usuario. Escriba su nombre de usuario a continuación:",
            'password': "Contraseña",
            'powerOptions': "Opciones de energía",
            'pressAnyKey': "Presione cualquier tecla",
            'promptUser': "Ingrese su nombre de usuario",
            'reboot': "Reiniciar",
            'selectUser': "Seleccionar usuario",
            'selectUserNamed': "Seleccionar usuario {name}",
            'shutdown': "Apagar",
            'suspend': "Suspender",
            'toggleVirtualKeyboard': "Alternar teclado virtual",
            'username': "Usuario",
        },
        'et': {
            'capslockWarning': "Caps Lock (suurtähtede lukustus) on lülitatud sisse",
            'changeKeyboardLayout': "Vaheta klahvistiku paigutust",
            'changeSession': "Vaheta sessiooni",
            'closeUserSelection': "Sulge kasutaja valik",
            'loggingIn': "Sisselogimisel",
            'login': "Logi sisse",
            'loginFailed': "Sisselogimine ei õnnestunud",
            'noKeyboardLayoutsConfigured': "Ühtegi klahvistikupaigutust pole seadistatud. Palun seadista nad siin: /etc/sddm.conf.d/*.conf",
            'noUsersFound': "SDDM ei leidnud ühtegi kasutajat. Palun sisesta kasutajanimi alljärgnevalt:",
            'password': "Salasõna",
            'powerOptions': "Toitevalikud",
            'pressAnyKey': "Vajuta suvalist klahvi",
            'promptUser': "Sisesta oma kasutajanimi",
            'reboot': "Taaskäivita",
            'selectUser': "Vali kasutaja",
            'selectUserNamed': "Vali kasutaja {name}",
            'shutdown': "Seiska",
            'suspend': "Peata",
            'toggleVirtualKeyboard': "Lülita virtuaalne klahvistik sisse/välja",
            'username': "Kasutajanimi",
        },
        'fi': {
            'capslockWarning': "Caps Lock on päällä",
            'changeKeyboardLayout': "Vaihda näppäimistöasettelua",
            'changeSession': "Vaihda istuntoa",
            'closeUserSelection': "Sulje käyttäjän valinta",
            'loggingIn': "Kirjautuminen sisään ",
            'login': "Kirjaudu",
            'loginFailed': "Kirjautuminen epäonnistui",
            'noKeyboardLayoutsConfigured': "Ei määritettyjä näppäimistöasetteluja. Määritä asettelut tiedostossa /etc/sddm.conf.d/*.conf.",
            'noUsersFound': "SDDM ei löytänyt käyttäjiä. Kirjoita käyttäjätunnuksesi alle:",
            'password': "Salasana",
            'powerOptions': "Virtavaihtoehdot",
            'pressAnyKey': "Paina mitä tahansa näppäintä",
            'promptUser': "Syötä käyttäjätunnuksesi",
            'reboot': "Käynnistä uudelleen",
            'selectUser': "Valitse käyttäjä",
            'selectUserNamed': "Valitse käyttäjän {nimi}",
            'shutdown': "Sammuta",
            'suspend': "Keskeyttää",
            'toggleVirtualKeyboard': "Virtuaalinäppäimistö päälle/pois",
            'username': "Käyttäjän nimi",
        },
        'fr': {
            'capslockWarning': "Verr Maj est activé",
            'changeKeyboardLayout': "Changer la disposition du clavier",
            'changeSession': "Changer de session",
            'closeUserSelection': "Fermer la sélection d'utilisateur",
            'loggingIn': "Connexion en cours",
            'login': "Connexion",
            'loginFailed': "Échec de la connexion",
            'noKeyboardLayoutsConfigured': "Aucune disposition de clavier configurée. Veuillez configurer les dispositions dans /etc/sddm.conf.d/*.conf",
            'noUsersFound': "SDDM n'a pas pu trouver d'utilisateur. Tapez votre nom d'utilisateur ci-dessous :",
            'password': "Mot de passe",
            'powerOptions': "Options d'alimentation",
            'pressAnyKey': "Appuyez sur n'importe quelle touche",
            'promptUser': "Entrez votre nom d'utilisateur",
            'reboot': "Redémarrer",
            'selectUser': "Sélectionner un utilisateur",
            'selectUserNamed': "Sélectionner l'utilisateur {name}",
            'shutdown': "Éteindre",
            'suspend': "Suspendre",
            'toggleVirtualKeyboard': "Basculer le clavier virtuel",
            'username': "Nom d'utilisateur",
        },
        'fr_FR': {
            'capslockWarning': "Verr Maj est activé",
            'changeKeyboardLayout': "Changer la disposition  du clavier",
            'changeSession': "Déconnexion",
            'closeUserSelection': "Fermer la sélection utilisateur",
            'loggingIn': "Connexion en cours",
            'login': "Connexion",
            'loginFailed': "Échec de la connexion",
            'noKeyboardLayoutsConfigured': "Aucune disposition de clavier n'est configurée. Veuillez configurer les dispositions dans /etc/sddm.conf.d/*.conf",
            'noUsersFound': "SDDM n'a pas pu trouver d'utilisateur. Retapez votre nom d'utilisateur ci-dessous :",
            'password': "Mot de passe",
            'powerOptions': "Options d'alimentation",
            'pressAnyKey': "Appuyez sur une touche",
            'promptUser': "Entrez votre nom d'utilisateur",
            'reboot': "Redémarrer",
            'selectUser': "Sélectionner l'utilisateur",
            'selectUserNamed': "Sélectionner l'utilisateur {nom}",
            'shutdown': "Arrêter",
            'suspend': "Suspendre",
            'toggleVirtualKeyboard': "Activer/désactiver le clavier virtuel",
            'username': "Nom d'utilisateur",
        },
        'he': {
            'capslockWarning': "Caps Lock דולק",
            'changeKeyboardLayout': "החלפת פריסת מקלדת",
            'changeSession': "החלפת הפעלה",
            'closeUserSelection': "סגירת בחירת משתמש",
            'loggingIn': "מתבצעת כניסה",
            'login': "כניסה",
            'loginFailed': "הכניסה נכשלה",
            'noKeyboardLayoutsConfigured': "לא מוגדרות פריסות מקלדת. נא להגדיר פריסות ב־‎/etc/sddm.conf.d/*.conf",
            'noUsersFound': "SDDM לא הצליח למצוא משתמשים כלשהם. נא למלא את שם המשתמש שלך להלן:",
            'password': "סיסמה",
            'powerOptions': "אפשרויות תפעול",
            'pressAnyKey': "נא ללחוץ על מקש כלשהו",
            'promptUser': "נא למלא את שם המשתמש שלך",
            'reboot': "הפעלה מחדש",
            'selectUser': "בחירת משתמש",
            'selectUserNamed': "בחירה במשתמש {name}",
            'shutdown': "כיבוי",
            'suspend': "השהיה",
            'toggleVirtualKeyboard': "הצגת/הסתרת מקלדת וירטואלית",
            'username': "שם משתמש",
        },
        'nl_NL': {
            'capslockWarning': "Caps Lock staat aan",
            'changeKeyboardLayout': "Toetsenbordindeling wijzigen",
            'changeSession': "Sessie wijzigen",
            'closeUserSelection': "Selectie van gebruikers sluiten",
            'loggingIn': "Inloggen",
            'login': "Inloggen",
            'loginFailed': "Inloggen is mislukt",
            'noKeyboardLayoutsConfigured': "Geen toetsenbordindelingen geconfigureerd. Configureer lay-outs in /etc/sddm.conf.d/*.conf",
            'noUsersFound': "SDDM kon geen enkele gebruiker vinden. Typ hieronder uw gebruikersnaam:",
            'password': "Wachtwoord",
            'powerOptions': "Opties voor energiebeheer",
            'pressAnyKey': "Druk op een toets",
            'promptUser': "Gebruikersnaam invoeren ",
            'reboot': "Opnieuw opstarten",
            'selectUser': "Gebruiker selecteren",
            'selectUserNamed': "Selecteer gebruiker {name}",
            'shutdown': "Uitschakelen",
            'suspend': "Opschorten",
            'toggleVirtualKeyboard': "Virtueel toetsenbord omschakelen",
            'username': "Gebruikersnaam",
        },
        'oc': {
            'capslockWarning': "Ver. Maj. actiu",
            'changeKeyboardLayout': "Cambiar la disposicion del clavièr",
            'changeSession': "Cambiar de session",
            'closeUserSelection': "Tampar la seleccion de l’utilizaire",
            'loggingIn': "Autentificacion",
            'login': "S’autentificar",
            'loginFailed': "Fracàs de l’autentificacion",
            'noKeyboardLayoutsConfigured': "Cap de disposicion de clavièr pas trobada. Mercés de configurar las disposicions dins /etc/sddm.conf.d/*.conf",
            'noUsersFound': "SDDM a pas pogut trobar cap d’utilizaire. Picatz lo nom d’utilizaire çaijós :",
            'password': "Senhal",
            'powerOptions': "Opcions d’alimentacion",
            'pressAnyKey': "Quichar una tòca",
            'promptUser': "Picatz lo nom d’utilizaire",
            'reboot': "Reaviar",
            'selectUser': "Seleccionar utilizaire",
            'selectUserNamed': "Seleccionar utilizaire {name}",
            'shutdown': "Atudar",
            'suspend': "Metre en velha",
            'toggleVirtualKeyboard': "Alternar clavièr virtual",
            'username': "Nom d’utilizaire",
        },
        'pt_BR': {
            'capslockWarning': "A tecla Caps Lock está ativada",
            'changeKeyboardLayout': "Alterar layout do teclado",
            'changeSession': "Alterar sessão",
            'closeUserSelection': "Fechar seleção de usuário",
            'loggingIn': "Logging in",
            'login': "Login",
            'loginFailed': "Login failed",
            'noKeyboardLayoutsConfigured': "Nenhum layout de teclado configurado. Configure os layouts em /etc/sddm.conf.d/*.conf",
            'noUsersFound': "O SDDM não encontrou nenhum usuário. Digite seu nome de usuário abaixo:",
            'password': "Senha",
            'powerOptions': "Opções de energia",
            'pressAnyKey': "Pressione qualquer tecla",
            'promptUser': "Digite seu nome de usuário",
            'reboot': "Reiniciar",
            'selectUser': "Selecionar usuário",
            'selectUserNamed': "Selecione o usuário {name}",
            'shutdown': "Desligar",
            'suspend': "Suspender",
            'toggleVirtualKeyboard': "Alternar teclado virtual",
            'username': "Nome de usuário",
        },
        'tr': {
            'capslockWarning': "Caps Lock açık",
            'changeKeyboardLayout': "Klavye düzenini değiştir",
            'changeSession': "Oturumu değiştir",
            'closeUserSelection': "Kullanıcı seçimini kapat",
            'loggingIn': "Giriş yapılıyor",
            'login': "Giriş",
            'loginFailed': "Giriş başarısız",
            'noKeyboardLayoutsConfigured': "Klavyeniz için herhangi bir düzen yapılandırılmamış. Lütfen /etc/sddm.conf.d/*.conf dosyasında düzenleri yapılandırın.",
            'noUsersFound': "SDDM herhangi bir kullanıcı bulamadı. Kullanıcı adınızı aşağıya yazın.",
            'password': "Parola",
            'powerOptions': "Güç seçenekleri",
            'pressAnyKey': "Herhangi bir tuşa basın",
            'promptUser': "Kullanıcı adınızı giriniz",
            'reboot': "Yeniden başlat",
            'selectUser': "Kullancıyı seçin",
            'selectUserNamed': "{name} kullanıcısını seçiniz",
            'shutdown': "Kapat",
            'suspend': "Durdur",
            'toggleVirtualKeyboard': "Sanal klavyeyi aç/kapat",
            'username': "Kullanıcı adı",
        },
    })

    // Get translation for current locale, fallback to English
    function tr(key) {
        // Try full locale (e.g., 'es_ES')
        if (translations[currentLocale] && translations[currentLocale][key]) {
            return translations[currentLocale][key]
        }
        
        // Try language code only (e.g., 'es' from 'es_ES')
        var langCode = currentLocale.split('_')[0]
        if (translations[langCode] && translations[langCode][key]) {
            return translations[langCode][key]
        }
        
        // Fallback to English
        if (translations['en'] && translations['en'][key]) {
            return translations['en'][key]
        }
        
        // Last resort: return key itself
        return key
    }

    // Basic strings
    readonly property string pressAnyKey: tr('pressAnyKey')
    readonly property string username: tr('username')
    readonly property string password: tr('password')
    readonly property string login: tr('login')
    readonly property string loggingIn: tr('loggingIn')
    readonly property string loginFailed: tr('loginFailed')
    readonly property string promptUser: tr('promptUser')
    readonly property string capslockWarning: tr('capslockWarning')

    // Power menu
    readonly property string suspend: tr('suspend')
    readonly property string reboot: tr('reboot')
    readonly property string shutdown: tr('shutdown')

    // Tooltips and UI
    readonly property string closeUserSelection: tr('closeUserSelection')
    readonly property string selectUser: tr('selectUser')

    // Error messages
    readonly property string noKeyboardLayoutsConfigured: tr('noKeyboardLayoutsConfigured')

    // Parameterized strings
    function selectUserNamed(name) {
        return tr('selectUserNamed').replace('%1', name).replace('{name}', name)
    }
}
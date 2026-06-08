
# Directories
prefix        = get_option('prefix')
bindir        = join_paths(prefix, get_option('bindir'))
mandir        = join_paths(prefix, 'share', 'man')
theme_dir     = join_paths(prefix, 'share', 'sddm', 'themes', theme_name)
sddm_conf_dir = join_paths(prefix, get_option('sddm_conf_dir'))
libexec_dir   = join_paths(prefix, get_option('libexecdir'))

src = meson.current_source_dir() / '..'

# Substitution map shared by all configure_file() calls below
conf_data = configuration_data()
conf_data.set('THEME_NAME',         theme_name)
conf_data.set('THEME_DIR',          theme_dir)
conf_data.set('THEME_DISPLAY_NAME', get_option('theme_display_name'))
conf_data.set('THEME_DESCRIPTION',  get_option('theme_description'))
conf_data.set('THEME_AUTHOR',       get_option('theme_author'))
conf_data.set('THEME_WEBSITE',      get_option('theme_website'))

# Background resolution: per-screen option falls back to shared default_background
_default_bg    = get_option('default_background')
_lock_bg_raw   = get_option('default_lock_background')
_login_bg_raw  = get_option('default_login_background')
_lock_bg       = _lock_bg_raw  != '' ? _lock_bg_raw  : _default_bg
_login_bg      = _login_bg_raw != '' ? _login_bg_raw : _default_bg
conf_data.set('DEFAULT_LOCK_BACKGROUND',  _lock_bg)
conf_data.set('DEFAULT_LOGIN_BACKGROUND', _login_bg)

src = meson.current_source_dir() / '..'

# Install display helper script
install_data(
  src / 'budgie-sddm-display-setup',
  install_dir: libexec_dir,
  install_mode: 'rwxr-xr-x'
)

# Install slicksddm-customize script to /usr/bin
install_data(
  src / 'slicksddm-customize',
  install_dir: bindir,
  install_mode: 'rwxr-xr-x'
)

# slicksddm-customize
install_data(
  src / 'slicksddm-customize.png',
  install_dir: join_paths(prefix, 'share', 'pixmaps')
)

install_data(
  src / 'slicksddm-customize.desktop',
  install_dir: join_paths(prefix, 'share', 'applications')
)

# Install man page
install_data(
  src / 'slicksddm-customize.1',
  install_dir: join_paths(mandir, 'man1')
)

# Install Main.qml (theme.conf is now generated from theme.conf.in above)
install_data(
  src / 'sddm-theme/Main.qml',
  install_dir: theme_dir
)

# Generate theme.conf from template, substituting background paths
configure_file(
  input:         src / 'sddm-theme/theme.conf.in',
  output:        'theme.conf',
  configuration: conf_data,
  install:       true,
  install_dir:   theme_dir
)

# Generate metadata.desktop from template, substituting theme identity tokens
configure_file(
  input:         src / 'sddm-theme/metadata.desktop.in',
  output:        'metadata.desktop',
  configuration: conf_data,
  install:       true,
  install_dir:   theme_dir
)

configure_file(
  input:         src / 'sddm-theme/theme.conf.in',
  output:        'theme.conf.example',
  configuration: conf_data,
  install:       true,
  install_mode:  'r--r--r--',
  install_dir:   theme_dir
)

# Install components directory
install_data(
  src / 'sddm-theme/components/AccountsService.qml',
  src / 'sddm-theme/components/Avatar.qml',
  src / 'sddm-theme/components/Config.qml',
  src / 'sddm-theme/components/CVKeyboard.qml',
  src / 'sddm-theme/components/IconButton.qml',
  src / 'sddm-theme/components/Input.qml',
  src / 'sddm-theme/components/Languages.qml',
  src / 'sddm-theme/components/LayoutSelector.qml',
  src / 'sddm-theme/components/LockScreen.qml',
  src / 'sddm-theme/components/LoginScreen.qml',
  src / 'sddm-theme/components/MenuArea.qml',
  src / 'sddm-theme/components/PowerMenu.qml',
  src / 'sddm-theme/components/SessionSelector.qml',
  src / 'sddm-theme/components/Spinner.qml',
  src / 'sddm-theme/components/TextConstants.qml',
  src / 'sddm-theme/components/TranslationManager.qml',
  src / 'sddm-theme/components/UserSelector.qml',
  src / 'sddm-theme/components/qmldir',
  install_dir: join_paths(theme_dir, 'components')
)

# Install virtual keyboard style
install_data(
  src / 'sddm-theme/components/QtQuick/VirtualKeyboard/Styles/vkeyboardStyle/style.qml',
  install_dir: join_paths(
    theme_dir,
    'components',
    'QtQuick',
    'VirtualKeyboard',
    'Styles',
    'vkeyboardStyle'
  )
)

# Install subdirectories - backgrounds, icons, faces
# These use install_subdir to capture all files recursively
install_subdir(
  src / 'sddm-theme/backgrounds',
  install_dir: theme_dir,
  strip_directory: false
)

install_subdir(
  src / 'sddm-theme/icons',
  install_dir: theme_dir,
  strip_directory: false
)

install_subdir(
  src / 'sddm-theme/faces',
  install_dir: theme_dir,
  strip_directory: false
)

# Generate SDDM config snippet from template
configure_file(
  input:         src / 'sddm-conf/sddm.conf.in',
  output:        '10-' + theme_name + '.conf',
  configuration: conf_data,
  install:       true,
  install_dir:   sddm_conf_dir
)

# Generate backgrounds cache update script from template
configure_file(
  input:         src / 'sddm-theme/scripts/update-sddm-backgrounds-cache.in',
  output:        'update-sddm-backgrounds-cache',
  configuration: conf_data,
  install:       true,
  install_mode:  'rwxr-xr-x',
  install_dir:   join_paths(theme_dir, 'scripts')
)

# Generate systemd service unit from template
configure_file(
  input:         src / 'systemd/sddm-backgrounds-cache.service.in',
  output:        'sddm-backgrounds-cache.service',
  configuration: conf_data,
  install:       true,
  install_dir:   join_paths(prefix, 'lib', 'systemd', 'system')
)

install_data(
  src / 'systemd/sddm-backgrounds-cache.path',
  src / 'systemd/sddm-backgrounds-cache.timer',
  install_dir:   join_paths(prefix, 'lib', 'systemd', 'system')
)

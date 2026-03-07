project('slicksddm',
  version: '1.0',
  license: 'GPL-3.0',
  meson_version: '>= 0.59.0'
)

# Directories
prefix        = get_option('prefix')
bindir        = join_paths(prefix, get_option('bindir'))
mandir        = join_paths(prefix, 'share', 'man')
theme_dir     = join_paths(prefix, 'share', 'sddm', 'themes', 'ubuntu-budgie-login')

# Install slicksddm-customize script to /usr/bin
install_data(
  'slicksddm-customize',
  install_dir: bindir,
  install_mode: 'rwxr-xr-x'
)

# Install man page
install_data(
  'slicksddm-customize.1',
  install_dir: join_paths(mandir, 'man1')
)

# Install top-level theme files
install_data(
  'sddm-theme/Main.qml',
  'sddm-theme/theme.conf',
  'sddm-theme/metadata.desktop',
  install_dir: theme_dir
)

# Install theme.conf as theme.conf.example (pristine defaults reference)
install_data(
  'sddm-theme/theme.conf',
  rename: 'theme.conf.example',
  install_mode: 'r--r--r--',
  install_dir: theme_dir
)

# Install components directory
install_data(
  'sddm-theme/components/Avatar.qml',
  'sddm-theme/components/Config.qml',
  'sddm-theme/components/CVKeyboard.qml',
  'sddm-theme/components/IconButton.qml',
  'sddm-theme/components/Input.qml',
  'sddm-theme/components/Languages.qml',
  'sddm-theme/components/LayoutSelector.qml',
  'sddm-theme/components/LockScreen.qml',
  'sddm-theme/components/LoginScreen.qml',
  'sddm-theme/components/MenuArea.qml',
  'sddm-theme/components/PowerMenu.qml',
  'sddm-theme/components/SessionSelector.qml',
  'sddm-theme/components/Spinner.qml',
  'sddm-theme/components/TextConstants.qml',
  'sddm-theme/components/TranslationManager.qml',
  'sddm-theme/components/UserSelector.qml',
  'sddm-theme/components/qmldir',
  install_dir: join_paths(theme_dir, 'components')
)

# Install virtual keyboard style
install_data(
  'sddm-theme/components/QtQuick/VirtualKeyboard/Styles/vkeyboardStyle/style.qml',
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
  'sddm-theme/backgrounds',
  install_dir: theme_dir,
  strip_directory: false
)

install_subdir(
  'sddm-theme/icons',
  install_dir: theme_dir,
  strip_directory: false
)

install_subdir(
  'sddm-theme/faces',
  install_dir: theme_dir,
  strip_directory: false
)

# Install SDDM config snippet to enable the theme
install_data(
  'sddm-conf/50-ubuntu-budgie.conf',
  install_dir: join_paths(prefix, 'lib', 'sddm', 'sddm.conf.d')
)

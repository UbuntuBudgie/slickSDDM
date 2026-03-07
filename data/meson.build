
# Directories
prefix        = get_option('prefix')
bindir        = join_paths(prefix, get_option('bindir'))
mandir        = join_paths(prefix, 'share', 'man')
theme_dir     = join_paths(prefix, 'share', 'sddm', 'themes', 'ubuntu-budgie-login')

src = meson.current_source_dir() / '..'

# Install slicksddm-customize script to /usr/bin
install_data(
  src / 'slicksddm-customize',
  install_dir: bindir,
  install_mode: 'rwxr-xr-x'
)

# Install man page
install_data(
  src / 'slicksddm-customize.1',
  install_dir: join_paths(mandir, 'man1')
)

# Install top-level theme files
install_data(
  src / 'sddm-theme/Main.qml',
  src /'sddm-theme/theme.conf',
  src / 'sddm-theme/metadata.desktop',
  install_dir: theme_dir
)

# Install theme.conf as theme.conf.example (pristine defaults reference)
install_data(
  src / 'sddm-theme/theme.conf',
  rename: 'theme.conf.example',
  install_mode: 'r--r--r--',
  install_dir: theme_dir
)

# Install components directory
install_data(
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

# Install SDDM config snippet to enable the theme
install_data(
  src / 'sddm-conf/50-ubuntu-budgie.conf',
  install_dir: join_paths(prefix, 'lib', 'sddm', 'sddm.conf.d')
)

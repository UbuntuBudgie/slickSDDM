# slickSDDM Theme Customization Guide

Complete reference for customizing the slickSDDM login theme.

## Table of Contents

1. [Quick Start](#quick-start)
2. [Configuration File Location](#configuration-file-location)
3. [General Settings](#general-settings)
4. [Lock Screen](#lock-screen)
5. [Login Screen](#login-screen)
6. [Advanced Customization](#advanced-customization)
7. [Color Reference](#color-reference)
8. [Examples](#examples)

---

## Quick Start

### Using the Customization Script (Recommended)
```bash
sudo slicksddm-customize --interactive
```

### Manual Editing
```bash
sudo nano /usr/share/sddm/themes/ubuntu-budgie-login/theme.conf
sudo systemctl restart sddm
```

---

## Configuration File Location

**Default**: `/usr/share/sddm/themes/[theme-name]/theme.conf`

The configuration file uses INI format with sections like `[General]`, `[LockScreen]`, etc.

---

## General Settings

### `[General]`

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `scale` | Float | `1.0` | Overall UI scale multiplier (0.5-2.0) |
| `enable-animations` | Boolean | `true` | Enable/disable all animations |
| `animated-background-placeholder` | String | (empty) | Placeholder image while video background loads |
| `background-fill-mode` | Enum | `"fill"` | How background images/videos fill screen<br>**Values**: `"fill"`, `"fit"`, `"stretch"` |

**Example:**
```ini
[General]
scale = 1.2
enable-animations = true
background-fill-mode = "fill"
```

---

## Lock Screen

### `[LockScreen]`

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `display` | Boolean | `true` | Show lock screen before login |
| `padding-top` | Integer | `0` | Top padding in pixels |
| `padding-right` | Integer | `0` | Right padding in pixels |
| `padding-bottom` | Integer | `0` | Bottom padding in pixels |
| `padding-left` | Integer | `0` | Left padding in pixels |
| `background` | String | `"default.jpg"` | Background image/video file path<br>**Formats**: jpg, png, mp4, mov, mkv, webm<br>**Paths**: Absolute (`/path/to/image.jpg`) or relative (`backgrounds/image.jpg`) |
| `use-background-color` | Boolean | `false` | Use solid color instead of image |
| `background-color` | Color | `"#000000"` | Background color (hex format) |
| `blur` | Integer | `16` | Blur amount (0-100, 0=no blur) |
| `brightness` | Float | `0.0` | Brightness adjustment (-1.0 to 1.0) |
| `saturation` | Float | `0.0` | Saturation adjustment (-1.0 to 1.0) |

### `[LockScreen.Clock]`

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `display` | Boolean | `true` | Show clock on lock screen |
| `position` | Enum | `"bottom-right"` | Clock position<br>**Values**: `"top-left"`, `"top-center"`, `"top-right"`, `"center-left"`, `"center"`, `"center-right"`, `"bottom-left"`, `"bottom-center"`, `"bottom-right"` |
| `align` | Enum | `"left"` | Text alignment<br>**Values**: `"left"`, `"center"`, `"right"` |
| `format` | String | `"hh:mm"` | Time format string<br>**Examples**: `"hh:mm"` (14:30), `"h:mm AP"` (2:30 PM) |
| `font-family` | String | `"Sawasdee"` | Font family name |
| `font-size` | Integer | `75` | Font size in points |
| `font-weight` | Integer | `300` | Font weight (100-900, 400=normal, 700=bold) |
| `color` | Color | `"#ffffff"` | Text color (hex format) |

### `[LockScreen.Date]`

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `display` | Boolean | `true` | Show date on lock screen |
| `format` | String | `"dddd dd MMMM"` | Date format string<br>**Examples**: `"dddd dd MMMM"` (Monday 03 February), `"MM/dd/yyyy"` (02/03/2026) |
| `locale` | String | `"en_US"` | Locale for date formatting (lang_COUNTRY) |
| `font-family` | String | `"Sawasdee"` | Font family name |
| `font-size` | Integer | `32` | Font size in points |
| `font-weight` | Integer | `300` | Font weight (100-900) |
| `color` | Color | `"#ffffff"` | Text color (hex format) |
| `margin-top` | Integer | `-15` | Spacing from clock (negative=closer) |

### `[LockScreen.Message]`

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `display` | Boolean | `true` | Show custom message on lock screen |
| `position` | Enum | `"bottom-center"` | Message position (see Clock positions) |
| `align` | Enum | `"center"` | Text alignment (`"left"`, `"center"`, `"right"`) |
| `text` | String | `"Press any key"` | Message text |
| `font-family` | String | `"Noto Sans"` | Font family name |
| `font-size` | Integer | `12` | Font size in points |
| `font-weight` | Integer | `400` | Font weight (100-900) |
| `display-icon` | Boolean | `true` | Show icon above message |
| `icon` | String | `"enter.svg"` | Icon filename (from `icons/`) |
| `icon-size` | Integer | `16` | Icon size in pixels |
| `color` | Color | `"#d3dae3"` | Text/icon color (hex format) |
| `paint-icon` | Boolean | `true` | Colorize icon to match text color |
| `spacing` | Integer | `0` | Space between icon and text |

---

## Login Screen

### `[LoginScreen]`

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `background` | String | `"default.jpg"` | Background image/video (same formats as LockScreen) |
| `use-background-color` | Boolean | `false` | Use solid color background |
| `background-color` | Color | `"#000000"` | Background color (hex format) |
| `blur` | Integer | `0` | Blur amount (0-100) |
| `brightness` | Float | `0.0` | Brightness adjustment (-1.0 to 1.0) |
| `saturation` | Float | `0.0` | Saturation adjustment (-1.0 to 1.0) |

### `[LoginScreen.LoginArea]`

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `position` | Enum | `"left"` | Position of the login area<br>**Values**: `"left"`, `"center"`, `"right"` |
| `margin` | Integer | `50` | Distance from edge or top<br>Set to `-1` to center vertically/horizontally |
| `show-all-users` | Boolean | `false` | Display all user avatars by default instead of just the selected user<br>Users can still collapse the list by clicking the active avatar |

### `[LoginScreen.LoginArea.Avatar]`

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `shape` | Enum | `"square"` | Avatar shape<br>**Values**: `"circle"`, `"square"` |
| `border-radius` | Integer | `30` | Corner radius for square avatars (0-100) |
| `active-size` | Integer | `120` | Size of selected user's avatar (pixels) |
| `inactive-size` | Integer | `80` | Size of non-selected avatars (pixels) |
| `inactive-opacity` | Float | `0.35` | Opacity of non-selected avatars (0.0-1.0) |
| `active-border-size` | Integer | `3` | Border width of selected avatar (pixels) |
| `inactive-border-size` | Integer | `3` | Border width of non-selected avatars |
| `active-border-color` | Color | `"#5294e2"` | Border color of selected avatar |
| `inactive-border-color` | Color | `"#5294e2"` | Border color of non-selected avatars |

### `[LoginScreen.LoginArea.Username]`

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `font-family` | String | `"Noto Sans"` | Font family name |
| `font-size` | Integer | `16` | Font size in points |
| `font-weight` | Integer | `700` | Font weight (100-900) |
| `color` | Color | `"#d3dae3"` | Text color (hex format) |
| `margin` | Integer | `10` | Distance from avatar (pixels) |

### `[LoginScreen.LoginArea.PasswordInput]`

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `width` | Integer | `200` | Input field width (pixels) |
| `height` | Integer | `30` | Input field height (pixels) |
| `display-icon` | Boolean | `true` | Show icon in input field |
| `font-family` | String | `"Noto Sans"` | Font family name |
| `font-size` | Integer | `12` | Font size in points |
| `icon` | String | `"password.svg"` | Icon filename (from `icons/`) |
| `icon-size` | Integer | `16` | Icon size in pixels |
| `content-color` | Color | `"#ffffff"` | Text and icon color |
| `background-color` | Color | `"#d3dae3"` | Input background color |
| `background-opacity` | Float | `0.0` | Background opacity (0.0-1.0) |
| `border-size` | Integer | `2` | Border width in pixels |
| `border-color` | Color | `"#5294e2"` | Border color |
| `border-radius-left` | Integer | `10` | Left corner radius |
| `border-radius-right` | Integer | `10` | Right corner radius |
| `margin-top` | Integer | `10` | Distance from username |
| `masked-character` | String | `"●"` | Character used to mask password |

### `[LoginScreen.LoginArea.LoginButton]`

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `background-color` | Color | `"#d3dae3"` | Button background color |
| `background-opacity` | Float | `0.0` | Normal background opacity (0.0-1.0) |
| `active-background-color` | Color | `"#5294e2"` | Background when hovered/focused |
| `active-background-opacity` | Float | `1.0` | Active background opacity |
| `icon` | String | `"arrow-right.svg"` | Button icon filename |
| `icon-size` | Integer | `18` | Icon size in pixels |
| `content-color` | Color | `"#5294e2"` | Icon/text color |
| `active-content-color` | Color | `"#ffffff"` | Color when hovered/focused |
| `border-size` | Integer | `2` | Border width |
| `border-color` | Color | `"#5294e2"` | Border color |
| `border-radius-left` | Integer | `10` | Left corner radius |
| `border-radius-right` | Integer | `10` | Right corner radius |
| `margin-left` | Integer | `5` | Distance from password field |
| `show-text-if-no-password` | Boolean | `true` | Show "Login" text for passwordless users |
| `hide-if-not-needed` | Boolean | `true` | Hide button if password is visible |
| `font-family` | String | `"Noto Sans"` | Font family for label |
| `font-size` | Integer | `12` | Label font size |
| `font-weight` | Integer | `600` | Label font weight |

### `[LoginScreen.LoginArea.Spinner]`

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `display-text` | Boolean | `true` | Show text with spinner |
| `text` | String | `"Logging in"` | Spinner message |
| `font-family` | String | `"Noto Sans"` | Font family |
| `font-weight` | Integer | `600` | Font weight |
| `font-size` | Integer | `14` | Font size |
| `icon-size` | Integer | `30` | Spinner icon size |
| `icon` | String | `"spinner.svg"` | Spinner icon filename |
| `color` | Color | `"#d3dae3"` | Spinner and text color |
| `spacing` | Integer | `5` | Space between icon and text |

### `[LoginScreen.LoginArea.WarningMessage]`

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `font-family` | String | `"Noto Sans"` | Font family |
| `font-size` | Integer | `11` | Font size |
| `font-weight` | Integer | `400` | Font weight |
| `normal-color` | Color | `"#d3dae3"` | Color for normal messages |
| `warning-color` | Color | `"#f9ae58"` | Color for warnings |
| `error-color` | Color | `"#f04a50"` | Color for errors |
| `margin-top` | Integer | `10` | Distance from password/button |

### `[LoginScreen.MenuArea.Buttons]`

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `margin-top` | Integer | `0` | Top margin for menu buttons |
| `margin-right` | Integer | `0` | Right margin |
| `margin-bottom` | Integer | `100` | Bottom margin |
| `margin-left` | Integer | `100` | Left margin |
| `size` | Integer | `30` | Button size (pixels) |
| `border-radius` | Integer | `5` | Button corner radius |
| `spacing` | Integer | `10` | Space between buttons |
| `font-family` | String | `"Noto Sans"` | Font for button labels |

### `[LoginScreen.MenuArea.Popups]`

Common settings for all popup menus:

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `max-height` | Integer | `300` | Maximum popup height |
| `item-height` | Integer | `30` | Height of each menu item |
| `item-spacing` | Integer | `2` | Space between menu items |
| `padding` | Integer | `5` | Internal padding |
| `display-scrollbar` | Boolean | `false` | Show scrollbar if needed |
| `margin` | Integer | `5` | Distance from button |
| `background-color` | Color | `"#383c4a"` | Popup background |
| `background-opacity` | Float | `1.0` | Background opacity |
| `active-option-background-color` | Color | `"#404552"` | Highlighted item background |
| `active-option-background-opacity` | Float | `1.0` | Highlighted item opacity |
| `content-color` | Color | `"#d3dae3"` | Normal text color |
| `active-content-color` | Color | `"#5294e2"` | Highlighted text color |
| `font-family` | String | `"Noto Sans"` | Font family |
| `border-size` | Integer | `2` | Border width |
| `border-color` | Color | `"#5294e2"` | Border color |
| `font-size` | Integer | `11` | Font size |
| `icon-size` | Integer | `16` | Icon size |

### `[LoginScreen.MenuArea.Session]`

Session selector button:

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `display` | Boolean | `true` | Show session button |
| `position` | Enum | `"bottom-left"` | Button position (see Clock positions) |
| `index` | Integer | `4` | Sort order for same position |
| `popup-direction` | Enum | `"up"` | Popup direction<br>**Values**: `"up"`, `"down"`, `"left"`, `"right"` |
| `popup-align` | Enum | `"center"` | Popup alignment<br>**Values**: `"start"`, `"center"`, `"end"` |
| `display-session-name` | Boolean | `true` | Show session name on button |
| `button-width` | Integer | `200` | Button width (ignored if session name shown) |
| `popup-width` | Integer | `200` | Popup width |
| `background-color` | Color | `"#383c4a"` | Button background |
| `background-opacity` | Float | `0.0` | Normal background opacity |
| `active-background-opacity` | Float | `1.0` | Active background opacity |
| `content-color` | Color | `"#d3dae3"` | Icon/text color |
| `active-content-color` | Color | `"#5294e2"` | Active icon/text color |
| `border-size` | Integer | `0` | Border width |
| `font-size` | Integer | `10` | Font size |
| `icon-size` | Integer | `16` | Icon size |

### `[LoginScreen.MenuArea.Layout]`

Keyboard layout selector:

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `display` | Boolean | `true` | Show layout button |
| `position` | Enum | `"bottom-left"` | Button position |
| `index` | Integer | `3` | Sort order |
| `popup-direction` | Enum | `"up"` | Popup direction |
| `popup-align` | Enum | `"center"` | Popup alignment |
| `popup-width` | Integer | `180` | Popup width |
| `display-layout-name` | Boolean | `true` | Show layout code on button |
| `background-color` | Color | `"#383c4a"` | Button background |
| `background-opacity` | Float | `0.0` | Normal opacity |
| `active-background-opacity` | Float | `1.0` | Active opacity |
| `content-color` | Color | `"#d3dae3"` | Icon/text color |
| `active-content-color` | Color | `"#5294e2"` | Active color |
| `border-size` | Integer | `0` | Border width |
| `font-size` | Integer | `10` | Font size |
| `icon` | String | `"language.svg"` | Button icon |
| `icon-size` | Integer | `16` | Icon size |

### `[LoginScreen.MenuArea.Keyboard]`

Virtual keyboard toggle:

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `display` | Boolean | `true` | Show keyboard button |
| `position` | Enum | `"bottom-left"` | Button position |
| `index` | Integer | `2` | Sort order |
| `background-color` | Color | `"#383c4a"` | Button background |
| `background-opacity` | Float | `0.0` | Normal opacity |
| `active-background-opacity` | Float | `1.0` | Active opacity |
| `content-color` | Color | `"#d3dae3"` | Icon color |
| `active-content-color` | Color | `"#5294e2"` | Active icon color |
| `border-size` | Integer | `0` | Border width |
| `icon` | String | `"keyboard.svg"` | Button icon |
| `icon-size` | Integer | `16` | Icon size |

### `[LoginScreen.MenuArea.Power]`

Power menu button:

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `display` | Boolean | `true` | Show power button |
| `position` | Enum | `"bottom-left"` | Button position |
| `index` | Integer | `1` | Sort order |
| `popup-direction` | Enum | `"up"` | Popup direction |
| `popup-align` | Enum | `"center"` | Popup alignment |
| `popup-width` | Integer | `100` | Popup width |
| `background-color` | Color | `"#383c4a"` | Button background |
| `background-opacity` | Float | `0.0` | Normal opacity |
| `active-background-opacity` | Float | `1.0` | Active opacity |
| `content-color` | Color | `"#d3dae3"` | Icon color |
| `active-content-color` | Color | `"#5294e2"` | Active icon color |
| `border-size` | Integer | `0` | Border width |
| `icon` | String | `"power.svg"` | Button icon |
| `icon-size` | Integer | `16` | Icon size |

### `[LoginScreen.VirtualKeyboard]`

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `scale` | Float | `1.0` | Keyboard size multiplier |
| `position` | Enum | `"login"` | Initial position<br>**Values**: `"login"`, `"top"`, `"bottom"`, `"left"`, `"right"` |
| `start-hidden` | Boolean | `true` | Hide keyboard on startup |
| `background-color` | Color | `"#383c4a"` | Keyboard background |
| `background-opacity` | Float | `1.0` | Background opacity |
| `key-content-color` | Color | `"#d3dae3"` | Key text color |
| `key-color` | Color | `"#404552"` | Key background |
| `key-opacity` | Float | `1.0` | Key opacity |
| `key-active-background-color` | Color | `"#5294e2"` | Special key background |
| `key-active-opacity` | Float | `0.0` | Special key opacity |
| `selection-background-color` | Color | `"#5294e2"` | Selected character background |
| `selection-content-color` | Color | `"#ffffff"` | Selected character text |
| `primary-color` | Color | `"#5294e2"` | Accent color |
| `border-size` | Integer | `2` | Border width |
| `border-color` | Color | `"#5294e2"` | Border color |

### `[Tooltips]`

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `enable` | Boolean | `true` | Show tooltips on hover |
| `font-family` | String | `"Noto Sans"` | Font family |
| `font-size` | Integer | `11` | Font size |
| `content-color` | Color | `"#d3dae3"` | Text color |
| `background-color` | Color | `"#383c4a"` | Background color |
| `background-opacity` | Float | `1.0` | Background opacity |
| `border-radius` | Integer | `5` | Corner radius |
| `disable-user` | Boolean | `false` | Disable user avatar tooltip |
| `disable-login-button` | Boolean | `false` | Disable login button tooltip |

---

## Color Reference

### Ubuntu Budgie Default Colors

| Color Name | Hex Value | Usage |
|------------|-----------|-------|
| Budgie Blue | `#5294e2` | Primary accent, borders, highlights |
| Light Gray | `#d3dae3` | Primary text color |
| Dark Gray | `#383c4a` | Background for popups/keyboard |
| Medium Gray | `#404552` | Hover states |
| Orange | `#f9ae58` | Warnings |
| Red | `#f04a50` | Errors |
| White | `#ffffff` | High contrast text |
| Black | `#000000` | Solid backgrounds |

### Creating Your Own Color Scheme

1. Choose a primary accent color (replace `#5294e2`)
2. Choose text colors with good contrast (WCAG AA: 4.5:1 minimum)
3. Maintain consistent opacity values
4. Test with different backgrounds

**Example Custom Scheme (Purple/Gold):**
```ini
[LoginScreen.LoginArea.Avatar]
active-border-color = "#9b59b6"

[LoginScreen.LoginArea.PasswordInput]
border-color = "#9b59b6"

[LoginScreen.LoginArea.LoginButton]
content-color = "#9b59b6"
active-background-color = "#f39c12"
```

---

## Examples

### Example 1: Minimal Dark Theme
```ini
[General]
enable-animations = false

[LockScreen]
use-background-color = true
background-color = "#1a1a1a"
blur = 0

[LoginScreen]
use-background-color = true
background-color = "#1a1a1a"

[LoginScreen.LoginArea.Avatar]
shape = "circle"
active-border-color = "#ffffff"

[LoginScreen.LoginArea.PasswordInput]
border-color = "#ffffff"
content-color = "#ffffff"
```

### Example 2: Colorful Modern Theme
```ini
[General]
scale = 1.1
enable-animations = true

[LoginScreen]
background = "/usr/share/backgrounds/gradient.jpg"
blur = 20
saturation = 0.5

[LoginScreen.LoginArea.Avatar]
shape = "square"
border-radius = 20
active-border-color = "#e91e63"

[LoginScreen.LoginArea.PasswordInput]
border-color = "#e91e63"
background-opacity = 0.2

[LoginScreen.LoginArea.LoginButton]
active-background-color = "#e91e63"
```

### Example 3: Corporate Professional
```ini
[General]
enable-animations = false

[LockScreen]
display = false

[LoginScreen]
background = "/company/branding/wallpaper.jpg"
blur = 0

[LoginScreen.LoginArea]
position = "center"
margin = -1

[LoginScreen.LoginArea.Avatar]
shape = "square"
border-radius = 5
active-border-color = "#003366"

[LoginScreen.LoginArea.PasswordInput]
border-color = "#003366"
```

### Example 4: Accessibility Enhanced
```ini
[General]
scale = 1.5

[LockScreen.Clock]
font-size = 100
font-weight = 700

[LoginScreen.LoginArea.Username]
font-size = 24
font-weight = 700

[LoginScreen.LoginArea.PasswordInput]
height = 50
font-size = 18
border-size = 3

[LoginScreen.VirtualKeyboard]
scale = 1.3
start-hidden = false

[Tooltips]
font-size = 14
```

---

## Advanced Customization

### Custom Backgrounds

**Static Image:**
```ini
[LoginScreen]
background = "/usr/share/backgrounds/custom/login.jpg"
```

**Video Background:**
```ini
[LoginScreen]
background = "/usr/share/backgrounds/custom/ambient.mp4"
animated-background-placeholder = "placeholder.jpg"
```

**Per-Time-of-Day:**
Create a script to switch backgrounds based on time (requires external cron job).

### Custom Icons

Replace default icons in `/usr/share/sddm/themes/[theme]/icons/`:
```bash
sudo cp my-power-icon.svg /usr/share/sddm/themes/ubuntu-budgie-login/icons/power.svg
```

Then update `theme.conf`:
```ini
[LoginScreen.MenuArea.Power]
icon = "power.svg"
```

### Custom Fonts

Install fonts system-wide, then reference:
```ini
[LockScreen.Clock]
font-family = "MyCustomFont"
```

### Custom Avatar Faces

Replace files in `/usr/share/sddm/themes/[theme]/faces/`:
```bash
sudo cp custom-avatar.png /usr/share/sddm/themes/ubuntu-budgie-login/faces/face-1.png
```

Or use per-user avatars: `~/.face.icon`

---

## Troubleshooting

### Changes Not Appearing
```bash
# Restart SDDM
sudo systemctl restart sddm

# Check for syntax errors
grep -v '^#' /usr/share/sddm/themes/*/theme.conf | grep -v '^$'
```

### SDDM Won't Start
```bash
# Check logs
journalctl -u sddm -b

# Reset to default theme temporarily
echo -e "[Theme]\nCurrent=breeze" | sudo tee /etc/sddm.conf.d/00-temp.conf
sudo systemctl restart sddm
```

### Colors Look Wrong

- Ensure hex colors start with `#`
- Use 6-digit hex (`#rrggbb`), not 3-digit
- Check opacity values are 0.0-1.0

---

## Getting Help

- Documentation: [GitHub Wiki](https://github.com/ubuntubudgie/slickSDDM)
- Issues: [GitHub Issues](https://github.com/ubuntubudgie/slickSDDM/issues)
- Community: [Ubuntu Budgie Forums](https://discourse.ubuntubudgie.org)

---

**Last Updated:** 2026-02-03  
**Theme Version:** 1.0

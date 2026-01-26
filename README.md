# slickSDDM

> [!WARNING]
> This theme requires **SDDM v0.21.0 or newer**. Make sure your distro provides the correct version before installing.

# TRANSLATIONS

consult docs/*
consult TRANSLATORS.md

# Dependencies

- SDDM ≥ 0.21;
- QT ≥ 6.5;
- qt6-svg;
- qt6-virtualkeyboard
- qt6-multimedia

## Install script

1. clone the repo

```
git clone https://github.com/ubuntubudgie/slickSDDM.git
cd slickSDDM/
````

2. ```sudo mkdir /usr/share/sddm/themes/yourthemename```
3. Create a similar file in the yourthemename folder based on ```sddm-conf/50-ubuntu-budgie.conf```
4. Make sure you change ```Current=``` to be yourthemename
5. test your changes
   
```sddm-greeter-qt6 --test-mode --theme /usr/share/sddm/themes/yourthemename```


# Acknowledgements

- [uiriansan/SilentSDDM](https://github.com/uiriansan/SilentSDDM): major thanks - basis for this theme
- [Keyitdev/sddm-astronaut-theme](https://github.com/Keyitdev/sddm-astronaut-theme): inspiration and code reference;
- [Match-Yang/sddm-deepin](https://github.com/Match-Yang/sddm-deepin): inspiration and code reference;
- [qt/qtvirtualkeyboard](https://github.com/qt/qtvirtualkeyboard): code reference;
- [iconify.design](https://iconify.design/): icons

# Quick Start Guide for Translators

Welcome! This guide will help you start translating the slickSDDM login theme.

## What is SDDM?

SDDM is the login screen (display manager) that appears when you start your computer. This theme makes it look beautiful and professional!

## Step-by-Step: Start Translating

### 1. Create a Transifex Account

1. Go to: https://www.transifex.com/signup/
2. Sign up with your email or GitHub account
3. Verify your email address

### 2. Join Our Translation Project

1. Visit: https://www.transifex.com/ubuntu-budgie/slicksddm/
2. Click "Help Translate slicksddm"
3. Select your language
4. Click "Join team" and wait for approval (usually within 24 hours)

### 3. Start Translating

1. Once approved, click on your language
2. Click "Translate" next to "translations"
3. You'll see a list of English strings on the left
4. Click each string and type your translation on the right
5. Click "Save Translation" when done

## Important Rules

### Keep Special Text

Some strings have special parts that **must not be translated**:

❌ **WRONG:**
```
English: "Select user {name}"
Spanish: "Seleccionar usuario nombre"  ← {name} was removed!
```

✅ **CORRECT:**
```
English: "Select user {name}"
Spanish: "Seleccionar usuario {name}"  ← {name} kept!
```

### Keep It Short

The login screen has limited space. Try to keep translations similar in length to English:

✅ Good: "Iniciar sesión" (13 chars) for "Login" (5 chars)  
⚠️ OK: "Iniciar sesión en el sistema" (29 chars) - might not fit!

## String Context Guide

Here's what each string means and where it appears:

| English String | Where You'll See It | Tips |
|----------------|---------------------|------|
| "Press any key" | Lock screen, center of screen | Very visible, keep it short |
| "Username" | Login input field placeholder | Single word is best |
| "Password" | Password input field placeholder | Single word is best |
| "Login" | Button to log in | Short action word |
| "Logging in" | Shows while logging in | Present continuous tense |
| "Caps Lock is on" | Warning below password field | Important warning! |
| "Select user {name}" | Tooltip when hovering over user | Keep {name} placeholder! |
| "Suspend" | Power menu option | Action: put computer to sleep |
| "Reboot" | Power menu option | Action: restart computer |
| "Shutdown" | Power menu option | Action: turn off computer |

## Tips for Good Translations

### 1. Match the Tone

This is a professional login screen. Use:
- **Formal** tone for professional contexts
- **Simple** words everyone understands
- **Clear** instructions

### 2. Test If You Can

If you use Ubuntu Budgie, you can test your translations:
```bash
# Download your translation
# Copy to: /usr/share/sddm/themes/ubuntu-budgie-login/translations/
# Restart SDDM to see it
```

### 3. Be Consistent

If you translate "Login" as "Acceder", don't use "Entrar" elsewhere. Consistency helps users!

### 4. Ask for Help

Not sure about something? Use the Transifex comments:
1. Click the comment icon 💬 next to any string
2. Ask your question
3. Other translators and maintainers will help!

## Translation Progress

You can see how complete your language is:

- **0-30%**: Just getting started
- **30-70%**: Good progress! 
- **70-90%**: Almost complete!
- **90-100%**: Excellent! Ready for release!

Aim for at least **70% complete** before the translation is included in releases.

## Quality Checklist

Before marking your translation as complete:

- [ ] All strings are translated
- [ ] Placeholders like `{name}` are preserved
- [ ] No spelling mistakes
- [ ] Consistent terminology throughout
- [ ] Strings fit the UI context
- [ ] Tone is appropriate for a login screen

## Getting Help

### Common Questions

**Q: I made a mistake. Can I fix it?**  
A: Yes! Just find the string and edit your translation. It will update automatically.

**Q: Someone else translated my language. Can I improve it?**  
A: Yes! You can suggest a better translation, and reviewers will choose the best one.

**Q: My language isn't listed. Can I add it?**  
A: Yes! Contact the project maintainers to request your language be added.

**Q: How long until my translation appears in the theme?**  
A: Translations are pulled weekly and included in the next release, usually within 1-2 weeks.

### Contact

- **Transifex questions**: Use comments on strings
- **Technical issues**: [GitHub Issues](https://github.com/ubuntubudgie/slicksddm/issues)
- **General questions**: discourse.ubuntubudgie.org

## Thank You!

Your translations help make slickSDDM accessible to users around the world. Every string you translate helps someone use their computer in their native language.

**Happy translating!** 🌍 🎉

---

*For more detailed information, see [TRANSLATIONS.md](../TRANSLATIONS.md)*

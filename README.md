# macOS Natural Scrolling Toggle

A lightweight shell script that toggles **Natural Scrolling** on/off instantly via a keyboard shortcut — no clicking through System Settings required.

Works on **macOS Ventura (13), Sonoma (14), Sequoia (15), and Tahoe (26)**.

---

## The Problem

Modern macOS System Settings is built with SwiftUI and is nearly impossible to automate via UI scripting or AppleScript. Attempts using:

- `x-apple.systempreferences:` URLs
- `System Events` tab group / splitter group navigation
- Keyboard simulation (Tab, Arrow keys, Space)

...all fail with errors like:
```
System Events got an error: Can't get tab group 1 of group 2 of splitter group 1 ...
```

---

## The Solution

Instead of navigating the UI, we write directly to the macOS preference that controls scroll direction — the same value System Settings changes under the hood — and force the system to apply it immediately.

```bash
defaults write -g com.apple.swipescrolldirection -bool true/false
```

Then we call Apple's own internal tool to apply the change live without logging out:

```bash
/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
```

---

## Files

```
ns.sh       # The toggle script
README.md   # This file
```

---

## Setup

### Step 1 — Create the script

Open **Terminal** and run:

```bash
nano ~/ns.sh
```

Paste the following:

```bash
#!/bin/bash
current=$(defaults read -g com.apple.swipescrolldirection 2>/dev/null)
if [ "$current" = "1" ]; then
    defaults write -g com.apple.swipescrolldirection -bool false
    MSG="Natural Scrolling: OFF"
else
    defaults write -g com.apple.swipescrolldirection -bool true
    MSG="Natural Scrolling: ON"
fi

/System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u

osascript -e "display notification \"$MSG\" with title \"Scroll Direction\""
```

Save with `Ctrl+O` → `Enter` → `Ctrl+X`.

---

### Step 2 — Make it executable

```bash
chmod +x ~/ns.sh
```

---

### Step 3 — Test it

```bash
bash ~/ns.sh
```

You should see a macOS notification saying **"Natural Scrolling: ON"** or **"Natural Scrolling: OFF"**, and scrolling should change direction immediately.

To confirm the value toggled:

```bash
defaults read -g com.apple.swipescrolldirection
# 1 = Natural Scrolling ON
# 0 = Natural Scrolling OFF
```

---

### Step 4 — Assign a keyboard shortcut via Shortcuts app

1. Open the **Shortcuts** app (`⌘ + Space` → type *Shortcuts*)
2. Click **+** to create a new shortcut
3. Search for and add the **"Run Shell Script"** action
4. Paste this into the script box (replace `YOUR_USERNAME` with your actual username — run `whoami` in Terminal if unsure):

```bash
bash /Users/YOUR_USERNAME/ns.sh
```

5. Set **Shell** to `/bin/zsh` and **Input** to `No Input`
6. Click the shortcut name at the top → **Add Keyboard Shortcut**
7. Press your desired key combo (e.g. `⌃⌥⌘S`)
8. Done ✓

---

### Step 5 — Grant permissions (first run only)

The first time the shortcut runs, macOS may ask for permission. If prompted:

1. Go to **System Settings → Privacy & Security → Automation**
2. Allow **Shortcuts** to run shell scripts
3. If a notification says the script was blocked, click **Open System Settings** in the alert and grant access

---

## How it works

| Step | What happens |
|---|---|
| Read preference | `defaults read -g com.apple.swipescrolldirection` returns `1` (ON) or `0` (OFF) |
| Write preference | `defaults write -g` flips the boolean |
| Apply live | `activateSettings -u` tells macOS to re-read and apply the preference immediately |
| Notify | `osascript` sends a native macOS notification with the new state |

---

## Compatibility

| macOS Version | Version Number | Status |
|---|---|---|
| Ventura | 13 |   Tested compatible |
| Sonoma | 14 |   Tested compatible |
| Sequoia | 15 |   Tested compatible |
| **Tahoe** | **26** |   Tested compatible |

> **Note:** macOS Tahoe (26) was released September 15, 2025. It introduced the Liquid Glass UI redesign and is the last version to support Intel Macs. This script works on both Apple Silicon and Intel Macs running Tahoe.

---

## Troubleshooting

**Script runs but scrolling doesn't change**
- Make sure `activateSettings -u` is in your script (the key step that applies the change live)
- Try logging out and back in once — subsequent runs will be instant

**`chmod: Operation not permitted`**
- Don't use `/usr/local/bin` — it's protected on modern macOS
- Use `~/ns.sh` (your home directory) as shown above

**Shortcuts app doesn't trigger the script**
- Use the full path `/Users/YOUR_USERNAME/ns.sh` instead of `~/ns.sh` — Shortcuts may not expand `~`
- Make sure Shell is set to `/bin/zsh`

**Notification doesn't appear**
- Go to **System Settings → Notifications → Script Editor** and enable notifications


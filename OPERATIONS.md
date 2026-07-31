# Operations

Practical notes for running this configuration. Written after a debugging
session that produced an unbootable system twice; the preflight checks in
`rebuild.sh` exist because of it.

## Source of truth

**`~/dotfiles` is the only source of truth.** Rebuild from there:

```bash
cd ~/dotfiles
./rebuild.sh switch laptop
```

There used to be a second copy at `/etc/nixos/config`. Two copies is how this
setup broke: the machine was running a system built from one copy while the
other copy — the one being edited — carried a stale `flake.lock` and a
`hardware-configuration.nix` from a different laptop. If you ever find a second
copy again, delete it rather than syncing it.

`/etc/nixos/configuration.nix` is only read by a non-flake `nixos-rebuild`.
Since everything here goes through `--flake`, it is ignored.

## Preflight checks

`./rebuild.sh switch|test|boot <host>` runs two checks before touching the
system, and only when the target host is the machine you are on. Both are
warnings you can override with `y`, because building for the *other* host is
legitimate.

### 1. Hardware config matches this machine

Compares the disk devices in `hosts/<host>/hardware-configuration.nix` against
`nixos-generate-config --show-hardware-config`.

A stale `hardware-configuration.nix` **builds and switches without any error**
and only fails at boot. That is what makes it dangerous. The failure modes:

- Wrong `/boot` UUID → `boot.mount` fails → no `nofail` in fstab → systemd
  drops to **emergency mode**.
- Missing `boot.initrd.luks.devices` → the initrd cannot unlock the root
  filesystem → the machine never reaches userspace at all.

To regenerate:

```bash
nixos-generate-config --show-hardware-config > hosts/laptop/hardware-configuration.nix
```

Review the diff before committing. `nixos-generate-config` only lists kernel
modules for hardware attached *right now*, so it can drop modules a previous
generation had. Prefer the union. In particular keep `usbhid`: the root is
LUKS, so the passphrase prompt runs in the initrd, and without that driver a
USB keyboard cannot type it.

### 2. No accidental release downgrade

Compares `system.nixos.release` from the flake against `nixos-version`.

`flake.nix` pins nixpkgs to a **release branch**, so `nix flake update` alone
never crosses releases — it only moves within the pinned branch. Moving to a
new NixOS release means editing the branch names:

```nix
nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
home-manager.url = "github:nix-community/home-manager/release-26.05";
```

Leave `system.stateVersion` alone. It records the release the system was first
installed at, for data-migration purposes; it is not a version to keep current.

A one-line manual version of this check:

```bash
readlink -f /run/booted-system   # compare against what the flake produces
```

## Recovering from a bad generation

The bootloader default follows `/nix/var/nix/profiles/system`, **not** whatever
you picked in the boot menu. Selecting an older generation at boot gets you in,
but the next reboot goes back to the broken default. To actually repoint it:

```bash
sudo nixos-rebuild --rollback boot
```

Or explicitly:

```bash
sudo nix-env --rollback -p /nix/var/nix/profiles/system
sudo /nix/var/nix/profiles/system/bin/switch-to-configuration boot
```

Check what will boot next:

```bash
cat /boot/loader/loader.conf                 # the default entry
readlink -f /nix/var/nix/profiles/system     # what that entry points at
```

If `/boot` is not mounted, the bootloader install silently writes into a plain
directory on the root filesystem and the real ESP keeps its old entries. Verify
with `mount | grep /boot` before trusting a switch.

## Machine notes: ThinkPad T14 Gen 6

### The `/ ?` key

ThinkPad ABNT2 keyboards wire the `/ ? °` key to the `<RCTL>` keycode (105)
instead of `<AB11>` (97), where `br(abnt2)` expects it. Under the plain layout
the key is dead. Fixed in `hosts/laptop/configuration.nix`:

```nix
services.xserver.xkb.variant = "thinkpad";
```

That variant is just `br(abnt2)` with `<RCTL>` remapped. It is set per-host, so
the desktop keeps a normal right Ctrl.

This only applies when X starts. After changing it, a running session keeps the
old keymap until you log out, or you can apply it live:

```bash
setxkbmap -layout br -variant thinkpad -option terminate:ctrl_alt_bksp
```

### Media and brightness keys

The Fn keys are **secondary**: `F1`/`F2`/`F3` send `XF86AudioMute` /
`LowerVolume` / `RaiseVolume` and `F5`/`F6` send `MonBrightnessDown` / `Up`
when pressed **without Fn**. Pressing Fn+F1 sends a literal `F1`. Toggle with
Fn+Esc (FnLock) or in the BIOS.

The bindings live in `home/programs/xmonad/config.hs`:

- Audio uses `wpctl` (WirePlumber). Not `amixer` — there is no ALSA `Master`
  control under PipeWire, and `alsa-utils` is not installed.
- Brightness uses `brightnessctl`. Not `xbacklight`, which gets
  `Permission denied` writing to `/sys/class/backlight/*/brightness`.

`brightnessctl` works without root via systemd-logind's D-Bus interface, so it
does not depend on the udev rules or the `input` group. Those are configured in
`hosts/common.nix` as a direct-sysfs fallback; note udev rules only fire on
`ACTION=="add"`, so they take effect at the next boot, not at switch time.

### Keyboard backlight

Handled entirely by the embedded controller. `KEY_KBDILLUMTOGGLE` is not in the
keyboard's keymap, so Fn+Space never reaches X and an xmonad binding for it
would be dead code. Read the state with:

```bash
cat /sys/class/leds/tpacpi::kbd_backlight/brightness   # 0..2
```

## Polybar

`services.polybar.script` redirects each bar's stderr into
`~/.config/polybar/logs/`, and creates that directory first. Without the
`mkdir -p` the redirect fails before polybar ever runs — and because the unit is
`Type=forking`, systemd reports the service as **started successfully** while
nothing is running.

Home Manager recreates `~/.config/polybar` during activation and removes
`logs/` with it. A switch can therefore race the service into
`start-limit-hit`, leaving it `failed` and not retrying. Recover with:

```bash
systemctl --user reset-failed polybar
systemctl --user restart polybar
```

## Things that need a re-login or reboot

| Change | When it applies |
| --- | --- |
| `services.xserver.xkb.*` | next X start (or `setxkbmap` now) |
| `users.users.*.extraGroups` | next login |
| `services.udev.packages` | next boot, or on device re-add |
| xmonad keybindings | `xmonad --restart` (keeps windows; PID stays, it re-execs) |
| polybar config | `systemctl --user restart polybar` |

## Slow builds

Two packages in this config have no binary in the cache and compile from
source, which is the difference between a 3-minute and a multi-hour rebuild:

- **MongoDB** — not distributed as a binary because of its SSPL license. It was
  removed from this config; `services.mongodb.enable` will bring it back.
- **stremio-linux-shell** — also removed.

`mongodb-compass` (GUI client) and the `networking.hosts` entry mapping
`mongodb` to `127.0.0.1` were kept, so connecting to a Mongo in Docker or on a
remote host still works.

Check before committing to a long build:

```bash
nix path-info --store https://cache.nixos.org <store-path>
```

`error: path ... is not valid` means it will be built locally.

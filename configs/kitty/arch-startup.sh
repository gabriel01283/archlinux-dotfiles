#!/usr/bin/env bash
[[ -t 1 ]] || exit 0

python - <<'INNER'
import os
import re
import shutil
import subprocess
import sys

cols, rows = shutil.get_terminal_size((120, 30))

if cols < 105 or rows < 18:
    sys.exit(0)

# Mesmo desenho tradicional do Arch, reduzido
logo = ['              /\\              ', '             /  \\             ', '            /    \\            ', '           /      \\           ', '          /        \\          ', '         /          \\         ', '        /            \\        ', '       /      /\\      \\       ', '      /      /  \\      \\      ', '     /      /    \\      \\     ', '    /      /      \\      \\    ', "   /__-''            ''-__\\   "]

BLUE = "\033[38;2;56;189;248m"
PURPLE = "\033[1;38;2;56;189;248m"
CYAN = "\033[38;2;34;211;238m"
NAME_PURPLE = "\033[38;2;192;132;252m"
WHITE = "\033[38;2;220;227;237m"
RESET = "\033[0m"

def command(*args):
    try:
        return subprocess.check_output(
            args, text=True, stderr=subprocess.DEVNULL
        ).strip()
    except Exception:
        return "N/A"

def get_os():
    try:
        data = Path("/etc/os-release").read_text()
        match = re.search(r'^PRETTY_NAME="?([^"\n]+)', data, re.M)
        return match.group(1) if match else "Arch Linux"
    except Exception:
        return "Arch Linux"

from pathlib import Path

os_name = get_os()
kernel = command("uname", "-r")
wm = os.environ.get("XDG_CURRENT_DESKTOP", "Hyprland")
terminal = "kitty"
cpu = "AMD Ryzen 7 4800HS"
gpu = "AMD Radeon Vega"

try:
    mem = Path("/proc/meminfo").read_text()
    total = int(re.search(r"MemTotal:\s+(\d+)", mem).group(1))
    available = int(re.search(r"MemAvailable:\s+(\d+)", mem).group(1))
    used = total - available
    ram = f"{used/1048576:.2f} / {total/1048576:.2f} GiB ({used/total:.0%})"
except Exception:
    ram = "N/A"

disk = shutil.disk_usage("/")
disk_text = (
    f"{disk.used/1073741824:.2f} / "
    f"{disk.total/1073741824:.2f} GiB "
    f"({disk.used/disk.total:.0%})"
)

uptime = command("uptime", "-p").replace("up ", "")
packages = command("bash", "-lc", "pacman -Qq | wc -l")

items = [
    ("OS", os_name),
    ("Kernel", kernel),
    ("WM", wm),
    ("Terminal", terminal),
    ("CPU", cpu),
    ("GPU", gpu),
    ("RAM", ram),
    ("Disk", disk_text),
    ("Uptime", uptime),
    ("Packages", packages)
]

username = os.environ.get("USER", "user")
hostname = os.environ.get("HOSTNAME") or command("hostname")
if hostname == "N/A":
    hostname = Path("/etc/hostname").read_text().strip()

header = [
    f"{WHITE}{username}{NAME_PURPLE}@{hostname}{RESET}",
    f"{WHITE}{'-' * (len(username) + len(hostname) + 1)}{RESET}",
    f"{WHITE}SYSTEM: ARCH + HYPRLAND{RESET}"
]

label_width = 10
LABEL_COLORS = {
    "OS": "\033[38;2;56;189;248m",
    "Kernel": "\033[38;2;244;114;182m",
    "WM": "\033[38;2;167;139;250m",
    "Terminal": "\033[38;2;45;212;191m",
    "CPU": "\033[38;2;251;191;36m",
    "GPU": "\033[38;2;251;146;60m",
    "RAM": "\033[38;2;74;222;128m",
    "Disk": "\033[38;2;232;121;249m",
    "Uptime": "\033[38;2;248;113;113m",
    "Packages": "\033[38;2;129;140;248m",
}

specs = header + [
    f"{LABEL_COLORS[name]}{name + ':':<{label_width}}{RESET} {WHITE}{value}{RESET}"
    for name, value in items
]

logo_width = max(map(len, logo))
plain_width = max(
    len(re.sub(r'\033\[[0-9;]*m', '', line))
    for line in specs
)

block_width = logo_width + 3 + plain_width
start = cols - block_width - 3

# Não invade a região do prompt
if start < 35:
    sys.exit(0)

sys.stdout.write("\033[2J\033[H\0337")

height = max(len(logo) + 1, len(specs))

for i in range(min(height, rows - 2)):
    left = logo[i - 1] if 1 <= i < len(logo) + 1 else ""
    right = specs[i] if i < len(specs) else ""

    if left:
        sys.stdout.write(f"\033[{i+1};{max(1, start-1)}H")
        sys.stdout.write(BLUE + left + RESET)

    if right:
        sys.stdout.write(f"\033[{i+1};{start+logo_width+4}H")
        sys.stdout.write(right)

sys.stdout.write("\0338\033[1;1H")
sys.stdout.flush()
INNER

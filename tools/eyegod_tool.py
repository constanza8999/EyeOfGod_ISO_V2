#!/usr/bin/env python3
"""
╔══════════════════════════════════════════════════════════════════════════╗
║  EYE OF GOD V∞ × KALI PURPLE — Windows Release Tool                    ║
║  GUI application for building and flashing custom Kali Linux ISO        ║
╚══════════════════════════════════════════════════════════════════════════╝
"""

import os
import sys
import subprocess
import threading
import shutil
import tkinter as tk
from tkinter import ttk, filedialog, messagebox, scrolledtext
from pathlib import Path
from datetime import datetime

# ── Colors (Cyberpunk Theme) ───────────────────────────────────────────────
COLORS = {
    'bg_primary': '#0a0000',
    'bg_secondary': '#120808',
    'bg_card': '#1a0a0a',
    'bg_terminal': '#0d0505',
    'text_primary': '#f0e6e6',
    'text_secondary': '#a08080',
    'text_muted': '#604040',
    'accent_red': '#ff1a1a',
    'accent_gold': '#ffd700',
    'accent_dark_red': '#8b0000',
    'accent_maroon': '#4a0000',
    'matrix_green': '#00ff41',
    'border_color': '#2a1010',
}


def check_powershell():
    """Check if PowerShell is available"""
    return shutil.which("powershell") is not None or shutil.which("pwsh") is not None


class EyeGodTool:
    """Main application class for Eye of God Windows Release Tool"""

    def __init__(self, root):
        self.root = root
        self.setup_window()
        self.create_widgets()
        self.project_root = self.find_project_root()

    def setup_window(self):
        """Configure main window"""
        self.root.title("👁 Eye of God V∞ × Kali Purple — Windows Release Tool")
        self.root.geometry("900x700")
        self.root.minsize(800, 600)
        self.root.configure(bg=COLORS['bg_primary'])

        # Center window
        self.root.update_idletasks()
        x = (self.root.winfo_screenwidth() // 2) - (900 // 2)
        y = (self.root.winfo_screenheight() // 2) - (700 // 2)
        self.root.geometry(f"900x700+{x}+{y}")

    def find_project_root(self):
        """Find project root directory - handles both source and packaged EXE"""
        # When running as EXE, __file__ won't resolve to source tree
        if getattr(sys, 'frozen', False):
            # Running as packaged EXE
            exe_dir = Path(sys.executable).parent
            # Check if we're in the project root
            if (exe_dir / "scripts").exists() and (exe_dir / "website").exists():
                return exe_dir
            # Check parent directory
            if (exe_dir.parent / "scripts").exists() and (exe_dir.parent / "website").exists():
                return exe_dir.parent
            # Fall back to current working directory
            cwd = Path.cwd()
            if (cwd / "scripts").exists() and (cwd / "website").exists():
                return cwd
            return exe_dir
        else:
            # Running as source
            possible_roots = [
                Path(__file__).parent.parent,
                Path.cwd(),
            ]
            for root in possible_roots:
                if (root / "scripts").exists() and (root / "website").exists():
                    return root
            return Path.cwd()

    def create_widgets(self):
        """Create all GUI widgets"""
        main_frame = tk.Frame(self.root, bg=COLORS['bg_primary'])
        main_frame.pack(fill=tk.BOTH, expand=True, padx=20, pady=20)

        self.create_header(main_frame)
        self.create_notebook(main_frame)
        self.create_status_bar(main_frame)

    def create_header(self, parent):
        """Create application header"""
        header_frame = tk.Frame(parent, bg=COLORS['bg_primary'])
        header_frame.pack(fill=tk.X, pady=(0, 20))

        title_label = tk.Label(
            header_frame,
            text="👁 EYE OF GOD V∞",
            font=('Consolas', 24, 'bold'),
            fg=COLORS['accent_red'],
            bg=COLORS['bg_primary']
        )
        title_label.pack(side=tk.LEFT)

        subtitle_label = tk.Label(
            header_frame,
            text="× KALI PURPLE — WINDOWS RELEASE TOOL",
            font=('Consolas', 12),
            fg=COLORS['accent_gold'],
            bg=COLORS['bg_primary']
        )
        subtitle_label.pack(side=tk.LEFT, padx=(10, 0), pady=(8, 0))

        version_label = tk.Label(
            header_frame,
            text=f"v2025.3.1 | {datetime.now().strftime('%Y-%m-%d')}",
            font=('Consolas', 10),
            fg=COLORS['text_muted'],
            bg=COLORS['bg_primary']
        )
        version_label.pack(side=tk.RIGHT, pady=(8, 0))

    def create_notebook(self, parent):
        """Create tabbed notebook"""
        style = ttk.Style()
        style.theme_use('clam')
        style.configure('TNotebook',
                        background=COLORS['bg_primary'],
                        borderwidth=0)
        style.configure('TNotebook.Tab',
                        background=COLORS['bg_secondary'],
                        foreground=COLORS['text_secondary'],
                        padding=[20, 10],
                        font=('Consolas', 10))
        style.map('TNotebook.Tab',
                  background=[('selected', COLORS['bg_card'])],
                  foreground=[('selected', COLORS['accent_red'])])

        self.notebook = ttk.Notebook(parent, style='TNotebook')
        self.notebook.pack(fill=tk.BOTH, expand=True)

        self.create_flash_tab()
        self.create_build_tab()
        self.create_disks_tab()
        self.create_about_tab()

    def create_flash_tab(self):
        """Create flash ISO tab"""
        tab = tk.Frame(self.notebook, bg=COLORS['bg_primary'])
        self.notebook.add(tab, text="  🔥 Flash ISO  ")

        title = tk.Label(
            tab,
            text="Flash ISO to USB/HDD",
            font=('Consolas', 16, 'bold'),
            fg=COLORS['accent_gold'],
            bg=COLORS['bg_primary']
        )
        title.pack(pady=(20, 10))

        # ISO Selection
        iso_frame = tk.Frame(tab, bg=COLORS['bg_primary'])
        iso_frame.pack(fill=tk.X, padx=40, pady=10)

        iso_label = tk.Label(
            iso_frame,
            text="ISO File:",
            font=('Consolas', 10),
            fg=COLORS['text_secondary'],
            bg=COLORS['bg_primary']
        )
        iso_label.pack(side=tk.LEFT)

        self.iso_path_var = tk.StringVar()
        iso_entry = tk.Entry(
            iso_frame,
            textvariable=self.iso_path_var,
            font=('Consolas', 10),
            bg=COLORS['bg_terminal'],
            fg=COLORS['matrix_green'],
            insertbackground=COLORS['matrix_green'],
            relief=tk.FLAT,
            bd=5
        )
        iso_entry.pack(side=tk.LEFT, fill=tk.X, expand=True, padx=(10, 10))

        browse_btn = tk.Button(
            iso_frame,
            text="Browse...",
            font=('Consolas', 10),
            bg=COLORS['accent_dark_red'],
            fg=COLORS['text_primary'],
            activebackground=COLORS['accent_red'],
            activeforeground=COLORS['text_primary'],
            relief=tk.FLAT,
            command=self.browse_iso
        )
        browse_btn.pack(side=tk.RIGHT)

        # Disk Selection
        disk_frame = tk.Frame(tab, bg=COLORS['bg_primary'])
        disk_frame.pack(fill=tk.X, padx=40, pady=10)

        disk_label = tk.Label(
            disk_frame,
            text="Disk Number:",
            font=('Consolas', 10),
            fg=COLORS['text_secondary'],
            bg=COLORS['bg_primary']
        )
        disk_label.pack(side=tk.LEFT)

        self.disk_number_var = tk.StringVar(value="1")
        disk_entry = tk.Entry(
            disk_frame,
            textvariable=self.disk_number_var,
            font=('Consolas', 10),
            bg=COLORS['bg_terminal'],
            fg=COLORS['matrix_green'],
            insertbackground=COLORS['matrix_green'],
            relief=tk.FLAT,
            bd=5,
            width=10
        )
        disk_entry.pack(side=tk.LEFT, padx=(10, 10))

        # Flash Button
        flash_btn = tk.Button(
            tab,
            text="🔥 FLASH ISO",
            font=('Consolas', 14, 'bold'),
            bg=COLORS['accent_red'],
            fg=COLORS['text_primary'],
            activebackground=COLORS['accent_dark_red'],
            activeforeground=COLORS['text_primary'],
            relief=tk.FLAT,
            command=self.flash_iso,
            height=2
        )
        flash_btn.pack(fill=tk.X, padx=40, pady=20)

        self.create_output_area(tab)

    def create_build_tab(self):
        """Create build ISO tab"""
        tab = tk.Frame(self.notebook, bg=COLORS['bg_primary'])
        self.notebook.add(tab, text="  🛠 Build ISO  ")

        title = tk.Label(
            tab,
            text="Build ISO via WSL2",
            font=('Consolas', 16, 'bold'),
            fg=COLORS['accent_gold'],
            bg=COLORS['bg_primary']
        )
        title.pack(pady=(20, 10))

        self.wsl_status_var = tk.StringVar(value="Checking WSL status...")
        status_label = tk.Label(
            tab,
            textvariable=self.wsl_status_var,
            font=('Consolas', 10),
            fg=COLORS['text_secondary'],
            bg=COLORS['bg_primary']
        )
        status_label.pack(pady=10)

        setup_btn = tk.Button(
            tab,
            text="⚙️ Setup WSL (One-time)",
            font=('Consolas', 12, 'bold'),
            bg=COLORS['accent_gold'],
            fg=COLORS['bg_primary'],
            activebackground=COLORS['accent_dark_red'],
            activeforeground=COLORS['text_primary'],
            relief=tk.FLAT,
            command=self.setup_wsl,
            height=2
        )
        setup_btn.pack(fill=tk.X, padx=40, pady=10)

        build_btn = tk.Button(
            tab,
            text="🔨 Build ISO",
            font=('Consolas', 14, 'bold'),
            bg=COLORS['accent_red'],
            fg=COLORS['text_primary'],
            activebackground=COLORS['accent_dark_red'],
            activeforeground=COLORS['text_primary'],
            relief=tk.FLAT,
            command=self.build_iso,
            height=2
        )
        build_btn.pack(fill=tk.X, padx=40, pady=10)

        self.create_output_area(tab)

    def create_disks_tab(self):
        """Create disks tab"""
        tab = tk.Frame(self.notebook, bg=COLORS['bg_primary'])
        self.notebook.add(tab, text="  💾 Disks  ")

        title = tk.Label(
            tab,
            text="Available Disks",
            font=('Consolas', 16, 'bold'),
            fg=COLORS['accent_gold'],
            bg=COLORS['bg_primary']
        )
        title.pack(pady=(20, 10))

        refresh_btn = tk.Button(
            tab,
            text="🔄 Refresh Disk List",
            font=('Consolas', 12, 'bold'),
            bg=COLORS['accent_dark_red'],
            fg=COLORS['text_primary'],
            activebackground=COLORS['accent_red'],
            activeforeground=COLORS['text_primary'],
            relief=tk.FLAT,
            command=self.list_disks,
            height=2
        )
        refresh_btn.pack(fill=tk.X, padx=40, pady=10)

        self.create_output_area(tab)

    def create_about_tab(self):
        """Create about tab"""
        tab = tk.Frame(self.notebook, bg=COLORS['bg_primary'])
        self.notebook.add(tab, text="  ℹ️ About  ")

        title = tk.Label(
            tab,
            text="Eye of God V∞ × Kali Purple",
            font=('Consolas', 20, 'bold'),
            fg=COLORS['accent_red'],
            bg=COLORS['bg_primary']
        )
        title.pack(pady=(40, 20))

        eye_label = tk.Label(
            tab,
            text="👁",
            font=('Arial', 60),
            bg=COLORS['bg_primary']
        )
        eye_label.pack(pady=20)

        desc_text = """
A custom Kali Linux live ISO designed to run from external HDD/USB.
Combines Kali Purple's offensive/defensive power with the Eye of God
procedural consciousness framework.

Features:
• 40+ GRUB boot entries
• 10,000 procedural subsystems
• 20 consciousness levels (0 to ∞)
• LUKS2 encryption support
• Windows PowerShell scripts
• BIOS + UEFI hybrid boot

Website: https://constanza8999.github.io/EyeOfGod_ISO_V2/
GitHub: https://github.com/constanza8999/EyeOfGod_ISO_V2

License: MIT License
"""
        desc_label = tk.Label(
            tab,
            text=desc_text,
            font=('Consolas', 10),
            fg=COLORS['text_secondary'],
            bg=COLORS['bg_primary'],
            justify=tk.LEFT
        )
        desc_label.pack(padx=40, pady=20)

        links_frame = tk.Frame(tab, bg=COLORS['bg_primary'])
        links_frame.pack(pady=20)

        website_btn = tk.Button(
            links_frame,
            text="🌐 Website",
            font=('Consolas', 10),
            bg=COLORS['accent_dark_red'],
            fg=COLORS['text_primary'],
            activebackground=COLORS['accent_red'],
            activeforeground=COLORS['text_primary'],
            relief=tk.FLAT,
            command=lambda: self.open_url("https://constanza8999.github.io/EyeOfGod_ISO_V2/")
        )
        website_btn.pack(side=tk.LEFT, padx=10)

        github_btn = tk.Button(
            links_frame,
            text="📁 GitHub",
            font=('Consolas', 10),
            bg=COLORS['accent_dark_red'],
            fg=COLORS['text_primary'],
            activebackground=COLORS['accent_red'],
            activeforeground=COLORS['text_primary'],
            relief=tk.FLAT,
            command=lambda: self.open_url("https://github.com/constanza8999/EyeOfGod_ISO_V2")
        )
        github_btn.pack(side=tk.LEFT, padx=10)

    def open_url(self, url):
        """Open URL cross-platform"""
        try:
            if sys.platform == 'win32':
                os.startfile(url)
            elif sys.platform == 'darwin':
                subprocess.run(['open', url], check=True)
            else:
                subprocess.run(['xdg-open', url], check=True)
        except Exception as e:
            self.log(f"Could not open URL: {e}", "error")

    def create_output_area(self, parent):
        """Create output text area"""
        output_frame = tk.Frame(parent, bg=COLORS['bg_terminal'], bd=1, relief=tk.SUNKEN)
        output_frame.pack(fill=tk.BOTH, expand=True, padx=40, pady=(10, 20))

        header_bar = tk.Frame(output_frame, bg=COLORS['bg_secondary'])
        header_bar.pack(fill=tk.X)

        header_label = tk.Label(
            header_bar,
            text="  ● ● ●  CONSOLE OUTPUT",
            font=('Consolas', 9),
            fg=COLORS['text_muted'],
            bg=COLORS['bg_secondary'],
            anchor=tk.W
        )
        header_label.pack(fill=tk.X, padx=10, pady=5)

        self.output_text = scrolledtext.ScrolledText(
            output_frame,
            font=('Consolas', 10),
            bg=COLORS['bg_terminal'],
            fg=COLORS['matrix_green'],
            insertbackground=COLORS['matrix_green'],
            selectbackground=COLORS['accent_dark_red'],
            selectforeground=COLORS['text_primary'],
            relief=tk.FLAT,
            bd=10,
            wrap=tk.WORD,
            state=tk.DISABLED
        )
        self.output_text.pack(fill=tk.BOTH, expand=True)

        # Configure text tags for colored output
        self.output_text.tag_config('info', foreground=COLORS['matrix_green'])
        self.output_text.tag_config('warning', foreground=COLORS['accent_gold'])
        self.output_text.tag_config('error', foreground=COLORS['accent_red'])
        self.output_text.tag_config('success', foreground=COLORS['matrix_green'])

    def create_status_bar(self, parent):
        """Create status bar"""
        status_frame = tk.Frame(parent, bg=COLORS['bg_secondary'], bd=1, relief=tk.SUNKEN)
        status_frame.pack(fill=tk.X, pady=(10, 0))

        self.status_var = tk.StringVar(value="Ready")
        status_label = tk.Label(
            status_frame,
            textvariable=self.status_var,
            font=('Consolas', 9),
            fg=COLORS['text_muted'],
            bg=COLORS['bg_secondary'],
            anchor=tk.W
        )
        status_label.pack(fill=tk.X, padx=10, pady=5)

    def log(self, message, level="info"):
        """Log message to output area (thread-safe)"""
        def _do_log():
            self.output_text.configure(state=tk.NORMAL)
            timestamp = datetime.now().strftime("%H:%M:%S")

            if level == "info":
                prefix = "[INFO ]"
            elif level == "warning":
                prefix = "[WARN ]"
            elif level == "error":
                prefix = "[FAIL ]"
            elif level == "success":
                prefix = "[  OK ]"
            else:
                prefix = ""

            self.output_text.insert(tk.END, f"{timestamp} {prefix} {message}\n", level)
            self.output_text.see(tk.END)
            self.output_text.configure(state=tk.DISABLED)

        self.root.after(0, _do_log)

    def update_status(self, message):
        """Update status bar (thread-safe)"""
        self.root.after(0, lambda: self.status_var.set(message))

    def browse_iso(self):
        """Browse for ISO file"""
        filename = filedialog.askopenfilename(
            title="Select ISO File",
            filetypes=[
                ("ISO files", "*.iso"),
                ("All files", "*.*")
            ]
        )
        if filename:
            self.iso_path_var.set(filename)
            self.log(f"Selected ISO: {filename}")

    def flash_iso(self):
        """Flash ISO to disk"""
        iso_path = self.iso_path_var.get()
        disk_number = self.disk_number_var.get()

        if not iso_path:
            messagebox.showerror("Error", "Please select an ISO file")
            return

        if not os.path.exists(iso_path):
            messagebox.showerror("Error", f"ISO file not found:\n{iso_path}")
            return

        if not disk_number:
            messagebox.showerror("Error", "Please enter a disk number")
            return

        # Validate disk number
        try:
            disk_int = int(disk_number)
            if disk_int < 0 or disk_int > 99:
                messagebox.showerror("Error", "Disk number must be between 0 and 99")
                return
        except ValueError:
            messagebox.showerror("Error", "Disk number must be a valid integer")
            return

        # Check PowerShell availability
        if not check_powershell():
            messagebox.showerror("Error", "PowerShell not found. Please install PowerShell.")
            return

        # Confirmation
        confirm = messagebox.askyesno(
            "Confirm Flash",
            f"⚠️ WARNING: All data on Disk {disk_number} will be ERASED!\n\n"
            f"ISO: {iso_path}\n"
            f"Disk: {disk_number}\n\n"
            f"Are you sure you want to continue?"
        )

        if not confirm:
            self.log("Operation cancelled by user", "warning")
            return

        # Run flash in background thread
        def flash_thread():
            self.update_status("Flashing ISO...")
            self.log("Starting flash operation...")
            self.log(f"ISO: {iso_path}")
            self.log(f"Disk: {disk_number}")

            try:
                ps_script = f'''
$ErrorActionPreference = "Stop"
$physicalPath = "\\\\.\\PhysicalDrive{disk_number}"

Write-Host "Flashing ISO to disk {disk_number}..."
Write-Host "This may take several minutes. Do not disconnect the disk."

if (Get-Command dd.exe -ErrorAction SilentlyContinue) {{
    dd.exe if="{iso_path}" of=$physicalPath bs=4M --progress
}} elseif (Get-Command rufus.exe -ErrorAction SilentlyContinue) {{
    Write-Host "Opening Rufus..."
    Start-Process rufus.exe -ArgumentList "`"{iso_path}`"" -Wait
}} else {{
    Write-Host "No flash tool found. Please install dd or Rufus."
    exit 1
}}

Write-Host "Flash completed successfully!"
'''
                result = subprocess.run(
                    ['powershell', '-ExecutionPolicy', 'Bypass', '-Command', ps_script],
                    capture_output=True,
                    text=True,
                    timeout=1800
                )

                if result.returncode == 0:
                    self.log("Flash completed successfully!", "success")
                    if result.stdout.strip():
                        self.log(result.stdout.strip(), "info")
                else:
                    self.log(f"Flash failed: {result.stderr}", "error")

            except subprocess.TimeoutExpired:
                self.log("Flash operation timed out", "error")
            except Exception as e:
                self.log(f"Error: {str(e)}", "error")
            finally:
                self.update_status("Ready")

        thread = threading.Thread(target=flash_thread, daemon=True)
        thread.start()

    def setup_wsl(self):
        """Setup WSL for building"""
        def setup_thread():
            self.update_status("Setting up WSL...")
            self.log("Setting up WSL with Kali Linux...")

            try:
                ps_script = '''
$ErrorActionPreference = "Stop"

Write-Host "Checking WSL installation..."
$wslInstalled = Get-Command wsl.exe -ErrorAction SilentlyContinue
if (-not $wslInstalled) {
    Write-Host "Installing WSL2..."
    dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
    dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart
    Write-Host "Please restart your computer and run this again."
    exit 0
}

Write-Host "Configuring WSL 2..."
wsl --set-default-version 2

Write-Host "Checking for Kali Linux..."
$kaliInstalled = wsl -l --quiet 2>$null | Select-String -SimpleMatch "kali"
if (-not $kaliInstalled) {
    Write-Host "Installing Kali Linux..."
    wsl --install -d kali-linux
    Write-Host "Kali Linux installed. Please set up your user when prompted."
} else {
    Write-Host "Kali Linux already installed."
}

Write-Host "WSL setup complete!"
'''
                result = subprocess.run(
                    ['powershell', '-ExecutionPolicy', 'Bypass', '-Command', ps_script],
                    capture_output=True,
                    text=True,
                    timeout=600
                )

                if result.returncode == 0:
                    self.log("WSL setup completed!", "success")
                    if result.stdout.strip():
                        self.log(result.stdout.strip(), "info")
                else:
                    self.log(f"WSL setup failed: {result.stderr}", "error")

            except Exception as e:
                self.log(f"Error: {str(e)}", "error")
            finally:
                self.update_status("Ready")

        thread = threading.Thread(target=setup_thread, daemon=True)
        thread.start()

    def build_iso(self):
        """Build ISO via WSL"""
        def build_thread():
            self.update_status("Building ISO...")
            self.log("Starting ISO build process...")
            self.log("This may take 15-30 minutes...")

            try:
                ps_script = f'''
$ErrorActionPreference = "Stop"

$wslUser = wsl whoami 2>$null
if (-not $wslUser) {{ $wslUser = "user" }}

$projectRoot = Resolve-Path "{self.project_root}"
$wslPath = "/home/$wslUser/eyegod_iso_v2"

Write-Host "Copying project to WSL..."
$wslProjectRoot = wsl wslpath "$projectRoot" 2>$null
if (-not $wslProjectRoot) {{
    $drive = $projectRoot.Substring(0,1).ToLower()
    $rest = $projectRoot.Substring(2) -replace '\\\\','/'
    $wslProjectRoot = "/mnt/$drive$rest"
}}

wsl mkdir -p "$wslPath"
wsl cp -r "$wslProjectRoot/." "$wslPath/" 2>$null

Write-Host "Installing dependencies..."
wsl -d kali-linux --exec bash -c "cd '$wslPath' && sudo apt update -qq && sudo apt install -y --no-install-recommends xorriso squashfs-tools debootstrap grub-pc-bin grub-efi-amd64-bin mtools dosfstools live-build live-boot cryptsetup-bin curl wget python3 2>&1 | tail -5"

Write-Host "Building ISO..."
wsl -d kali-linux --exec bash -c "cd '$wslPath' && sudo bash scripts/build_kali_hdd.sh --clean ."

Write-Host "Copying ISO to Windows..."
$isoName = "EyeOfGod_KaliPurple_2025.3_HDD.iso"
$wslIso = "$wslPath/$isoName"
wsl cp "$wslIso" "/mnt/c/Users/$env:USERNAME/Desktop/" 2>$null

Write-Host "Build complete! ISO saved to Desktop."
'''
                result = subprocess.run(
                    ['powershell', '-ExecutionPolicy', 'Bypass', '-Command', ps_script],
                    capture_output=True,
                    text=True,
                    timeout=2400
                )

                if result.returncode == 0:
                    self.log("ISO build completed!", "success")
                    if result.stdout.strip():
                        self.log(result.stdout.strip(), "info")
                else:
                    self.log(f"Build failed: {result.stderr}", "error")

            except Exception as e:
                self.log(f"Error: {str(e)}", "error")
            finally:
                self.update_status("Ready")

        thread = threading.Thread(target=build_thread, daemon=True)
        thread.start()

    def list_disks(self):
        """List available disks"""
        def list_thread():
            self.update_status("Listing disks...")
            self.log("Scanning for available disks...")

            try:
                ps_script = '''
Get-Disk | Where-Object { $_.BusType -ne 'File Backed Virtual' -and $_.Size -gt 10GB } |
    Sort-Object Number |
    Format-Table -AutoSize -Property `
        @{N="Number";E={$_.Number}},
        @{N="Size";E={"{0:N0} GB" -f ($_.Size / 1GB)}},
        @{N="Type";E={$_.BusType}},
        @{N="Style";E={$_.PartitionStyle}},
        @{N="Status";E={if($_.OperationalStatus -eq "Online"){"Online"}else{$_.OperationalStatus}}},
        @{N="System";E={if($_.IsSystem -or $_.IsBoot){"⚠ SYSTEM"}else{""}}}
'''
                result = subprocess.run(
                    ['powershell', '-ExecutionPolicy', 'Bypass', '-Command', ps_script],
                    capture_output=True,
                    text=True,
                    timeout=30
                )

                if result.returncode == 0:
                    self.log("Available disks:", "info")
                    if result.stdout.strip():
                        self.log(result.stdout.strip(), "info")
                else:
                    self.log(f"Failed to list disks: {result.stderr}", "error")

            except Exception as e:
                self.log(f"Error: {str(e)}", "error")
            finally:
                self.update_status("Ready")

        thread = threading.Thread(target=list_thread, daemon=True)
        thread.start()


def main():
    """Main entry point"""
    root = tk.Tk()
    app = EyeGodTool(root)
    root.mainloop()


if __name__ == "__main__":
    main()

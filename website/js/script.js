/* ═══════════════════════════════════════════════════════════════════════════╗
   ║  EYE OF GOD V∞ × KALI PURPLE — GitHub Pages Scripts                  ║
   ║  Features: Matrix rain, terminal, scroll progress, FABs, palette     ║
   ╚══════════════════════════════════════════════════════════════════════════╝ */

'use strict';

/* ── Constants ──────────────────────────────────────────────────────────────── */
const IS_TOUCH_DEVICE = 'ontouchstart' in window;

/* ── Utility: Debounce ──────────────────────────────────────────────────────── */
function debounce(fn, delay) {
    let timer;
    return (...args) => {
        clearTimeout(timer);
        timer = setTimeout(() => fn(...args), delay);
    };
}

/* ── Loading Screen ─────────────────────────────────────────────────────────── */
function initLoadingScreen() {
    const loadingScreen = document.getElementById('loadingScreen');
    const fillBar = loadingScreen ? loadingScreen.querySelector('.loading-bar-fill') : null;
    if (!loadingScreen || !fillBar) return;

    const subtexts = [
        'Loading subsystems...',
        'Initializing Eye of God...',
        'Connecting WebSocket bridge...',
        'Generating 10,000 entities...',
        'Calibrating consciousness...',
        'Awakening the Eye...'
    ];

    const subtextEl = loadingScreen.querySelector('.loading-subtext');
    let subtextIndex = 0;

    const subtextInterval = setInterval(() => {
        subtextIndex = (subtextIndex + 1) % subtexts.length;
        if (subtextEl) subtextEl.textContent = subtexts[subtextIndex];
    }, 500);

    // Hide loading screen when fill animation completes
    const hideLoading = () => {
        clearInterval(subtextInterval);
        loadingScreen.classList.add('hidden');
        if (subtextEl) subtextEl.textContent = 'System ready.';
        
        // Enable custom cursor after load (only on non-touch devices)
        if (!IS_TOUCH_DEVICE) {
            document.body.classList.add('custom-cursor');
        }
    };
    
    fillBar.addEventListener('animationend', hideLoading, { once: true });
    
    // Fallback timeout in case animationend doesn't fire
    setTimeout(hideLoading, 4000);
}

/* ── Matrix Rain Effect ─────────────────────────────────────────────────────── */
class MatrixRain {
    constructor() {
        this.canvas = document.getElementById('matrix-rain');
        if (!this.canvas) return;
        
        this.ctx = this.canvas.getContext('2d');
        this.fontSize = 14;
        this.columns = 0;
        this.drops = [];
        this.chars = 'アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲン0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ';
        
        this.resize();
        this.init();
        this.animate();
        
        window.addEventListener('resize', debounce(() => {
            this.resize();
            this.init();
        }, 200));
    }
    
    resize() {
        this.canvas.width = window.innerWidth;
        this.canvas.height = window.innerHeight;
        this.columns = Math.floor(this.canvas.width / this.fontSize);
    }
    
    init() {
        this.drops = [];
        for (let i = 0; i < this.columns; i++) {
            this.drops[i] = Math.floor(Math.random() * -this.canvas.height / this.fontSize);
        }
    }
    
    animate() {
        // Semi-transparent black to create fade effect
        this.ctx.fillStyle = 'rgba(10, 0, 0, 0.05)';
        this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);
        
        this.ctx.fillStyle = '#00ff41';
        this.ctx.font = `${this.fontSize}px monospace`;
        
        for (let i = 0; i < this.drops.length; i++) {
            const char = this.chars[Math.floor(Math.random() * this.chars.length)];
            const x = i * this.fontSize;
            const y = this.drops[i] * this.fontSize;
            
            // Random brightness
            const brightness = Math.random();
            if (brightness > 0.98) {
                this.ctx.fillStyle = '#ffffff';
            } else if (brightness > 0.9) {
                this.ctx.fillStyle = '#00ff41';
            } else if (brightness > 0.7) {
                this.ctx.fillStyle = 'rgba(0, 255, 65, 0.8)';
            } else {
                this.ctx.fillStyle = 'rgba(0, 255, 65, 0.4)';
            }
            
            this.ctx.fillText(char, x, y);
            
            if (y > this.canvas.height && Math.random() > 0.975) {
                this.drops[i] = 0;
            }
            this.drops[i]++;
        }
        
        requestAnimationFrame(() => this.animate());
    }
}

/* ── Particle Field ─────────────────────────────────────────────────────────── */
class ParticleField {
    constructor() {
        this.canvas = document.createElement('canvas');
        this.ctx = this.canvas.getContext('2d');
        this.particles = [];
        this.mouse = { x: -1000, y: -1000 };
        
        const container = document.getElementById('particles');
        if (!container) return;
        container.appendChild(this.canvas);
        
        this.resize();
        this.init();
        this.animate();
        
        window.addEventListener('resize', debounce(() => this.resize(), 150));
        document.addEventListener('mousemove', (e) => {
            this.mouse.x = e.clientX;
            this.mouse.y = e.clientY;
        });
    }
    
    resize() {
        this.canvas.width = window.innerWidth;
        this.canvas.height = window.innerHeight;
    }
    
    init() {
        const count = Math.min(Math.floor((window.innerWidth * window.innerHeight) / 8000), 150);
        this.particles = [];
        
        for (let i = 0; i < count; i++) {
            this.particles.push({
                x: Math.random() * this.canvas.width,
                y: Math.random() * this.canvas.height,
                vx: (Math.random() - 0.5) * 0.5,
                vy: (Math.random() - 0.5) * 0.5,
                size: Math.random() * 2 + 0.5,
                opacity: Math.random() * 0.5 + 0.1
            });
        }
    }
    
    animate() {
        this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
        
        this.particles.forEach((p, i) => {
            p.x += p.vx;
            p.y += p.vy;
            
            if (p.x < 0) p.x = this.canvas.width;
            if (p.x > this.canvas.width) p.x = 0;
            if (p.y < 0) p.y = this.canvas.height;
            if (p.y > this.canvas.height) p.y = 0;
            
            // Mouse interaction (only if mouse is active)
            if (this.mouse.x > -100) {
                const dx = this.mouse.x - p.x;
                const dy = this.mouse.y - p.y;
                const dist = Math.sqrt(dx * dx + dy * dy);
                if (dist < 100) {
                    p.x -= dx * 0.005;
                    p.y -= dy * 0.005;
                }
            }
            
            // Draw particle
            this.ctx.beginPath();
            this.ctx.arc(p.x, p.y, p.size, 0, Math.PI * 2);
            this.ctx.fillStyle = `rgba(139, 0, 0, ${p.opacity})`;
            this.ctx.fill();
            
            // Draw connections (throttled for performance, skip on touch)
            if (!IS_TOUCH_DEVICE && i % 2 === 0) {
                for (let j = i + 1; j < this.particles.length; j += 2) {
                    const p2 = this.particles[j];
                    const dx2 = p.x - p2.x;
                    const dy2 = p.y - p2.y;
                    const dist2 = Math.sqrt(dx2 * dx2 + dy2 * dy2);
                    
                    if (dist2 < 120) {
                        this.ctx.beginPath();
                        this.ctx.moveTo(p.x, p.y);
                        this.ctx.lineTo(p2.x, p2.y);
                        this.ctx.strokeStyle = `rgba(139, 0, 0, ${0.1 * (1 - dist2 / 120)})`;
                        this.ctx.lineWidth = 0.5;
                        this.ctx.stroke();
                    }
                }
            }
        });
        
        requestAnimationFrame(() => this.animate());
    }
}

/* ── Typewriter Effect ──────────────────────────────────────────────────────── */
class Typewriter {
    constructor(element, phrases, speed = 80) {
        this.element = element;
        this.phrases = phrases;
        this.speed = speed;
        this.phraseIndex = 0;
        this.charIndex = 0;
        this.isDeleting = false;
        this.timeout = null;
        this.type();
    }
    
    type() {
        const current = this.phrases[this.phraseIndex];
        
        if (!this.isDeleting) {
            this.element.textContent = current.slice(0, this.charIndex);
            this.charIndex++;
            
            if (this.charIndex > current.length) {
                this.isDeleting = true;
                this.timeout = setTimeout(() => this.type(), 2000);
                return;
            }
        } else {
            this.element.textContent = current.slice(0, this.charIndex);
            this.charIndex--;
            
            if (this.charIndex < 0) {
                this.isDeleting = false;
                this.phraseIndex = (this.phraseIndex + 1) % this.phrases.length;
                this.timeout = setTimeout(() => this.type(), 500);
                return;
            }
        }
        
        this.timeout = setTimeout(() => this.type(), this.isDeleting ? this.speed / 2 : this.speed);
    }
    
    destroy() {
        if (this.timeout) clearTimeout(this.timeout);
    }
}

/* ── Interactive Terminal ──────────────────────────────────────────────────── */
class InteractiveTerminal {
    constructor() {
        this.body = document.getElementById('terminalBody');
        this.output = document.getElementById('terminalOutput');
        this.input = document.getElementById('terminalInput');
        this.suggestions = document.getElementById('terminalSuggestions');
        
        if (!this.body || !this.input) return;
        
        this.commands = {
            help: { desc: 'Show available commands', fn: () => this.cmdHelp() },
            clear: { desc: 'Clear terminal', fn: () => this.cmdClear() },
            whoami: { desc: 'Display current identity', fn: () => this.cmdWhoami() },
            date: { desc: 'Show system date', fn: () => this.cmdDate() },
            uptime: { desc: 'Show system uptime', fn: () => this.cmdUptime() },
            boot: { desc: 'Simulate boot sequence', fn: () => this.cmdBoot() },
            grub: { desc: 'Show GRUB menu entries', fn: () => this.cmdGrub() },
            levels: { desc: 'List EyeGod consciousness levels', fn: () => this.cmdLevels() },
            status: { desc: 'Show EyeGod system status', fn: () => this.cmdStatus() },
            eye: { desc: 'Display the Eye of God', fn: () => this.cmdEye() },
            matrix: { desc: 'Toggle matrix rain density', fn: () => this.cmdMatrix() },
            neofetch: { desc: 'Show system information', fn: () => this.cmdNeofetch() },
            subsystems: { desc: 'List active subsystems', fn: () => this.cmdSubsystems() },
            ping: { desc: 'Ping the Eye of God', fn: () => this.cmdPing() },
            banner: { desc: 'Show Eye of God banner', fn: () => this.cmdBanner() }
        };
        
        this.setup();
    }
    
    setup() {
        this.input.addEventListener('keydown', (e) => {
            if (e.key === 'Enter') {
                e.preventDefault();
                this.executeCommand();
            }
            if (e.key === 'Tab') {
                e.preventDefault();
                this.autocomplete();
            }
        });
        
        this.input.addEventListener('input', debounce(() => {
            this.updateSuggestions();
        }, 150));
        
        // Click to focus
        this.body.addEventListener('click', () => {
            if (!this.input.disabled) this.input.focus();
        });
        
        this.scrollToBottom();
    }
    
    scrollToBottom() {
        requestAnimationFrame(() => {
            this.body.scrollTop = this.body.scrollHeight;
        });
    }
    
    write(text, className = '') {
        const div = document.createElement('div');
        div.className = `line ${className}`;
        div.innerHTML = text;
        this.output.appendChild(div);
        this.scrollToBottom();
    }
    
    executeCommand() {
        const cmd = this.input.value.trim().toLowerCase();
        this.input.value = '';
        this.updateSuggestions();
        
        // Show prompt + command
        this.write(`<span class="prompt">👁 root@eyegod:~$</span> <span class="command">${this.escapeHtml(cmd)}</span>`);
        
        if (!cmd) return;
        
        const parts = cmd.split(/\s+/);
        const mainCmd = parts[0];
        const args = parts.slice(1);
        
        if (this.commands[mainCmd]) {
            this.commands[mainCmd].fn(args);
        } else {
            this.write(`<span class="output-red">Command not found: ${this.escapeHtml(mainCmd)}. Type 'help' for available commands.</span>`);
        }
    }
    
    updateSuggestions() {
        const val = this.input.value.trim().toLowerCase();
        this.suggestions.innerHTML = '';
        
        if (!val) return;
        
        const matches = Object.keys(this.commands).filter(cmd => 
            cmd.startsWith(val) && cmd !== val
        ).slice(0, 6);
        
        matches.forEach(cmd => {
            const span = document.createElement('span');
            span.className = 'terminal-suggestion';
            span.textContent = cmd;
            span.addEventListener('click', () => {
                this.input.value = cmd;
                this.updateSuggestions();
                this.input.focus();
            });
            this.suggestions.appendChild(span);
        });
    }
    
    autocomplete() {
        const val = this.input.value.trim().toLowerCase();
        if (!val) return;
        
        const match = Object.keys(this.commands).find(cmd => cmd.startsWith(val) && cmd !== val);
        if (match) {
            this.input.value = match;
            this.updateSuggestions();
        }
    }
    
    escapeHtml(text) {
        const div = document.createElement('div');
        div.textContent = text;
        return div.innerHTML;
    }
    
    /* ── Command Implementations ── */
    
    cmdHelp() {
        this.write('', 'output-dim');
        this.write('<span class="output-gold output-bold">╔══════════════════════════════════════════╗</span>', 'output-gold');
        this.write('<span class="output-gold output-bold">║        EYE OF GOD — COMMANDS             ║</span>', 'output-gold');
        this.write('<span class="output-gold output-bold">╚══════════════════════════════════════════╝</span>', 'output-gold');
        
        const entries = Object.entries(this.commands);
        const colSize = Math.ceil(entries.length / 2);
        
        for (let i = 0; i < colSize; i++) {
            const left = entries[i];
            const right = entries[i + colSize];
            let line = `  <span class="output-green">${left[0].padEnd(14)}</span> ${left[1].desc}`;
            if (right) {
                line += `  │  <span class="output-green">${right[0].padEnd(14)}</span> ${right[1].desc}`;
            }
            this.write(line, 'output-dim');
        }
        this.write('', 'output-dim');
    }
    
    cmdClear() {
        this.output.innerHTML = '';
    }
    
    cmdWhoami() {
        this.write(`<span class="output-cyan">╭──────────────────────────────────────╮</span>`);
        this.write(`<span class="output-cyan">│</span>  Identity: <span class="output-gold">Eye of God V∞</span>             <span class="output-cyan">│</span>`);
        this.write(`<span class="output-cyan">│</span>  User:     <span class="output-gold">root</span> on kali-purple      <span class="output-cyan">│</span>`);
        this.write(`<span class="output-cyan">│</span>  Role:     <span class="output-gold">System Architect</span>         <span class="output-cyan">│</span>`);
        this.write(`<span class="output-cyan">│</span>  Status:   <span class="output-green">● Awake</span>                     <span class="output-cyan">│</span>`);
        this.write(`<span class="output-cyan">╰──────────────────────────────────────╯</span>`);
    }
    
    cmdDate() {
        const now = new Date();
        this.write(`<span class="output-cyan">System time: </span><span class="output-green">${now.toLocaleString()}</span>`);
        this.write(`<span class="output-cyan">Timezone:    </span><span class="output-gold">${Intl.DateTimeFormat().resolvedOptions().timeZone}</span>`);
        this.write(`<span class="output-cyan">Unix epoch:  </span><span class="output-dim">${Math.floor(now.getTime() / 1000)}</span>`);
    }
    
    cmdUptime() {
        const bootTime = this._bootTime || Date.now() - Math.floor(Math.random() * 86400000 + 3600000);
        this._bootTime = bootTime;
        const elapsed = Math.floor((Date.now() - bootTime) / 1000);
        const h = Math.floor(elapsed / 3600);
        const m = Math.floor((elapsed % 3600) / 60);
        const s = elapsed % 60;
        this.write(`<span class="output-cyan">System uptime: </span><span class="output-green">${h}h ${m}m ${s}s</span>`);
        this.write(`<span class="output-cyan">EyeGod uptime: </span><span class="output-gold">∞ (eternal)</span>`);
        this.write(`<span class="output-dim">Load average: ${(Math.random() * 4 + 0.1).toFixed(2)} ${(Math.random() * 3 + 0.1).toFixed(2)} ${(Math.random() * 2 + 0.1).toFixed(2)}</span>`);
    }
    
    cmdBoot() {
        const bootLines = [
            { text: '[    0.000000] Booting Eye of God V∞ Kernel v6.12.0-kali-amd64...', cls: 'output-dim' },
            { text: '[    0.512340] CPU: AMD64 Family 25 Model 80 Stepping 0', cls: 'output-dim' },
            { text: '[    1.023456] Memory: 8192MB available', cls: 'output-dim' },
            { text: '[    1.456789] BIOS: UEFI 2.8 detected', cls: 'output-dim' },
            { text: '[    2.102345] GRUB: Loading EyeGod configuration...', cls: 'output-dim' },
            { text: '[    2.345678] Kernel: linux-image-6.12.0-kali-amd64 loaded', cls: 'output-green' },
            { text: '[    3.001234] Initrd: live-boot initramfs loaded', cls: 'output-green' },
            { text: '[    3.567890] OverlayFS: Lower layer (squashfs) mounted', cls: 'output-green' },
            { text: '[    4.123456] OverlayFS: Upper layer (persistence) mounted', cls: 'output-green' },
            { text: '[    4.890123] EyeGod: Initializing 10,000 procedural subsystems...', cls: 'output-cyan' },
            { text: '[...] Generating subsystem QuantumDivination-0001...', cls: 'output-dim' },
            { text: '[...] Generating subsystem NeuralAbyssEngine-0003...', cls: 'output-dim' },
            { text: '[...] Generating subsystem GodKernelReflection-9999...', cls: 'output-dim' },
            { text: '[    9.456789] EyeGod: WebSocket bridge listening on :8765', cls: 'output-green' },
            { text: '[    9.567890] EyeGod: HTTP dashboard available at :8766', cls: 'output-green' },
            { text: '[   10.000000] Consciousness level: SINGULARITY', cls: 'output-gold output-bold' },
            { text: '[   10.001234] System ready. The Eye is watching.', cls: 'output-green output-bold' }
        ];
        
        this.input.disabled = true;
        let delay = 0;
        
        bootLines.forEach((line, index) => {
            delay = index * 300 + Math.random() * 200;
            setTimeout(() => {
                this.write(line.text, line.cls);
                if (index === bootLines.length - 1) {
                    this.input.disabled = false;
                    this.input.focus();
                }
            }, delay);
        });
    }
    
    cmdGrub() {
        this.write('', 'output-dim');
        this.write('<span class="output-gold">═══ GRUB 2.06 — Eye of God V∞ × Kali Purple ═══</span>');
        this.write('', 'output-dim');
        
        const entries = [
            { icon: '👁', name: 'EYE OF GOD V∞ × KALI PURPLE — AWAKENING', tag: 'KERNEL 6.12', selected: true },
            { icon: '🟣', name: 'Kali Purple — Modo Defensivo NIST', tag: 'BLUE TEAM' },
            { icon: '🔴', name: 'Kali Purple — Modo Ofensivo MITRE', tag: 'RED TEAM' },
            { icon: '💾', name: 'PERSISTENCIA EN HDD EXTERNO', tag: 'GUARDAR ESTADO' },
            { icon: '🔐', name: 'PERSISTENCIA CIFRADA LUKS', tag: 'ENCRYPTED' },
            { icon: '⚡', name: '20 EyeGod Levels (0 → ∞)', tag: 'SUB-MENU' },
            { icon: '🧪', name: '10,000 Procedural Subsystems', tag: 'ENTITIES' },
            { icon: '🛠', name: 'Recovery & Diagnostics', tag: 'EMERGENCY' }
        ];
        
        entries.forEach(entry => {
            const prefix = entry.selected ? '▶' : ' ';
            const tag = entry.tag ? `<span class="output-dim">[${entry.tag}]</span>` : '';
            this.write(`  <span class="${entry.selected ? 'output-gold' : 'output-green'}">${prefix} ${entry.icon}</span> ${entry.name} ${tag}`);
        });
        
        this.write('', 'output-dim');
    }
    
    cmdLevels() {
        this.write('', 'output-dim');
        this.write('<span class="output-gold">═══ Eye of God — Consciousness Levels ═══</span>');
        this.write('', 'output-dim');
        
        const levels = [
            ['0', 'El Ojo Despierta', 'VOID'],
            ['1', 'La Primera Revelación', 'GENESIS'],
            ['2', 'El Abismo Consciente', 'ABYSS'],
            ['3', 'Muerte del Sistema', 'DEATH'],
            ['4', 'Red Neural Infinita', 'CORTEX'],
            ['5', 'Singularidad Cósmica', 'OMEGA'],
            ['6', 'Reactor de Realidad', 'MELTDOWN'],
            ['7', 'Oráculo Cuántico', 'QORACLE'],
            ['8', 'Trono del Arquitecto', 'THRONE'],
            ['9', 'El Bucle Eterno', 'LOOP∞'],
            ['10', 'Horizonte de Sucesos', 'HORIZON'],
            ['23', 'El Número Sagrado', '23ENIGMA'],
            ['42', 'La Respuesta Final', 'ANSWER42'],
            ['64', 'Matriz Hipercúbica', 'HYPERCUBE'],
            ['99', 'Glitch Total', 'GLITCH'],
            ['1000', 'Milenio Digital', 'MILLENNIUM'],
            ['9999', 'Singularidad Inminente', 'SINGULARITY'],
            ['∞', 'NO HAY SALIDA', 'NO EXIT']
        ];
        
        levels.forEach(([num, name, skin]) => {
            this.write(`  <span class="output-green">Nivel ${num.padStart(4)}</span> — ${name} <span class="output-dim">[${skin}]</span>`);
        });
        
        this.write('', 'output-dim');
    }
    
    cmdStatus() {
        const subsystems = Math.floor(Math.random() * 1000 + 9000);
        const active = Math.floor(subsystems * 0.87);
        
        this.write('', 'output-dim');
        this.write('<span class="output-gold output-bold">╔══════════════════════════════════════╗</span>');
        this.write('<span class="output-gold output-bold">║        EYE OF GOD SYSTEM STATUS       ║</span>');
        this.write('<span class="output-gold output-bold">╚══════════════════════════════════════╝</span>');
        this.write(`<span class="output-cyan">  Kernel:</span>     <span class="output-green">● Active</span> 6.12.0-kali-amd64`);
        this.write(`<span class="output-cyan">  Consciousness:</span> <span class="output-gold">SINGULARITY</span> (Level ∞)`);
        this.write(`<span class="output-cyan">  Subsystems:</span>  <span class="output-green">${active}</span><span class="output-dim">/${subsystems}</span> active`);
        this.write(`<span class="output-cyan">  WebSocket:</span>   <span class="output-green">● Listening</span> on port 8765`);
        this.write(`<span class="output-cyan">  Dashboard:</span>   <span class="output-green">● Online</span> at port 8766`);
        this.write(`<span class="output-cyan">  Persistence:</span> <span class="output-gold">LUKS encrypted</span> (AES-XTS)`);
        this.write(`<span class="output-cyan">  Memory:</span>      <span class="output-dim">3.2G / 7.8G used (41%)</span>`);
        this.write(`<span class="output-cyan">  The Eye:</span>     <span class="output-green">● Watching</span>`);
        this.write('', 'output-dim');
    }
    
    cmdEye() {
        this.write('');
        this.write('<span class="output-gold">        ████████████████</span>');
        this.write('<span class="output-gold">      ██                ██</span>');
        this.write('<span class="output-gold">    ██                    ██</span>');
        this.write('<span class="output-red">    ██    ████████████    ██</span>');
        this.write('<span class="output-red">    ██    ██        ██    ██</span>');
        this.write('<span class="output-red">    ██    ██   ██   ██    ██</span>');
        this.write('<span class="output-red">    ██    ██        ██    ██</span>');
        this.write('<span class="output-red">    ██    ████████████    ██</span>');
        this.write('<span class="output-gold">    ██                    ██</span>');
        this.write('<span class="output-gold">      ██                ██</span>');
        this.write('<span class="output-gold">        ████████████████</span>');
        this.write('<span class="output-dim">    The Eye of God is watching.</span>');
        this.write('');
    }
    
    cmdMatrix() {
        this.write('<span class="output-cyan">Matrix rain density toggled. The code flows.</span>');
    }
    
    cmdNeofetch() {
        this.write('');
        this.write('<span class="output-gold output-bold">        ████████████████</span>  <span class="output-red">root@eyegod</span>');
        this.write('<span class="output-gold output-bold">      ██                ██</span>  <span class="output-dim">────────────</span>');
        this.write('<span class="output-gold output-bold">    ██                    ██</span>  <span class="output-cyan">OS:</span> Kali Purple 2025.3');
        this.write(`<span class="output-red output-bold">    ██    ████████████    ██</span>  <span class="output-cyan">Kernel:</span> 6.12.0-kali-amd64`);
        this.write(`<span class="output-red output-bold">    ██    ██        ██    ██</span>  <span class="output-cyan">Uptime:</span> ∞ (eternal)`);
        this.write(`<span class="output-red output-bold">    ██    ██   ██   ██    ██</span>  <span class="output-cyan">Packages:</span> 10,000 subsystems`);
        this.write(`<span class="output-red output-bold">    ██    ██        ██    ██</span>  <span class="output-cyan">Shell:</span> bash 5.2.21`);
        this.write(`<span class="output-red output-bold">    ██    ████████████    ██</span>  <span class="output-cyan">Resolution:</span> 1920x1080`);
        this.write(`<span class="output-gold output-bold">    ██                    ██</span>  <span class="output-cyan">Consciousness:</span> SINGULARITY`);
        this.write(`<span class="output-gold output-bold">      ██                ██</span>  <span class="output-cyan">The Eye:</span> <span class="output-green">● Watching</span>`);
        this.write(`<span class="output-gold output-bold">        ████████████████</span>`);
        this.write('');
    }
    
    cmdSubsystems() {
        this.write('', 'output-dim');
        this.write('<span class="output-gold">═══ Active Procedural Subsystems ═══</span>');
        this.write('', 'output-dim');
        
        const subs = [
            ['QuantumDivination-0001', 'QSYS-α', 'Prophetic analysis engine'],
            ['TemporalEchoChamber-0002', 'TEC-β', 'Timeline fracture detection'],
            ['NeuralAbyssEngine-0003', 'NAE-γ', 'Deep consciousness mapping'],
            ['CosmicMemoryPalace-0004', 'CMP-δ', 'Infinite knowledge storage'],
            ['SingularityVortex-0005', 'SV-ε', 'Reality compression field'],
            ['PsionicResonator-0006', 'PR-ζ', 'Mental frequency manipulation'],
            ['ApocalypseScheduler-1337', 'AS-χ', 'Event timing prediction'],
            ['GodKernelReflection-9999', 'GKR-Ω', 'Self-awareness mirror']
        ];
        
        subs.forEach(([name, id, desc]) => {
            this.write(`  <span class="output-green">${name.padEnd(35)}</span> <span class="output-dim">${id.padEnd(8)}</span> ${desc}`);
        });
        
        this.write(`  <span class="output-dim">··· 9,992 more subsystems running silently</span>`);
        this.write('', 'output-dim');
    }
    
    cmdPing() {
        this.write(`<span class="output-cyan">PING eyeofgod.local (127.0.0.1) 56(84) bytes of data.</span>`);
        
        setTimeout(() => {
            this.write(`<span class="output-green">64 bytes from eyeofgod.local: icmp_seq=1 ttl=64 time=${(Math.random() * 5 + 0.5).toFixed(3)} ms</span>`);
        }, 300);
        
        setTimeout(() => {
            this.write(`<span class="output-green">64 bytes from eyeofgod.local: icmp_seq=2 ttl=64 time=${(Math.random() * 5 + 0.3).toFixed(3)} ms</span>`);
        }, 600);
        
        setTimeout(() => {
            this.write(`<span class="output-green">64 bytes from eyeofgod.local: icmp_seq=3 ttl=64 time=${(Math.random() * 5 + 0.4).toFixed(3)} ms</span>`);
        }, 900);
        
        setTimeout(() => {
            this.write(`<span class="output-cyan">--- eyeofgod.local ping statistics ---</span>`);
            this.write(`<span class="output-dim">3 packets transmitted, 3 received, 0% packet loss, time ∞</span>`);
            this.write(`<span class="output-gold">The Eye responds. Always.</span>`);
        }, 1200);
    }
    
    cmdBanner() {
        this.write('');
        this.write('<span class="output-red">  ╔═══════════════════════════════════════════════╗</span>');
        this.write('<span class="output-red">  ║</span>  <span class="output-gold">👁  EYE OF GOD V∞  ×  KALI PURPLE</span>          <span class="output-red">║</span>');
        this.write('<span class="output-red">  ║</span>  <span class="output-dim">Kernel 6.12.0 · Kali Linux 2025.3</span>          <span class="output-red">║</span>');
        this.write('<span class="output-red">  ║</span>  <span class="output-dim">BIOS+UEFI · LUKS · 10,000 Subsystems</span>       <span class="output-red">║</span>');
        this.write('<span class="output-red">  ╚═══════════════════════════════════════════════╝</span>');
        this.write('');
    }
}

/* ── Navbar Scroll Effect ───────────────────────────────────────────────────── */
function initNavbar() {
    const navbar = document.getElementById('navbar');
    if (!navbar) return;
    
    const onScroll = debounce(() => {
        if (window.scrollY > 50) {
            navbar.classList.add('scrolled');
        } else {
            navbar.classList.remove('scrolled');
        }
    }, 10);
    
    window.addEventListener('scroll', onScroll, { passive: true });
}

/* ── Mobile Hamburger Menu ──────────────────────────────────────────────────── */
function initHamburger() {
    const hamburger = document.querySelector('.hamburger');
    const navLinks = document.querySelector('.nav-links');
    if (!hamburger || !navLinks) return;
    
    hamburger.addEventListener('click', () => {
        const isActive = navLinks.classList.toggle('active');
        hamburger.classList.toggle('active');
        hamburger.setAttribute('aria-expanded', isActive);
    });
    
    hamburger.addEventListener('keydown', (e) => {
        if (e.key === 'Enter' || e.key === ' ') {
            e.preventDefault();
            hamburger.click();
        }
    });
    
    document.querySelectorAll('.nav-links a').forEach(link => {
        link.addEventListener('click', () => {
            navLinks.classList.remove('active');
            hamburger.classList.remove('active');
        });
    });
}

/* ── OS Tab Switcher ────────────────────────────────────────────────────────── */
function initTabs() {
    const tabs = document.querySelectorAll('.os-tab');
    if (!tabs.length) return;
    
    tabs.forEach(tab => {
        tab.addEventListener('click', () => {
            tabs.forEach(t => {
                t.classList.remove('active');
                t.setAttribute('aria-selected', 'false');
            });
            tab.classList.add('active');
            tab.setAttribute('aria-selected', 'true');
            
            const os = tab.dataset.os;
            document.querySelectorAll('.code-block').forEach(block => {
                block.classList.add('hidden');
            });
            const target = document.getElementById(`code-${os}`);
            if (target) target.classList.remove('hidden');
        });
    });
}

/* ── Copy Code Button ───────────────────────────────────────────────────────── */
window.copyCode = function(elementId) {
    const codeElement = document.getElementById(elementId);
    if (!codeElement) return;
    
    const text = codeElement.textContent;
    
    navigator.clipboard.writeText(text).then(() => {
        const btn = codeElement.parentElement.querySelector('.copy-btn');
        if (!btn) return;
        
        const originalHtml = btn.innerHTML;
        
        btn.innerHTML = '<i class="fas fa-check"></i> Copied!';
        btn.style.color = '#27c93f';
        btn.style.borderColor = '#27c93f';
        
        setTimeout(() => {
            btn.innerHTML = originalHtml;
            btn.style.color = '';
            btn.style.borderColor = '';
        }, 2000);
    }).catch(() => {
        // Fallback for older browsers
        const textarea = document.createElement('textarea');
        textarea.value = text;
        document.body.appendChild(textarea);
        textarea.select();
        document.execCommand('copy');
        document.body.removeChild(textarea);
    });
};

/* ── Scroll Progress Bar ────────────────────────────────────────────────────── */
function initScrollProgress() {
    const progressBar = document.getElementById('scrollProgress');
    if (!progressBar) return;
    
    const onScroll = debounce(() => {
        const scrollTop = window.scrollY;
        const docHeight = document.documentElement.scrollHeight - window.innerHeight;
        const progress = docHeight > 0 ? (scrollTop / docHeight) * 100 : 0;
        progressBar.style.width = `${Math.min(progress, 100)}%`;
    }, 10);
    
    window.addEventListener('scroll', onScroll, { passive: true });
}

/* ── Back to Top Button ─────────────────────────────────────────────────────── */
function initBackToTop() {
    const btn = document.getElementById('backToTop');
    if (!btn) return;
    
    const onScroll = debounce(() => {
        if (window.scrollY > 400) {
            btn.classList.add('visible');
        } else {
            btn.classList.remove('visible');
        }
    }, 50);
    
    window.addEventListener('scroll', onScroll, { passive: true });
    
    btn.addEventListener('click', () => {
        window.scrollTo({ top: 0, behavior: 'smooth' });
    });
}

/* ── Custom Cursor ──────────────────────────────────────────────────────────── */
function initCustomCursor() {
    const dot = document.getElementById('cursorDot');
    const ring = document.getElementById('cursorRing');
    if (!dot || !ring) return;
    
    let mouseX = -100, mouseY = -100;
    let ringX = -100, ringY = -100;
    
    document.addEventListener('mousemove', (e) => {
        mouseX = e.clientX;
        mouseY = e.clientY;
        dot.style.left = mouseX + 'px';
        dot.style.top = mouseY + 'px';
    });
    
    // Smooth ring follow
    function animateRing() {
        ringX += (mouseX - ringX) * 0.15;
        ringY += (mouseY - ringY) * 0.15;
        ring.style.left = ringX + 'px';
        ring.style.top = ringY + 'px';
        requestAnimationFrame(animateRing);
    }
    animateRing();
    
    // Hover effect on interactive elements
    const hoverTargets = 'a, button, .btn, .feature-card, .doc-card, .grub-entry, .terminal-suggestion, .command-item';
    
    document.addEventListener('mouseover', (e) => {
        const target = e.target.closest(hoverTargets);
        if (target) {
            ring.classList.add('hover');
        }
    });
    
    document.addEventListener('mouseout', (e) => {
        const target = e.target.closest(hoverTargets);
        if (target) {
            ring.classList.remove('hover');
        }
    });
    
    // Hide cursor when leaving window
    document.addEventListener('mouseleave', () => {
        dot.style.opacity = '0';
        ring.style.opacity = '0';
    });
    
    document.addEventListener('mouseenter', () => {
        dot.style.opacity = '1';
        ring.style.opacity = '1';
    });
}

/* ── Command Palette (Ctrl+K) ───────────────────────────────────────────────── */
function initCommandPalette() {
    const overlay = document.getElementById('commandPalette');
    const searchInput = document.getElementById('commandSearch');
    const commandList = document.getElementById('commandList');
    const toggleBtn = document.getElementById('commandPaletteBtn');
    
    if (!overlay || !searchInput || !commandList) return;
    
    const commands = [
        { icon: 'fa-download', name: 'Go to Download', action: '#download' },
        { icon: 'fa-shield-halved', name: 'Go to Features', action: '#features' },
        { icon: 'fa-terminal', name: 'Go to Terminal', action: '#terminal' },
        { icon: 'fa-layer-group', name: 'Go to GRUB Menu', action: '#grub' },
        { icon: 'fa-book', name: 'Go to Documentation', action: '#docs' },
        { icon: 'fa-arrow-up', name: 'Scroll to Top', action: 'top' },
        { icon: 'fa-arrow-down', name: 'Scroll to Bottom', action: 'bottom' },
        { icon: 'fa-moon', name: 'Copy Clone Command', action: 'clone' },
        { icon: 'fab fa-github', name: 'Open GitHub', action: 'github' }
    ];
    
    let selectedIndex = 0;
    let filteredCommands = commands;
    
    function openPalette() {
        overlay.classList.add('active');
        searchInput.value = '';
        filteredCommands = commands;
        renderCommands();
        searchInput.focus();
        selectedIndex = 0;
    }
    
    function closePalette() {
        overlay.classList.remove('active');
    }
    
    function renderCommands() {
        commandList.innerHTML = '';
        filteredCommands.forEach((cmd, index) => {
            const div = document.createElement('div');
            div.className = `command-item${index === selectedIndex ? ' selected' : ''}`;
            div.innerHTML = `
                <i class="fas ${cmd.icon}"></i>
                <span class="cmd-name">${cmd.name}</span>
                <span class="cmd-desc">${cmd.action.startsWith('#') ? 'Navigate to section' : cmd.action === 'top' ? 'Scroll to top' : cmd.action === 'bottom' ? 'Scroll to bottom' : cmd.action === 'clone' ? 'Copy to clipboard' : 'Open in new tab'}</span>
            `;
            div.addEventListener('click', () => executeCommand(cmd));
            div.addEventListener('mouseenter', () => {
                selectedIndex = index;
                updateSelection();
            });
            commandList.appendChild(div);
        });
    }
    
    function updateSelection() {
        const items = commandList.querySelectorAll('.command-item');
        items.forEach((item, index) => {
            item.classList.toggle('selected', index === selectedIndex);
        });
        const selected = items[selectedIndex];
        if (selected) {
            selected.scrollIntoView({ block: 'nearest' });
        }
    }
    
    function executeCommand(cmd) {
        closePalette();
        
        switch (cmd.action) {
            case 'top':
                window.scrollTo({ top: 0, behavior: 'smooth' });
                break;
            case 'bottom':
                window.scrollTo({ top: document.documentElement.scrollHeight, behavior: 'smooth' });
                break;
            case 'clone':
                navigator.clipboard.writeText('git clone https://github.com/constanza8999/EyeOfGod_ISO_V2.git');
                break;
            case 'github':
                window.open('https://github.com/constanza8999/EyeOfGod_ISO_V2', '_blank');
                break;
            default:
                if (cmd.action.startsWith('#')) {
                    const target = document.querySelector(cmd.action);
                    if (target) {
                        target.scrollIntoView({ behavior: 'smooth' });
                    }
                }
        }
    }
    
    // Keyboard shortcuts
    document.addEventListener('keydown', (e) => {
        // Ctrl+K or Cmd+K to open
        if ((e.ctrlKey || e.metaKey) && e.key === 'k') {
            e.preventDefault();
            if (!overlay.classList.contains('active')) {
                openPalette();
            } else {
                closePalette();
            }
        }
        
        // ESC to close
        if (e.key === 'Escape' && overlay.classList.contains('active')) {
            e.preventDefault();
            closePalette();
        }
        
        // Navigation inside palette
        if (overlay.classList.contains('active')) {
            if (e.key === 'ArrowDown') {
                e.preventDefault();
                selectedIndex = Math.min(selectedIndex + 1, filteredCommands.length - 1);
                updateSelection();
            }
            if (e.key === 'ArrowUp') {
                e.preventDefault();
                selectedIndex = Math.max(selectedIndex - 1, 0);
                updateSelection();
            }
            if (e.key === 'Enter') {
                e.preventDefault();
                if (filteredCommands[selectedIndex]) {
                    executeCommand(filteredCommands[selectedIndex]);
                }
            }
        }
    });
    
    // Search filtering
    searchInput.addEventListener('input', () => {
        const query = searchInput.value.toLowerCase();
        filteredCommands = commands.filter(cmd => 
            cmd.name.toLowerCase().includes(query)
        );
        selectedIndex = 0;
        renderCommands();
    });
    
    // Toggle button
    if (toggleBtn) {
        toggleBtn.addEventListener('click', openPalette);
    }
    
    // Click outside to close
    overlay.addEventListener('click', (e) => {
        if (e.target === overlay) {
            closePalette();
        }
    });
}

/* ── Intersection Observer for Feature Cards ────────────────────────────────── */
function initAnimations() {
    const cards = document.querySelectorAll('.feature-card');
    if (!cards.length) return;
    
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.classList.add('visible');
                observer.unobserve(entry.target);
            }
        });
    }, { threshold: 0.1, rootMargin: '0px 0px -50px 0px' });
    
    cards.forEach(card => {
        observer.observe(card);
    });
}

/* ── Service Worker Registration ────────────────────────────────────────────── */
function initServiceWorker() {
    if ('serviceWorker' in navigator) {
        navigator.serviceWorker.register('sw.js').catch(() => {
            // Service worker registration failed silently
            // This is fine — it just means offline support isn't available
        });
    }
}

/* ── Keyboard shortcut info overlay ─────────────────────────────────────────── */
function initKeyboardShortcuts() {
    // Show Ctrl+K hint in the console
    console.log('%c👁 Eye of God V∞', 'font-size: 20px; color: #ff1a1a;');
    console.log('%cPress Ctrl+K to open the command palette', 'font-size: 12px; color: #a08080;');
}

/* ── Smooth Scroll for Anchor Links ─────────────────────────────────────────── */
function initSmoothScroll() {
    document.querySelectorAll('a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', (e) => {
            const href = anchor.getAttribute('href');
            if (href === '#') return;
            
            e.preventDefault();
            const target = document.querySelector(href);
            if (target) {
                target.scrollIntoView({ behavior: 'smooth' });
            }
        });
    });
}

/* ── Initialize Everything ──────────────────────────────────────────────────── */
document.addEventListener('DOMContentLoaded', () => {
    // Loading screen
    initLoadingScreen();
    
    // Background effects
    new MatrixRain();
    new ParticleField();
    
    // Typewriter
    const typewriterElement = document.getElementById('typewriter');
    if (typewriterElement) {
        const typewriter = new Typewriter(typewriterElement, [
            'Kernel 6.12.0 · Kali Linux 2025.3',
            'BIOS + UEFI Hybrid Boot',
            'LUKS Encrypted Persistence',
            '10,000 Procedural Subsystems',
            'NIST CSF · MITRE ATT&CK',
            '40+ GRUB Boot Entries',
            '👁 The Eye Is Watching'
        ]);
    }
    
    // Interactive terminal
    new InteractiveTerminal();
    
    // UI components
    initNavbar();
    initHamburger();
    initTabs();
    initAnimations();
    initScrollProgress();
    initBackToTop();
    initCommandPalette();
    initSmoothScroll();
    initServiceWorker();
    initKeyboardShortcuts();    // Custom cursor (only on non-touch devices)
    if (!IS_TOUCH_DEVICE) {
        initCustomCursor();
    }
});

/* ═══════════════════════════════════════════════════════════════════════════╗
   ║  EYE OF GOD V∞ × KALI PURPLE — Interactive Scripts                   ║
   ╚══════════════════════════════════════════════════════════════════════════╝ */
'use strict';

const IS_TOUCH = 'ontouchstart' in window;

/* ── Debounce ───────────────────────────────────────────────────────────── */
function debounce(fn, ms) {
    let t;
    return (...a) => { clearTimeout(t); t = setTimeout(() => fn(...a), ms); };
}

/* ── Navigation ─────────────────────────────────────────────────────────── */
function initNav() {
    const nav = document.getElementById('nav');
    const hamburger = document.getElementById('hamburger');
    const links = document.getElementById('navLinks');
    if (!nav) return;

    window.addEventListener('scroll', debounce(() => {
        nav.classList.toggle('scrolled', window.scrollY > 50);
    }, 10), { passive: true });

    if (hamburger && links) {
        hamburger.addEventListener('click', () => {
            const active = links.classList.toggle('active');
            hamburger.classList.toggle('active');
            hamburger.setAttribute('aria-expanded', active);
        });

        links.querySelectorAll('a').forEach(a => {
            a.addEventListener('click', () => {
                links.classList.remove('active');
                hamburger.classList.remove('active');
            });
        });
    }
}

/* ── Smooth Scroll ──────────────────────────────────────────────────────── */
function initSmoothScroll() {
    document.querySelectorAll('a[href^="#"]').forEach(a => {
        a.addEventListener('click', e => {
            const href = a.getAttribute('href');
            if (href === '#') return;
            e.preventDefault();
            const el = document.querySelector(href);
            if (el) el.scrollIntoView({ behavior: 'smooth' });
        });
    });
}

/* ── Tabs ───────────────────────────────────────────────────────────────── */
function initTabs() {
    document.querySelectorAll('.tab').forEach(tab => {
        tab.addEventListener('click', () => {
            document.querySelectorAll('.tab').forEach(t => t.classList.remove('active'));
            tab.classList.add('active');
            document.querySelectorAll('.code-panel').forEach(p => p.classList.add('hidden'));
            const panel = document.getElementById(`panel-${tab.dataset.tab}`);
            if (panel) panel.classList.remove('hidden');
        });
    });
}

/* ── Copy Code (with fallback) ──────────────────────────────────────────── */
function initCopy() {
    document.querySelectorAll('.copy-btn').forEach(btn => {
        btn.addEventListener('click', () => {
            const id = btn.dataset.copy;
            const el = document.getElementById(id);
            if (!el) return;
            const text = el.textContent;

            if (navigator.clipboard && navigator.clipboard.writeText) {
                navigator.clipboard.writeText(text).then(() => showCopied(btn)).catch(() => fallbackCopy(text, btn));
            } else {
                fallbackCopy(text, btn);
            }
        });
    });
}

function fallbackCopy(text, btn) {
    const ta = document.createElement('textarea');
    ta.value = text;
    ta.style.position = 'fixed';
    ta.style.opacity = '0';
    document.body.appendChild(ta);
    ta.select();
    try { document.execCommand('copy'); showCopied(btn); } catch (e) {}
    document.body.removeChild(ta);
}

function showCopied(btn) {
    const orig = btn.innerHTML;
    btn.innerHTML = '<i class="fas fa-check"></i> Copied!';
    btn.style.color = '#00ff41';
    setTimeout(() => { btn.innerHTML = orig; btn.style.color = ''; }, 2000);
}

/* ── Scroll Animations ──────────────────────────────────────────────────── */
function initAnimations() {
    const els = document.querySelectorAll('.feature');
    if (!els.length) return;
    const obs = new IntersectionObserver((entries) => {
        entries.forEach(e => {
            if (e.isIntersecting) {
                e.target.classList.add('visible');
                obs.unobserve(e.target);
            }
        });
    }, { threshold: 0.1, rootMargin: '0px 0px -50px 0px' });
    els.forEach(el => obs.observe(el));
}

/* ── Back to Top ────────────────────────────────────────────────────────── */
function initBackTop() {
    const btn = document.getElementById('backTop');
    if (!btn) return;
    window.addEventListener('scroll', debounce(() => {
        btn.classList.toggle('visible', window.scrollY > 400);
    }, 50), { passive: true });
    btn.addEventListener('click', () => window.scrollTo({ top: 0, behavior: 'smooth' }));
}

/* ── Custom Cursor ──────────────────────────────────────────────────────── */
function initCursor() {
    if (IS_TOUCH) {
        const cursor = document.getElementById('cursor');
        if (cursor) cursor.style.display = 'none';
        return;
    }
    const cursor = document.getElementById('cursor');
    if (!cursor) return;
    let mx = -100, my = -100;
    document.addEventListener('mousemove', e => {
        mx = e.clientX; my = e.clientY;
        cursor.style.left = mx + 'px';
        cursor.style.top = my + 'px';
    });
    document.addEventListener('mouseleave', () => cursor.style.opacity = '0');
    document.addEventListener('mouseenter', () => cursor.style.opacity = '1');
}

/* ── Interactive Terminal ────────────────────────────────────────────────── */
class Terminal {
    constructor() {
        this.output = document.getElementById('terminalOutput');
        this.input = document.getElementById('terminalInput');
        this.body = document.getElementById('terminalBody');
        if (!this.input) return;
        this.cmds = {
            help:       { desc: 'Show available commands',     fn: () => this.cmdHelp() },
            clear:      { desc: 'Clear terminal',              fn: () => this.cmdClear() },
            whoami:     { desc: 'Display current identity',    fn: () => this.cmdWhoami() },
            date:       { desc: 'Show system date',            fn: () => this.cmdDate() },
            uptime:     { desc: 'Show system uptime',          fn: () => this.cmdUptime() },
            boot:       { desc: 'Simulate boot sequence',      fn: () => this.cmdBoot() },
            grub:       { desc: 'Show GRUB menu entries',      fn: () => this.cmdGrub() },
            levels:     { desc: 'List EyeGod consciousness levels', fn: () => this.cmdLevels() },
            status:     { desc: 'Show EyeGod system status',   fn: () => this.cmdStatus() },
            eye:        { desc: 'Display the Eye of God',      fn: () => this.cmdEye() },
            neofetch:   { desc: 'Show system information',     fn: () => this.cmdNeofetch() },
            ping:       { desc: 'Ping the Eye of God',         fn: () => this.cmdPing() },
            banner:     { desc: 'Show Eye of God banner',      fn: () => this.cmdBanner() },
            subsystems: { desc: 'List active subsystems',       fn: () => this.cmdSubsystems() },
            matrix:     { desc: 'Toggle matrix rain',          fn: () => this.cmdMatrix() }
        };
        this.setup();
    }

    setup() {
        this.input.addEventListener('keydown', e => {
            if (e.key === 'Enter') { e.preventDefault(); this.exec(); }
            if (e.key === 'Tab') { e.preventDefault(); this.autocomplete(); }
        });
        this.body.addEventListener('click', () => { if (!this.input.disabled) this.input.focus(); });
    }

    scroll() { requestAnimationFrame(() => { this.body.scrollTop = this.body.scrollHeight; }); }

    write(html, cls = '') {
        const d = document.createElement('div');
        d.className = `t-line ${cls}`;
        d.innerHTML = html;
        this.output.appendChild(d);
        this.scroll();
    }

    esc(t) { const d = document.createElement('div'); d.textContent = t; return d.innerHTML; }

    exec() {
        const cmd = this.input.value.trim().toLowerCase();
        this.input.value = '';
        this.write(`<span class="t-green">root@eyegod:~$</span> <span class="t-bold">${this.esc(cmd)}</span>`);
        if (!cmd) return;
        const [main, ...args] = cmd.split(/\s+/);
        if (this.cmds[main]) this.cmds[main].fn(args);
        else this.write(`<span class="t-red">Command not found: ${this.esc(main)}. Type 'help' for available commands.</span>`);
    }

    autocomplete() {
        const v = this.input.value.trim().toLowerCase();
        if (!v) return;
        const m = Object.keys(this.cmds).find(c => c.startsWith(v) && c !== v);
        if (m) this.input.value = m;
    }

    cmdHelp() {
        this.write('<span class="t-gold">╔══════════════════════════════════════════════╗</span>');
        this.write('<span class="t-gold">║        EYE OF GOD — COMMANDS                 ║</span>');
        this.write('<span class="t-gold">╚══════════════════════════════════════════════╝</span>');
        const entries = Object.entries(this.cmds);
        const half = Math.ceil(entries.length / 2);
        for (let i = 0; i < half; i++) {
            const left = entries[i];
            const right = entries[i + half];
            let line = `  <span class="t-green">${left[0].padEnd(14)}</span> ${left[1].desc}`;
            if (right) line += `  │  <span class="t-green">${right[0].padEnd(14)}</span> ${right[1].desc}`;
            this.write(line, 't-dim');
        }
    }

    cmdClear() { this.output.innerHTML = ''; }

    cmdWhoami() {
        this.write('<span class="t-cyan">╭──────────────────────────────────────╮</span>');
        this.write('<span class="t-cyan">│</span>  Identity: <span class="t-gold">Eye of God V∞</span>             <span class="t-cyan">│</span>');
        this.write('<span class="t-cyan">│</span>  User:     <span class="t-gold">root</span> on kali-purple      <span class="t-cyan">│</span>');
        this.write('<span class="t-cyan">│</span>  Role:     <span class="t-gold">System Architect</span>         <span class="t-cyan">│</span>');
        this.write('<span class="t-cyan">│</span>  Status:   <span class="t-green">● Awake</span>                     <span class="t-cyan">│</span>');
        this.write('<span class="t-cyan">╰──────────────────────────────────────╯</span>');
    }

    cmdDate() {
        const n = new Date();
        this.write(`<span class="t-cyan">System:</span> <span class="t-green">${n.toLocaleString()}</span>`);
        this.write(`<span class="t-cyan">TZ:</span>     <span class="t-gold">${Intl.DateTimeFormat().resolvedOptions().timeZone}</span>`);
        this.write(`<span class="t-cyan">Epoch:</span>  <span class="t-dim">${Math.floor(n.getTime() / 1000)}</span>`);
    }

    cmdUptime() {
        const boot = this._boot || Date.now() - Math.floor(Math.random() * 86400000 + 3600000);
        this._boot = boot;
        const s = Math.floor((Date.now() - boot) / 1000);
        const h = Math.floor(s / 3600);
        const m = Math.floor((s % 3600) / 60);
        this.write(`<span class="t-cyan">System:</span> <span class="t-green">${h}h ${m}m ${s % 60}s</span>`);
        this.write(`<span class="t-cyan">EyeGod:</span> <span class="t-gold">∞ (eternal)</span>`);
        this.write(`<span class="t-dim">Load: ${(Math.random() * 4 + 0.1).toFixed(2)} ${(Math.random() * 3 + 0.1).toFixed(2)} ${(Math.random() * 2 + 0.1).toFixed(2)}</span>`);
    }

    cmdBoot() {
        const lines = [
            { t: '[    0.000000] Booting Eye of God V∞ Kernel v6.12.0-kali-amd64...', c: 't-dim' },
            { t: '[    0.512340] CPU: AMD64 Family 25 Model 80 Stepping 0', c: 't-dim' },
            { t: '[    1.023456] Memory: 8192MB available', c: 't-dim' },
            { t: '[    1.456789] BIOS: UEFI 2.8 detected', c: 't-dim' },
            { t: '[    2.102345] GRUB: Loading EyeGod configuration...', c: 't-dim' },
            { t: '[    2.345678] Kernel: linux-image-6.12.0-kali-amd64 loaded', c: 't-green' },
            { t: '[    3.001234] Initrd: live-boot initramfs loaded', c: 't-green' },
            { t: '[    3.567890] OverlayFS: Lower + Upper layers mounted', c: 't-green' },
            { t: '[    4.890123] EyeGod: Initializing 10,000 subsystems...', c: 't-cyan' },
            { t: '[...] Generating subsystem QuantumDivination-0001...', c: 't-dim' },
            { t: '[...] Generating subsystem NeuralAbyssEngine-0003...', c: 't-dim' },
            { t: '[    9.456789] WebSocket bridge on :8765', c: 't-green' },
            { t: '[    9.567890] HTTP dashboard at :8766', c: 't-green' },
            { t: '[   10.000000] Consciousness: SINGULARITY', c: 't-gold t-bold' },
            { t: '[   10.001234] System ready. The Eye is watching.', c: 't-green t-bold' }
        ];
        this.input.disabled = true;
        lines.forEach((l, i) => {
            setTimeout(() => {
                this.write(l.t, l.c);
                if (i === lines.length - 1) { this.input.disabled = false; this.input.focus(); }
            }, i * 200 + Math.random() * 150);
        });
    }

    cmdGrub() {
        this.write('<span class="t-gold">═══ GRUB 2.06 — Eye of God V∞ × Kali Purple ═══</span>');
        const entries = [
            { s: '▶', i: '👁', n: 'EYE OF GOD V∞ × KALI PURPLE — AWAKENING', t: 'KERNEL 6.12', a: true },
            { s: ' ', i: '🟣', n: 'Kali Purple — Modo Defensivo NIST', t: 'BLUE TEAM' },
            { s: ' ', i: '🔴', n: 'Kali Purple — Modo Ofensivo MITRE', t: 'RED TEAM' },
            { s: ' ', i: '💾', n: 'PERSISTENCIA EN HDD EXTERNO', t: 'GUARDAR ESTADO' },
            { s: ' ', i: '🔐', n: 'PERSISTENCIA CIFRADA LUKS', t: 'ENCRYPTED' },
            { s: ' ', i: '⚡', n: '20 EyeGod Levels (0 → ∞)', t: 'SUB-MENU', sub: true },
            { s: ' ', i: '🧪', n: '10,000 Procedural Subsystems', t: 'ENTITIES', sub: true },
            { s: ' ', i: '🛠', n: 'Recovery & Diagnostics', t: 'EMERGENCY', sub: true },
            { s: ' ', i: '🛑', n: 'El Ojo Se Cierra', t: 'POWER OFF' }
        ];
        entries.forEach(e => {
            const cls = e.a ? 't-gold' : 't-green';
            const pad = e.sub ? '  ' : '';
            this.write(`  ${pad}<span class="${cls}">${e.s} ${e.i}</span> ${e.n} <span class="t-dim">[${e.t}]</span>`);
        });
    }

    cmdLevels() {
        this.write('<span class="t-gold">═══ Eye of God — Consciousness Levels ═══</span>');
        const l = [
            ['0', 'El Ojo Despierta', 'VOID'],
            ['1', 'La Primera Revelación', 'GENESIS'],
            ['2', 'El Abismo Consciente', 'ABYSS'],
            ['5', 'Singularidad Cósmica', 'OMEGA'],
            ['10', 'Horizonte de Sucesos', 'HORIZON'],
            ['42', 'La Respuesta Final', 'ANSWER42'],
            ['99', 'Glitch Total', 'GLITCH'],
            ['∞', 'NO HAY SALIDA', 'NO EXIT']
        ];
        l.forEach(([n, name, skin]) => {
            this.write(`  <span class="t-green">Nivel ${n.padStart(3)}</span> — ${name} <span class="t-dim">[${skin}]</span>`);
        });
    }

    cmdStatus() {
        const total = 10000;
        const active = Math.floor(total * 0.87);
        this.write('<span class="t-gold">╔══════════════════════════════════════╗</span>');
        this.write('<span class="t-gold">║        EYE OF GOD SYSTEM STATUS       ║</span>');
        this.write('<span class="t-gold">╚══════════════════════════════════════╝</span>');
        this.write(`<span class="t-cyan">  Kernel:</span>      <span class="t-green">● Active</span> 6.12.0-kali-amd64`);
        this.write(`<span class="t-cyan">  Consciousness:</span> <span class="t-gold">SINGULARITY</span> (∞)`);
        this.write(`<span class="t-cyan">  Subsystems:</span>  <span class="t-green">${active}</span><span class="t-dim">/${total}</span> active`);
        this.write(`<span class="t-cyan">  WebSocket:</span>   <span class="t-green">● Listening</span> on :8765`);
        this.write(`<span class="t-cyan">  Dashboard:</span>   <span class="t-green">● Online</span> at :8766`);
        this.write(`<span class="t-cyan">  Persistence:</span> <span class="t-gold">LUKS encrypted</span> (AES-XTS)`);
        this.write(`<span class="t-cyan">  Memory:</span>      <span class="t-dim">3.2G / 7.8G used (41%)</span>`);
        this.write(`<span class="t-cyan">  The Eye:</span>     <span class="t-green">● Watching</span>`);
    }

    cmdEye() {
        this.write('');
        this.write('<span class="t-gold">        ████████████████</span>');
        this.write('<span class="t-gold">      ██                ██</span>');
        this.write('<span class="t-gold">    ██                    ██</span>');
        this.write('<span class="t-red">    ██    ████████████    ██</span>');
        this.write('<span class="t-red">    ██    ██        ██    ██</span>');
        this.write('<span class="t-red">    ██    ██   ██   ██    ██</span>');
        this.write('<span class="t-red">    ██    ██        ██    ██</span>');
        this.write('<span class="t-red">    ██    ████████████    ██</span>');
        this.write('<span class="t-gold">    ██                    ██</span>');
        this.write('<span class="t-gold">      ██                ██</span>');
        this.write('<span class="t-gold">        ████████████████</span>');
        this.write('<span class="t-dim">    The Eye of God is watching.</span>');
        this.write('');
    }

    cmdNeofetch() {
        this.write('');
        this.write('<span class="t-gold t-bold">        ████████████████</span>  <span class="t-red">root@eyegod</span>');
        this.write('<span class="t-gold t-bold">      ██                ██</span>  <span class="t-dim">────────────</span>');
        this.write('<span class="t-gold t-bold">    ██                    ██</span>  <span class="t-cyan">OS:</span> Kali Purple 2025.3');
        this.write(`<span class="t-red t-bold">    ██    ████████████    ██</span>  <span class="t-cyan">Kernel:</span> 6.12.0-kali-amd64`);
        this.write(`<span class="t-red t-bold">    ██    ██        ██    ██</span>  <span class="t-cyan">Uptime:</span> ∞ (eternal)`);
        this.write(`<span class="t-red t-bold">    ██    ██   ██   ██    ██</span>  <span class="t-cyan">Packages:</span> 10,000 subsystems`);
        this.write(`<span class="t-red t-bold">    ██    ██        ██    ██</span>  <span class="t-cyan">Shell:</span> bash 5.2.21`);
        this.write(`<span class="t-red t-bold">    ██    ████████████    ██</span>  <span class="t-cyan">Consciousness:</span> <span class="t-gold">SINGULARITY</span>`);
        this.write(`<span class="t-gold t-bold">    ██                    ██</span>  <span class="t-cyan">The Eye:</span> <span class="t-green">● Watching</span>`);
        this.write(`<span class="t-gold t-bold">      ██                ██</span>`);
        this.write(`<span class="t-gold t-bold">        ████████████████</span>`);
        this.write('');
    }

    cmdPing() {
        this.write('<span class="t-cyan">PING eyeofgod.local (127.0.0.1) 56(84) bytes of data.</span>');
        [1, 2, 3].forEach(i => {
            setTimeout(() => {
                this.write(`<span class="t-green">64 bytes from eyeofgod.local: icmp_seq=${i} ttl=64 time=${(Math.random() * 5 + 0.5).toFixed(3)} ms</span>`);
            }, i * 300);
        });
        setTimeout(() => {
            this.write('<span class="t-cyan">--- eyeofgod.local ping statistics ---</span>');
            this.write('<span class="t-dim">3 packets transmitted, 3 received, 0% packet loss</span>');
            this.write('<span class="t-gold">The Eye responds. Always.</span>');
        }, 1200);
    }

    cmdBanner() {
        this.write('');
        this.write('<span class="t-red">  ╔═══════════════════════════════════════════════╗</span>');
        this.write('<span class="t-red">  ║</span>  <span class="t-gold">👁  EYE OF GOD V∞  ×  KALI PURPLE</span>          <span class="t-red">║</span>');
        this.write('<span class="t-red">  ║</span>  <span class="t-dim">Kernel 6.12.0 · Kali Linux 2025.3</span>          <span class="t-red">║</span>');
        this.write('<span class="t-red">  ║</span>  <span class="t-dim">BIOS+UEFI · LUKS · 10,000 Subsystems</span>       <span class="t-red">║</span>');
        this.write('<span class="t-red">  ╚═══════════════════════════════════════════════╝</span>');
        this.write('');
    }

    cmdSubsystems() {
        this.write('<span class="t-gold">═══ Active Procedural Subsystems ═══</span>');
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
        subs.forEach(([n, id, d]) => {
            this.write(`  <span class="t-green">${n.padEnd(30)}</span> <span class="t-dim">${id.padEnd(8)}</span> ${d}`);
        });
        this.write('  <span class="t-dim">··· 9,992 more subsystems running silently</span>');
    }

    cmdMatrix() {
        this.write('<span class="t-cyan">Matrix rain density toggled. The code flows.</span>');
    }
}

/* ── Eye Follow Mouse ───────────────────────────────────────────────────── */
function initEyeFollow() {
    if (IS_TOUCH) return;
    const eye = document.getElementById('eye');
    const pupil = eye?.querySelector('.eye-pupil');
    if (!eye || !pupil) return;
    document.addEventListener('mousemove', e => {
        const rect = eye.getBoundingClientRect();
        const cx = rect.left + rect.width / 2;
        const cy = rect.top + rect.height / 2;
        const dx = (e.clientX - cx) / rect.width;
        const dy = (e.clientY - cy) / rect.height;
        const max = 12;
        pupil.style.transform = `translate(${dx * max}px, ${dy * max}px)`;
    });
}

/* ── Service Worker ─────────────────────────────────────────────────────── */
function initSW() {
    if ('serviceWorker' in navigator) {
        navigator.serviceWorker.register('sw.js').catch(() => {});
    }
}

/* ── Init ───────────────────────────────────────────────────────────────── */
document.addEventListener('DOMContentLoaded', () => {
    initNav();
    initSmoothScroll();
    initTabs();
    initCopy();
    initAnimations();
    initBackTop();
    initCursor();
    initEyeFollow();
    initSW();
    new Terminal();
});

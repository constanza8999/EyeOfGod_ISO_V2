/* ═══════════════════════════════════════════════════════════════════════════╗
   ║  EYE OF GOD V∞ × KALI PURPLE — GitHub Pages Scripts                  ║
   ║  Interactions, animations, typing effect, particle background          ║
   ╚══════════════════════════════════════════════════════════════════════════╝ */

'use strict';

/* ── Particle Background ──────────────────────────────────────────────────── */
class ParticleField {
    constructor() {
        this.canvas = document.createElement('canvas');
        this.ctx = this.canvas.getContext('2d');
        this.particles = [];
        this.mouse = { x: 0, y: 0 };
        
        const container = document.getElementById('particles');
        container.appendChild(this.canvas);
        
        this.resize();
        this.init();
        this.animate();
        
        window.addEventListener('resize', () => this.resize());
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
        const count = Math.floor((window.innerWidth * window.innerHeight) / 8000);
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
            
            // Mouse interaction
            const dx = this.mouse.x - p.x;
            const dy = this.mouse.y - p.y;
            const dist = Math.sqrt(dx * dx + dy * dy);
            if (dist < 100) {
                p.x -= dx * 0.005;
                p.y -= dy * 0.005;
            }
            
            // Draw particle
            this.ctx.beginPath();
            this.ctx.arc(p.x, p.y, p.size, 0, Math.PI * 2);
            this.ctx.fillStyle = `rgba(139, 0, 0, ${p.opacity})`;
            this.ctx.fill();
            
            // Draw connections
            for (let j = i + 1; j < this.particles.length; j++) {
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
        });
        
        requestAnimationFrame(() => this.animate());
    }
}

/* ── Typewriter Effect ────────────────────────────────────────────────────── */
class Typewriter {
    constructor(element, phrases, speed = 80) {
        this.element = element;
        this.phrases = phrases;
        this.speed = speed;
        this.phraseIndex = 0;
        this.charIndex = 0;
        this.isDeleting = false;
        this.type();
    }
    
    type() {
        const current = this.phrases[this.phraseIndex];
        
        if (!this.isDeleting) {
            this.element.textContent = current.slice(0, this.charIndex);
            this.charIndex++;
            
            if (this.charIndex > current.length) {
                this.isDeleting = true;
                setTimeout(() => this.type(), 2000);
                return;
            }
        } else {
            this.element.textContent = current.slice(0, this.charIndex);
            this.charIndex--;
            
            if (this.charIndex < 0) {
                this.isDeleting = false;
                this.phraseIndex = (this.phraseIndex + 1) % this.phrases.length;
                setTimeout(() => this.type(), 500);
                return;
            }
        }
        
        setTimeout(() => this.type(), this.isDeleting ? this.speed / 2 : this.speed);
    }
}

/* ── Navbar Scroll Effect ─────────────────────────────────────────────────── */
function initNavbar() {
    const navbar = document.getElementById('navbar');
    let lastScroll = 0;
    
    window.addEventListener('scroll', () => {
        const currentScroll = window.scrollY;
        
        if (currentScroll > 50) {
            navbar.classList.add('scrolled');
        } else {
            navbar.classList.remove('scrolled');
        }
        
        lastScroll = currentScroll;
    });
}

/* ── Mobile Hamburger Menu ────────────────────────────────────────────────── */
function initHamburger() {
    const hamburger = document.querySelector('.hamburger');
    const navLinks = document.querySelector('.nav-links');
    
    hamburger.addEventListener('click', () => {
        const isExpanded = navLinks.classList.toggle('active');
        hamburger.classList.toggle('active');
        hamburger.setAttribute('aria-expanded', isExpanded);
    });
    
    // Keyboard support
    hamburger.addEventListener('keydown', (e) => {
        if (e.key === 'Enter' || e.key === ' ') {
            e.preventDefault();
            hamburger.click();
        }
    });
    
    // Close menu on link click
    document.querySelectorAll('.nav-links a').forEach(link => {
        link.addEventListener('click', () => {
            navLinks.classList.remove('active');
            hamburger.classList.remove('active');
        });
    });
}

/* ── OS Tab Switcher ──────────────────────────────────────────────────────── */
function initTabs() {
    const tabs = document.querySelectorAll('.os-tab');
    
    tabs.forEach(tab => {
        tab.addEventListener('click', () => {
            tabs.forEach(t => t.classList.remove('active'));
            tab.classList.add('active');
            
            const os = tab.dataset.os;
            document.querySelectorAll('.code-block').forEach(block => {
                block.classList.add('hidden');
            });
            document.getElementById(`code-${os}`).classList.remove('hidden');
        });
    });
}

/* ── Copy Code Button ─────────────────────────────────────────────────────── */
window.copyCode = function(elementId) {
    const codeElement = document.getElementById(elementId);
    const text = codeElement.textContent;
    
    navigator.clipboard.writeText(text).then(() => {
        const btn = codeElement.parentElement.querySelector('.copy-btn');
        const icon = btn.querySelector('i');
        const originalText = btn.innerHTML;
        
        btn.innerHTML = '<i class="fas fa-check"></i> Copied!';
        btn.style.color = '#27c93f';
        btn.style.borderColor = '#27c93f';
        
        setTimeout(() => {
            btn.innerHTML = originalText;
            btn.style.color = '';
            btn.style.borderColor = '';
        }, 2000);
    });
};

/* ── Intersection Observer for Feature Cards ──────────────────────────────── */
function initAnimations() {
    const observer = new IntersectionObserver((entries) => {
        entries.forEach(entry => {
            if (entry.isIntersecting) {
                entry.target.style.animationPlayState = 'running';
            }
        });
    }, { threshold: 0.1 });
    
    document.querySelectorAll('.feature-card').forEach(card => {
        const delay = card.dataset.delay || 0;
        card.style.animation = `fade-in-up 0.6s ease ${delay}ms forwards`;
        card.style.animationPlayState = 'paused';
        observer.observe(card);
    });
}

/* ── Initialize Everything ────────────────────────────────────────────────── */
document.addEventListener('DOMContentLoaded', () => {
    // Particle background
    new ParticleField();
    
    // Typewriter
    const typewriterElement = document.getElementById('typewriter');
    if (typewriterElement) {
        new Typewriter(typewriterElement, [
            'Kernel 6.12.0 · Kali Linux 2025.3',
            'BIOS + UEFI Hybrid Boot',
            'LUKS Encrypted Persistence',
            '10,000 Procedural Subsystems',
            'NIST CSF · MITRE ATT&CK',
            '40+ GRUB Boot Entries',
            '👁 The Eye Is Watching'
        ]);
    }
    
    // UI
    initNavbar();
    initHamburger();
    initTabs();
    initAnimations();
    
    // Smooth scroll for anchor links
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
});

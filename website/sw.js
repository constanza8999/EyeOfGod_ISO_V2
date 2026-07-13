/* ═══════════════════════════════════════════════════════════════════════════╗
   ║  EYE OF GOD V∞ × KALI PURPLE — Service Worker (Offline Support)       ║
   ╚══════════════════════════════════════════════════════════════════════════╝ */

const CACHE_NAME = 'eyegod-v1';
const ASSETS = [
    '.',
    'index.html',
    'css/style.css',
    'js/script.js',
    'manifest.json'
];

// Install: cache core assets
self.addEventListener('install', (event) => {
    event.waitUntil(
        caches.open(CACHE_NAME).then((cache) => {
            return cache.addAll(ASSETS);
        }).then(() => {
            return self.skipWaiting();
        })
    );
});

// Activate: clean old caches
self.addEventListener('activate', (event) => {
    event.waitUntil(
        caches.keys().then((cacheNames) => {
            return Promise.all(
                cacheNames
                    .filter((name) => name !== CACHE_NAME)
                    .map((name) => caches.delete(name))
            );
        }).then(() => {
            return self.clients.claim();
        })
    );
});

// Fetch: serve from cache, fallback to network
self.addEventListener('fetch', (event) => {
    // Only handle GET requests
    if (event.request.method !== 'GET') return;

    event.respondWith(
        caches.match(event.request).then((cached) => {
            if (cached) return cached;

            return fetch(event.request).then((response) => {
                // Cache successful responses for future offline use
                if (response && response.status === 200) {
                    const clone = response.clone();
                    caches.open(CACHE_NAME).then((cache) => {
                        cache.put(event.request, clone);
                    });
                }
                return response;
            }).catch(() => {
                // Offline fallback for HTML pages
                if (event.request.headers.get('Accept').includes('text/html')) {
                    return caches.match('index.html');
                }
            });
        })
    );
});

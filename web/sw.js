const CACHE_NAME = 'hipzi-cache-v2';
const APP_ROOT = new URL('./', self.location.href);
const urlsToCache = [
  APP_ROOT.href,
  new URL('assets/images/pwa-icon-192.png', APP_ROOT).href,
  new URL('assets/images/pwa-icon-512.png', APP_ROOT).href
];

self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then(cache => cache.addAll(urlsToCache)
        .catch(error => console.warn('Cache addAll failed:', error)))
  );
});

self.addEventListener('activate', event => {
  event.waitUntil(
    caches.keys()
      .then(keys => Promise.all(
        keys.filter(key => key !== CACHE_NAME).map(key => caches.delete(key))
      ))
      .then(() => self.clients.claim())
  );
});

self.addEventListener('fetch', event => {
  if (event.request.method !== 'GET'
      || new URL(event.request.url).origin !== self.location.origin) {
    return;
  }

  event.respondWith(
    caches.match(event.request)
      .then(response => response || fetch(event.request))
  );
});

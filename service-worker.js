// Service worker simple : met en cache l'appli (structure + données)
// pour qu'elle puisse s'ouvrir même sans connexion internet après
// une première visite. Le fond de carte OpenStreetMap, lui, a besoin
// d'internet pour charger de nouvelles zones (sauf zones déjà visitées
// et donc déjà mises en cache par le navigateur).

const CACHE_NAME = 'rando-fianarantsoa-v1';
const FICHIERS_A_METTRE_EN_CACHE = [
  './',
  './index.html',
  './manifest.json',
  './data/sites_rando.geojson',
  './data/circuits_rando.geojson'
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    caches.open(CACHE_NAME).then((cache) => cache.addAll(FICHIERS_A_METTRE_EN_CACHE))
  );
  self.skipWaiting();
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((noms) =>
      Promise.all(noms.filter(n => n !== CACHE_NAME).map(n => caches.delete(n)))
    )
  );
  self.clients.claim();
});

// Stratégie : essayer le réseau d'abord, retomber sur le cache si hors-ligne
self.addEventListener('fetch', (event) => {
  event.respondWith(
    fetch(event.request)
      .then((reponse) => {
        // Met aussi à jour le cache avec la version fraîche
        const copie = reponse.clone();
        caches.open(CACHE_NAME).then((cache) => cache.put(event.request, copie));
        return reponse;
      })
      .catch(() => caches.match(event.request))
  );
});

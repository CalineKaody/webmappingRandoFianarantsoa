# Guide complet — Webmapping des sites de randonnée & circuits écotouristiques de la région de Fianarantsoa

**Stack retenue :** Leaflet (frontend) + OpenStreetMap (fond de carte) + GeoServer (serveur de données/WMS)
**Objectif :** avoir une démo fonctionnelle et présentable en 2 jours.

---

## 0. Vue d'ensemble de l'architecture

```
Navigateur (Leaflet + HTML/CSS/JS)
        │
        │  requêtes WMS/WFS (couches cartographiques)
        ▼
   GeoServer (serveur cartographique)
        │
        │  lit les données
        ▼
Fichiers GeoJSON / Shapefile  (ou base PostGIS si tu as le temps)
```

Le fond de carte (routes, villes, relief) vient directement d'OpenStreetMap.
Tes données métier (sites de randonnée, circuits) sont stockées en GeoJSON/Shapefile, publiées par GeoServer en WMS, et affichées par Leaflet par-dessus le fond OSM.

Pour la démo la plus sûre : Leaflet peut aussi charger directement les fichiers GeoJSON **sans passer par GeoServer** (c'est ce que fait le fichier `index.html` fourni). GeoServer devient alors une **couche supplémentaire** que tu ajoutes en Jour 2 pour montrer que tu maîtrises la partie serveur — mais si GeoServer plante le jour de la présentation, ton appli fonctionne quand même.

---

## JOUR 1 — Installation + données

### Étape 1 — Installer GeoServer

1. Prérequis : Java (JDK 11 ou 17). Vérifie avec `java -version` dans un terminal / invite de commandes.
   - Si absent, télécharge Java (Adoptium/Temurin) : https://adoptium.net/
2. Télécharge GeoServer (version stable, "Platform Independent Binary" ou l'installeur Windows) :
   https://geoserver.org/download/
3. Windows : décompresse l'archive, puis dans `bin/`, lance `startup.bat`.
   (Ou utilise l'installeur Windows qui installe GeoServer comme service.)
4. Une fois lancé, ouvre dans ton navigateur : `http://localhost:8080/geoserver`
5. Connecte-toi à l'interface d'admin :
   - Identifiant par défaut : `admin`
   - Mot de passe par défaut : `geoserver`
   - **Change le mot de passe** dans Sécurité > Utilisateurs si tu dois le présenter en ligne.

> Si tu bloques sur l'installation, une alternative rapide : GeoServer via Docker (`docker run -p 8080:8080 kartoza/geoserver`) si Docker est déjà installé sur ta machine.

### Étape 2 — Créer un Workspace et publier tes données

1. Dans l'interface GeoServer : **Data > Workspaces > Add new workspace**
   - Nom : `fianarantsoa`
   - URI : `http://fianarantsoa.mg` (n'importe quelle URI unique, pas besoin d'être un vrai site)
2. **Data > Stores > Add new Store > GeoJSON / Shapefile** (selon le format)
   - Choisis le workspace `fianarantsoa`
   - Importe les fichiers `sites_rando.geojson` et `circuits_rando.geojson` fournis (un store par fichier, ou regroupe-les dans un dossier shapefile si tu convertis via QGIS — voir Étape 3)
3. **Publish** la couche : donne-lui un nom (`sites_rando`, `circuits_rando`), définis le système de coordonnées **EPSG:4326** (WGS84 — c'est le standard GPS/web), et calcule l'étendue (bounding box) automatiquement.
4. Teste : dans **Layer Preview**, clique sur "OpenLayers" à côté de ta couche. Si la carte s'affiche, c'est publié correctement.
5. Ton URL WMS ressemblera à :
   `http://localhost:8080/geoserver/fianarantsoa/wms`

### Étape 3 — Installer QGIS (pour préparer/valider tes données)

1. Télécharge QGIS (gratuit) : https://qgis.org/download/
2. Utilité pour toi :
   - Ouvrir/valider tes fichiers GeoJSON avant de les publier
   - Convertir un GeoJSON en Shapefile si GeoServer galère avec un format
   - Ajouter/corriger des points ou tracés à la souris si tu as de vraies coordonnées à intégrer
   - Vérifier le système de projection (doit être **EPSG:4326**)
3. Pour ouvrir un GeoJSON : **Couche > Ajouter une couche > Ajouter une couche vecteur**, sélectionne le fichier.

### Étape 4 — Les données : que faire si tu n'en as pas ?

Trois options, à combiner selon le temps disponible :

**Option A — Utiliser les données d'exemple fournies (le plus sûr pour respecter le délai)**
Les fichiers `sites_rando.geojson` et `circuits_rando.geojson` fournis contiennent déjà 6 sites réels de la région (Ranomafana, Anja, Tsaranoro, Andringitra, Chutes de la Lily, Fianarantsoa ville) et 4 circuits types. Les coordonnées des sites sont réalistes ; les tracés des circuits sont schématiques (à affiner si tu as de vraies traces GPS).

**Option B — Extraire de vraies données depuis OpenStreetMap (Overpass Turbo)**
Si tu veux des sentiers réels déjà cartographiés sur OSM autour de Fianarantsoa :
1. Va sur https://overpass-turbo.eu/
2. Exemple de requête pour les sentiers de randonnée dans la région :
```
[out:json][timeout:25];
area["name"="Fianarantsoa"]->.searchArea;
(
  way["highway"="path"](area.searchArea);
  way["route"="hiking"](area.searchArea);
);
out geom;
```
3. Clique sur "Run", puis **Export > download / GeoJSON**.
4. Importe ce fichier dans QGIS pour vérifier, puis dans GeoServer.

**Option C — Demander à un ami/contact local des GPX/coordonnées réelles**
Si un ami a fait ces randonnées avec une appli GPS (Strava, Maps.me, OsmAnd), il peut t'exporter un fichier `.gpx`. QGIS sait importer un GPX directement (**Ajouter une couche vecteur**, choisis le fichier `.gpx` — il proposera les tracks, waypoints, routes).

> Pour la soutenance, dis clairement : *"les données de démonstration sont basées sur des sites réels avec coordonnées approximatives ; en conditions réelles, elles seraient collectées par GPS/GPX ou récupérées via OpenStreetMap"* — c'est une réponse tout à fait normale et attendue pour un projet de 2 jours.

---

## JOUR 2 — Frontend Leaflet + finitions + présentation

### Étape 5 — Lancer l'application Leaflet fournie

Le fichier `index.html` (avec le dossier `data/` à côté) est une appli complète : fond OSM, sites (points colorés par difficulté), circuits (lignes), sidebar avec filtres, légende, popups d'info.

**Important : il faut la lancer via un serveur local**, pas juste double-cliquer sur le fichier (sinon le chargement des `.geojson` est bloqué par le navigateur).

- Si tu as Python installé, dans le dossier du projet :
  ```
  python -m http.server 8000
  ```
  puis ouvre `http://localhost:8000` dans ton navigateur.
- Ou avec VS Code : installe l'extension **Live Server**, clic droit sur `index.html` > "Open with Live Server".

### Étape 6 — Connecter GeoServer à Leaflet (bonus, montre la maîtrise du serveur)

Dans `index.html`, la section 2 du script contient un bloc commenté :
```js
const wmsLayer = L.tileLayer.wms('http://localhost:8080/geoserver/fianarantsoa/wms', {
  layers: 'fianarantsoa:circuits_rando',
  format: 'image/png',
  transparent: true
});
wmsLayer.addTo(map);
```
Une fois ta couche publiée dans GeoServer (Étape 2), décommente ce bloc et adapte le nom de la couche (`fianarantsoa:circuits_rando`). Ça affichera la couche **servie par GeoServer** par-dessus la couche GeoJSON locale — parfait pour montrer à l'oral que ton architecture serveur fonctionne réellement.

### Étape 7 — Personnalisation / finitions

Idées rapides à fort impact visuel pour la soutenance :
- Change les couleurs dans le CSS (`--vert-foret`, `--vert-clair`, `--terre`) si tu veux une autre identité visuelle.
- Ajoute une photo dans chaque popup (`popupSite`) si tu as des images libres de droit des sites (Wikimedia Commons est une bonne source).
- Ajoute un titre/logo de ton établissement dans le header.

### Étape 8 — Préparer la présentation

Structure conseillée (10-15 min) :
1. **Contexte & objectif** : pourquoi le webmapping pour valoriser la randonnée/écotourisme à Fianarantsoa
2. **Architecture technique** : le schéma de la section 0 (Leaflet / OSM / GeoServer)
3. **Démo live** : ouvre l'appli, montre les filtres, clique sur un site, montre un circuit
4. **Partie serveur** : montre l'interface GeoServer, la couche publiée, éventuellement la requête WMS brute dans un nouvel onglet (`http://localhost:8080/geoserver/fianarantsoa/wms?service=WMS&request=GetMap&layers=fianarantsoa:sites_rando&...`)
5. **Limites & perspectives** : données de démo à remplacer par de vraies collectes GPS/OSM, ajout possible de PostGIS, application mobile de collecte terrain, etc.

---

## Récap des liens utiles

| Outil | Lien |
|---|---|
| Java (JDK) | https://adoptium.net/ |
| GeoServer | https://geoserver.org/download/ |
| QGIS | https://qgis.org/download/ |
| Leaflet (doc) | https://leafletjs.com/reference.html |
| Overpass Turbo (extraction OSM) | https://overpass-turbo.eu/ |
| OpenStreetMap | https://www.openstreetmap.org |

---

## Planning suggéré (2 jours)

**Jour 1 (matin)** : installer Java + GeoServer, vérifier que l'interface admin s'ouvre
**Jour 1 (après-midi)** : installer QGIS, valider les fichiers GeoJSON fournis, publier les couches dans GeoServer
**Jour 1 (soir)** : si le temps le permet, tenter l'extraction Overpass Turbo pour de vraies données

**Jour 2 (matin)** : lancer `index.html` en local, tester tous les filtres/popups, connecter la couche WMS
**Jour 2 (après-midi)** : finitions visuelles, captures d'écran de secours (au cas où le wifi de la salle pose problème), préparer le discours
**Jour 2 (soir)** : répétition de la soutenance

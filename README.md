# Webmapping des sites de randonnée de Fianarantsoa

Application web cartographique présentant des sites de randonnée et des circuits écotouristiques de la région de Fianarantsoa (Madagascar). Les données sont stockées dans une base **PostgreSQL/PostGIS** et publiées par **GeoServer** (WMS), puis affichées avec **Leaflet** sur un fond **OpenStreetMap**.

<!-- Ajouter ici une capture d'écran : ![Carte de l'application](images/carte.png) -->

## Fonctionnalités

- Carte interactive avec 6 sites (points) et 4 circuits (lignes), colorés selon la difficulté
- Filtres par type de couche et par niveau de difficulté, liste des sites et fenêtres d'information
- Couche WMS publiée par GeoServer à partir de PostGIS
- Localisation GPS de l'utilisateur
- Signalement d'un point par l'utilisateur (stocké localement dans le navigateur, voir « Limites »)
- Application installable (PWA) avec mise en cache pour un usage hors connexion limité

## Architecture

```
Navigateur (Leaflet + HTML/CSS/JS)
   │   ├── fichiers GeoJSON (data/) : sites, circuits, filtres, popups
   │   └── requêtes WMS
   ▼
GeoServer (workspace « fianarantsoa », entrepôt « rando_postgis »)
   ▼
PostgreSQL 18 + PostGIS 3.7 (base « fianarantsoa_rando »)
```

## Technologies

Leaflet 1.9, OpenStreetMap, GeoServer (WMS), PostgreSQL/PostGIS, QGIS (import des Shapefiles d'origine), HTML/CSS/JavaScript, GeoJSON, service worker (PWA).

## Base de données

Base `fianarantsoa_rando`, schéma `public`, système de coordonnées **EPSG:4326**, colonne géométrique `geom`, clé primaire `id` et index spatial (GiST) sur chaque table.

| Table | Géométrie | Contenu | Attributs |
|---|---|---|---|
| `sites_rando` | Point | 6 sites : Ranomafana, Anja, Tsaranoro, Andringitra, Chutes de la Lily, Fianarantsoa ville | `nom`, `categorie`, `difficulte`, `duree`, `descriptio`, `altitude_m`, `image` |
| `circuits_rando` | LineString | 4 circuits écotouristiques | `nom`, `type`, `distance_k`, `duree`, `difficulte`, `descriptio` |

Les Shapefiles d'origine ont été importés dans PostGIS avec le gestionnaire de bases de données de QGIS (les noms de champs de plus de 10 caractères sont tronqués par le format Shapefile, d'où `descriptio` et `distance_k`). Le script `db/schema_et_donnees.sql` permet de recréer la base sans passer par QGIS.

### Recréer la base

```bash
createdb -U postgres fianarantsoa_rando
psql -U postgres -d fianarantsoa_rando -f db/schema_et_donnees.sql
```

## Configuration de GeoServer

1. Créer le workspace `fianarantsoa`.
2. Créer un entrepôt de type **PostGIS** nommé `rando_postgis` : hôte `localhost`, port `5432`, base `fianarantsoa_rando`, schéma `public`, utilisateur `postgres` et votre mot de passe (à ne jamais publier dans le dépôt).
3. Publier les couches `fianarantsoa:sites_rando` et `fianarantsoa:circuits_rando`, en EPSG:4326, avec calcul automatique de l'emprise.
4. Vérifier avec **Aperçu de la couche > OpenLayers**.

## Lancer l'application

Ouvrir directement `index.html` par double-clic ne suffit pas : le navigateur bloque le chargement des fichiers GeoJSON. Il faut un petit serveur local.

1. Démarrer PostgreSQL (service Windows).
2. Démarrer GeoServer : dans une invite de commandes en administrateur, `cd "C:\Program Files\GeoServer\bin"` puis `startup.bat`. Si le port 8080 est déjà utilisé, arrêter d'abord l'autre programme. Laisser la fenêtre ouverte.
3. Dans le dossier du projet : `python -m http.server 8000`
4. Ouvrir `http://localhost:8000`.

Sans GeoServer, la carte fonctionne, mais la couche WMS (circuits en bleu) n'apparaît pas. Pour tester sur un téléphone connecté au même réseau, ouvrir `http://IP-DU-PC:8000` : l'adresse de GeoServer suit automatiquement celle de la page.

## Captures d'écran

<!-- Ajouter les captures dans un dossier images/ puis les afficher ici, par exemple :
![Application](images/application.png)
![Couches GeoServer](images/geoserver-couches.png)
![Tables dans pgAdmin](images/pgadmin-tables.png)
![Connexion PostGIS dans QGIS](images/qgis.png)
-->

## Limites et perspectives

- **Données de démonstration** : les coordonnées des sites sont approximatives et les tracés des circuits sont schématiques. Pour un usage réel, les remplacer par des traces GPS ou des données OpenStreetMap.
- **Les couches interactives (points, popups, filtres) lisent les fichiers GeoJSON** du dossier `data/` ; PostGIS alimente la couche WMS via GeoServer. Une évolution naturelle est de charger aussi les points et les lignes en WFS depuis GeoServer, pour que la base PostGIS soit l'unique source de vérité.
- **Contributions des utilisateurs** : elles sont stockées dans le `localStorage` du navigateur. Les enregistrer dans PostGIS (via GeoServer WFS-T ou une API) permettrait de les partager entre visiteurs.
- À ajouter : sécurisation de GeoServer pour une mise en ligne et automatisation de l'import des données.

## Auteure

Câline Fetison – étudiante en Master SIGD (EMIT) et en Master Objets connectés et cybersécurité (ENI), Madagascar.

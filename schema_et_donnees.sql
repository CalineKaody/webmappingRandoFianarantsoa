-- Base de données : fianarantsoa_rando (PostgreSQL + PostGIS)
-- Recréation :
--   createdb -U postgres fianarantsoa_rando
--   psql -U postgres -d fianarantsoa_rando -f db/schema_et_donnees.sql
-- Données de démonstration : coordonnées approximatives, tracés des circuits schématiques.

CREATE EXTENSION IF NOT EXISTS postgis;

DROP TABLE IF EXISTS public.sites_rando;
DROP TABLE IF EXISTS public.circuits_rando;

CREATE TABLE public.sites_rando (
    id          integer PRIMARY KEY,
    nom         varchar(254),
    categorie   varchar(254),
    difficulte  varchar(254),
    duree       varchar(254),
    descriptio  varchar(254),
    altitude_m  integer,
    image       varchar(254),
    geom        geometry(Point, 4326)
);

CREATE TABLE public.circuits_rando (
    id          integer PRIMARY KEY,
    nom         varchar(254),
    type        varchar(254),
    distance_k  integer,
    duree       varchar(254),
    difficulte  varchar(254),
    descriptio  varchar(254),
    geom        geometry(LineString, 4326)
);

CREATE INDEX sites_rando_geom_idx    ON public.sites_rando    USING GIST (geom);
CREATE INDEX circuits_rando_geom_idx ON public.circuits_rando USING GIST (geom);

INSERT INTO public.sites_rando (id, nom, categorie, difficulte, duree, descriptio, altitude_m, image, geom) VALUES
(1, 'Parc National Ranomafana', 'Parc National', 'Modérée', '2 à 6 heures selon circuit', 'Forêt tropicale humide, lémuriens (dont le grand hapalémur), cascades. L''un des parcs les plus visités de Madagascar.', 1000, NULL, ST_GeomFromText('POINT(47.4321 -21.2555)', 4326)),
(2, 'Réserve Communautaire d''Anja', 'Réserve communautaire', 'Facile', '1 à 2 heures', 'Célèbre pour ses colonies de makis catta (lémurs à queue annelée), massifs granitiques et grottes.', 950, NULL, ST_GeomFromText('POINT(46.9432 -21.8672)', 4326)),
(3, 'Massif du Tsaranoro', 'Randonnée / Escalade', 'Difficile', '1 à 3 jours', 'Parois granitiques spectaculaires, spot international d''escalade, treks de plusieurs jours, villages betsileo.', 1600, NULL, ST_GeomFromText('POINT(46.8833 -22.1667)', 4326)),
(4, 'Parc National Andringitra', 'Parc National', 'Difficile', '2 à 4 jours', 'Deuxième plus haut sommet de Madagascar (Pic Boby / Imarivolanitra), paysages de montagne, forte biodiversité.', 2658, NULL, ST_GeomFromText('POINT(46.9167 -22.2)', 4326)),
(5, 'Chutes de la Lily', 'Cascade', 'Facile', 'Demi-journée', 'Cascade et bassins naturels proches de Fianarantsoa, prisés pour la baignade et le pique-nique.', 900, NULL, ST_GeomFromText('POINT(47.15 -21.35)', 4326)),
(6, 'Ville haute de Fianarantsoa (point de départ)', 'Point de départ / Ville', 'Facile', '1 à 2 heures (visite)', 'Vieille ville coloniale, ruelles pavées, cathédrale, point de départ logistique de la plupart des circuits de la région.', 1200, NULL, ST_GeomFromText('POINT(47.0857 -21.4529)', 4326));

INSERT INTO public.circuits_rando (id, nom, type, distance_k, duree, difficulte, descriptio, geom) VALUES
(1, 'Circuit Talatakely (Ranomafana)', 'Boucle forêt primaire', 6, '3 à 4 heures', 'Modérée', 'Boucle classique du parc de Ranomafana, forte probabilité d''observer des lémuriens.', ST_GeomFromText('LINESTRING(47.4321 -21.2555, 47.436 -21.253, 47.44 -21.256, 47.437 -21.26, 47.4321 -21.2555)', 4326)),
(2, 'Sentier des Makis (Anja)', 'Boucle rochers/forêt', 3, '1h30', 'Facile', 'Sentier balisé à travers les massifs granitiques d''Anja, observation de makis catta.', ST_GeomFromText('LINESTRING(46.9432 -21.8672, 46.945 -21.865, 46.947 -21.868, 46.9432 -21.8672)', 4326)),
(3, 'Trek Camp Catta - Tsaranoro', 'Trek montagne', 12, '1 à 2 jours', 'Difficile', 'Ascension vers les parois du massif du Tsaranoro depuis le Camp Catta.', ST_GeomFromText('LINESTRING(46.8833 -22.1667, 46.89 -22.16, 46.895 -22.15, 46.9 -22.145)', 4326)),
(4, 'Ascension Pic Boby (Andringitra)', 'Trek sommet', 22, '2 à 3 jours', 'Difficile', 'Trek vers le sommet Imarivolanitra (Pic Boby), point culminant du parc, 2658 m.', ST_GeomFromText('LINESTRING(46.9167 -22.2, 46.91 -22.21, 46.905 -22.22, 46.9 -22.23)', 4326));

-- Vérifications
-- SELECT postgis_full_version();
-- SELECT nom, difficulte, ST_AsText(geom) FROM public.sites_rando;
-- SELECT nom, distance_k FROM public.circuits_rando;

\set database_name real_estate

CREATE DATABASE :database_name WITH
  ENCODING = 'utf8'
  LC_COLLATE = 'English'
  LC_CTYPE = 'English'
;

\c :database_name

CREATE EXTENSION postgis;


-- Material type
CREATE TYPE MATERIAL_TYPE AS ENUM (
  'brick',
  'monolith',
  'panel',
  'block',
  'wood',
  'stalin',
  'monolithBrick',
  'old'
  );



CREATE TABLE addresses
(
  id            SERIAL PRIMARY KEY,
  cian_id       INTEGER,
  ru_address    CHARACTER VARYING,
  geom          GEOMETRY(Point, 4326) NOT NULL,
  material_type MATERIAL_TYPE,
  year          INTEGER,
  floors        INTEGER
);
CREATE INDEX addresses_geom_index ON addresses USING gist (geom);
CREATE INDEX addresses_cian_id_index ON addresses USING btree (cian_id);


CREATE TABLE flats
(
  id                SERIAL PRIMARY KEY,
  address_id        INTEGER REFERENCES addresses (id),
  qrooms            INTEGER,
  floor             INTEGER,
  area              NUMERIC,
  kitchen_area      NUMERIC,
  living_area       NUMERIC,
  separate_wc_count INTEGER,
  combined_wc_count INTEGER,
  description       CHARACTER VARYING,
  cian_id           INTEGER,
  link              CHARACTER VARYING
);
CREATE UNIQUE INDEX flats_cian_id_unique ON flats USING btree (cian_id);
CREATE INDEX flats_address_id_index ON flats USING btree (address_id);


CREATE TABLE price_history
(
  flat_id      INTEGER REFERENCES flats (id),
  observe_date DATE NOT NULL,
  price        NUMERIC,
  PRIMARY KEY (flat_id, observe_date)
);


CREATE SCHEMA spatial_data;


CREATE TABLE spatial_data.kad
(
  id   SERIAL PRIMARY KEY,
  geom GEOMETRY(MultiLineString, 32636) NOT NULL,
  name CHARACTER VARYING
);
CREATE INDEX kad_geom_index ON spatial_data.kad USING gist (geom);


CREATE TABLE spatial_data.metro
(
  id   SERIAL PRIMARY KEY,
  geom GEOMETRY(MultiPoint, 32636) NOT NULL,
  name CHARACTER VARYING
);
CREATE INDEX metro_geom_index ON spatial_data.metro USING gist (geom);


CREATE TABLE spatial_data.parks
(
  id   SERIAL PRIMARY KEY,
  geom GEOMETRY(MultiPolygon, 32636) NOT NULL,
  name CHARACTER VARYING,
  area FLOAT
);
CREATE INDEX parks_geom_index ON spatial_data.parks USING gist (geom);


CREATE TABLE spatial_data.schools
(
  id   SERIAL PRIMARY KEY,
  geom GEOMETRY(Point, 32636) NOT NULL,
  name CHARACTER VARYING
);
CREATE INDEX schools_geom_index ON spatial_data.schools USING gist (geom);


CREATE TABLE spatial_data.kindergarten
(
  id   SERIAL PRIMARY KEY,
  geom GEOMETRY(Point, 32636) NOT NULL,
  name CHARACTER VARYING
);
CREATE INDEX kindergarten_geom_index ON spatial_data.kindergarten USING gist (geom);


CREATE TABLE spatial_data.distances
(
  address_id INTEGER PRIMARY KEY REFERENCES public.addresses (id) ON DELETE CASCADE,
  parks      INTEGER NOT NULL,
  metro      INTEGER NOT NULL,
  kad        INTEGER NOT NULL
);
CREATE INDEX distances_park_index ON spatial_data.distances USING btree (parks);
CREATE INDEX distances_metro_index ON spatial_data.distances USING btree (metro);
CREATE INDEX distances_park_kad_index ON spatial_data.distances USING btree (kad);


CREATE OR REPLACE FUNCTION calculate_distances()
  RETURNS TRIGGER
AS
$$
BEGIN
  DELETE
  FROM spatial_data.distances WHERE address_id = new.id;

  INSERT INTO spatial_data.distances
  SELECT a.id,
         st_distance(st_transform(a.geom, 32636), up.geom) AS park_distance,
         st_distance(st_transform(a.geom, 32636), um.geom) AS metro_distance,
         st_distance(st_transform(a.geom, 32636), uk.geom) AS kad_distance
  FROM addresses AS a,
       (SELECT st_union(p.geom) AS geom FROM spatial_data.parks AS p) AS up,
       (SELECT st_union(m.geom) AS geom FROM spatial_data.metro AS m) AS um,
       (SELECT st_union(k.geom) AS geom FROM spatial_data.kad AS k) AS uk
    WHERE
       a.id = new.id;
  RETURN new;
END;
$$
  LANGUAGE plpgsql;


CREATE TRIGGER calculate_addresses_distances
  AFTER UPDATE OR DELETE OR INSERT
  ON addresses
  FOR EACH ROW
EXECUTE PROCEDURE calculate_distances();
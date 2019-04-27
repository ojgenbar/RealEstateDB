\set database_name real_estate

CREATE DATABASE :database_name WITH
    ENCODING = 'utf8'
    LC_COLLATE = 'English'
    LC_CTYPE = 'English'
;

\c :database_name

CREATE EXTENSION postgis;


-- Material type
CREATE TYPE material_type AS ENUM (
    'brick',
    'monolith',
    'panel',
    'block',
    'wood',
    'stalin',
    'monolithBrick',
    'old'
);



CREATE TABLE addresses(
    id serial PRIMARY KEY,
    cian_id integer NOT NULL,
    ru_address character varying,
    geom geometry(Point,4326) NOT NULL,
    material_type material_type,
    year integer,
    floors integer
);
CREATE INDEX addresses_geom_index ON addresses USING gist (geom);
CREATE UNIQUE INDEX addresses_cian_id_unique ON addresses USING btree (cian_id);


CREATE TABLE flats (
    id serial PRIMARY KEY,
    address_id integer REFERENCES addresses (id),
    qrooms integer,
    floor integer,
    area numeric,
    kitchen_area character varying,
    living_area character varying,
    separate_wc_count character varying,
    combined_wc_count character varying,
    description character varying,
    cian_id integer,
    link character varying
);
CREATE UNIQUE INDEX flats_cian_id_unique ON flats USING btree (cian_id);


CREATE TABLE price_history (
    flat_id integer REFERENCES flats(id),
    observe_date date NOT NULL,
    price numeric,
    PRIMARY KEY (flat_id, observe_date)
);


CREATE SCHEMA spatial_data;


CREATE TABLE spatial_data.kad (
    id serial PRIMARY KEY,
    geom geometry(MultiLineString,32636),
    name character varying
);
CREATE INDEX kad_geom_index ON spatial_data.kad USING gist (geom);


CREATE TABLE spatial_data.metro (
    id serial PRIMARY KEY,
    geom geometry(MultiPoint,32636),
    name character varying
);
CREATE INDEX metro_geom_index ON spatial_data.metro USING gist (geom);


CREATE TABLE spatial_data.parks (
    id serial PRIMARY KEY,
    geom geometry(MultiPolygon,32636),
    name character varying,
    area float
);
CREATE INDEX parks_geom_index ON spatial_data.parks USING gist (geom);

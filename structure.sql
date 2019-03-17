CREATE DATABASE real_estate WITH
    ENCODING = 'utf8'
    LC_COLLATE = 'English'
    LC_CTYPE = 'English'
;

\c real_estate

CREATE EXTENSION postgis;


CREATE TABLE districts(
    id serial PRIMARY KEY,
    name character varying
);


CREATE TABLE addresses(
    id serial PRIMARY KEY,
    district_id integer REFERENCES districts (id),
    ru_address character varying,
    en_address character varying UNIQUE,
    geom geometry(Point,4326),
    building_type character varying,
    floors integer
);
CREATE INDEX addresses_geom_index ON addresses USING gist (geom);


CREATE TABLE flats (
    id serial PRIMARY KEY,
    address_id integer REFERENCES addresses (id),
    qrooms integer,
    floor integer,
    area numeric(10,3),
    kitchen_area character varying,
    living_area character varying,
    bathroom character varying,
    abilities character varying,
    agency character varying,
    tel character varying,
    description character varying,
    bn_id integer,
    ad_type integer,
    link character varying UNIQUE,
    UNIQUE (bn_id, ad_type)
);


CREATE TABLE price_history (
    flat_id integer REFERENCES flats(id),
    observe_date date NOT NULL,
    price numeric(10,3),
    price_sqm numeric(20,15),
    PRIMARY KEY (flat_id, observe_date)
);


CREATE SCHEMA spatial_data;


CREATE TABLE spatial_data.kad (
    id serial PRIMARY KEY,
    geom geometry(MultiLineString,32636),
    name character varying(137)
);
CREATE INDEX kad_geom_index ON spatial_data.kad USING gist (geom);


CREATE TABLE spatial_data.metro (
    id serial PRIMARY KEY,
    geom geometry(MultiPoint,32636),
    name character varying(95)
);
CREATE INDEX metro_geom_index ON spatial_data.metro USING gist (geom);


CREATE TABLE spatial_data.parks (
    id bigint NOT NULL,
    geom geometry(MultiPolygon,32636),
    name character varying(254),
    area double precision
);
CREATE INDEX parks_geom_index ON spatial_data.parks USING gist (geom);

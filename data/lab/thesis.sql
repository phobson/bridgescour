-- DATABASE
CREATE DATABASE erosion
  WITH OWNER = paul
       ENCODING = 'UTF8'
       LC_COLLATE = 'en_US.UTF-8'
       LC_CTYPE = 'en_US.UTF-8'
       CONNECTION LIMIT = -1;
       
--TABLES
--calibration table
CREATE TABLE calib
(
  calib_type integer NOT NULL,
  zero_order double precision,
  first_order double precision,
  second_order double precision,
  CONSTRAINT calib_pkey PRIMARY KEY (calib_type)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE calib OWNER TO paul;


--code table
CREATE TABLE codes
(
  code integer NOT NULL,
  descr character varying(50),
  CONSTRAINT codes_pkey PRIMARY KEY (code)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE codes OWNER TO paul;


--erosion
CREATE TABLE erosion
(
  loc_id integer NOT NULL,
  tube_num integer NOT NULL,
  sn integer NOT NULL,
  rn integer NOT NULL,
  disp double precision,
  CONSTRAINT erosion_pkey PRIMARY KEY (loc_id, tube_num, sn, rn)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE erosion OWNER TO paul;


--extrusion
CREATE TABLE extrusion
(
  loc_id integer NOT NULL,
  tube_num integer NOT NULL,
  sn integer NOT NULL,
  rn integer NOT NULL,
  disp double precision,
  CONSTRAINT extrusion_pkey PRIMARY KEY (loc_id, tube_num, sn, rn)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE extrusion OWNER TO paul;


--hydrometer
CREATE TABLE hydrometer
(
  loc_id integer NOT NULL,
  tube_num integer NOT NULL,
  "time" double precision NOT NULL,
  hydr double precision,
  temperature double precision,
  CONSTRAINT hydrometer_pkey PRIMARY KEY (loc_id, tube_num, "time")
)
WITH (
  OIDS=FALSE
);
ALTER TABLE hydrometer OWNER TO paul;


--erosion_info
CREATE TABLE erosion_info
(
  loc_id integer NOT NULL,
  tube_num integer NOT NULL,
  sn integer NOT NULL,
  sf integer,
  tau double precision,
  dur double precision,
  erosion_type integer,
  note character varying(100),
  wcs_sn integer,
  ext_sn integer,
  CONSTRAINT erosion_info_pkey PRIMARY KEY (loc_id, tube_num, sn)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE erosion_info OWNER TO paul;


--extrusion_info
CREATE TABLE extrusion_info
(
  loc_id integer NOT NULL,
  tube_num integer NOT NULL,
  sn integer NOT NULL,
  sf integer,
  dur double precision,
  in1 integer,
  in2 double precision,
  mms double precision,
  msw double precision,
  note character varying(100),
  wcs_sn integer,
  CONSTRAINT extrusion_info_pkey PRIMARY KEY (loc_id, tube_num, sn)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE extrusion_info OWNER TO paul;


--hydrometer_info
CREATE TABLE hydrometer_info
(
  loc_id integer NOT NULL,
  tube_num integer NOT NULL,
  mps double precision,
  note character varying(75),
  wcs_sn integer,
  CONSTRAINT hydrometer_info_pkey PRIMARY KEY (loc_id, tube_num)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE hydrometer_info OWNER TO paul;


--yieldstress_info
CREATE TABLE yieldstress_info
(
  loc_id integer NOT NULL,
  tube_num integer NOT NULL,
  sn integer NOT NULL,
  tmin double precision,
  tmax double precision,
  dur integer,
  mc double precision,
  mcsw double precision,
  mp double precision,
  mps double precision,
  l11 integer,
  l12 integer,
  u11 integer,
  u12 integer,
  l21 integer,
  l22 integer,
  u21 integer,
  u22 integer,
  x11 double precision,
  x12 double precision,
  y11 double precision,
  y12 double precision,
  x21 double precision,
  x22 double precision,
  y21 double precision,
  y22 double precision,
  CONSTRAINT yieldstress_info_pkey PRIMARY KEY (loc_id, tube_num, sn)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE yieldstress_info OWNER TO paul;


--omd
CREATE TABLE omd
(
  loc_id integer NOT NULL,
  tube_num integer NOT NULL,
  mp double precision,
  mpsa double precision,
  mps double precision,
  CONSTRAINT omd_pkey PRIMARY KEY (loc_id, tube_num)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE omd OWNER TO paul;


--locations
CREATE TABLE locations
(
  id integer NOT NULL,
  county character varying(15),
  river character varying(20),
  road character varying(20),
  phys character varying(40),
  region character varying(25),
  coords point,
  CONSTRAINT locations_pkey PRIMARY KEY (id)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE locations OWNER TO paul;


--sgd
CREATE TABLE sgd
(
  loc_id integer NOT NULL,
  tube_num integer NOT NULL,
  mpync double precision,
  temperature double precision,
  mtot double precision,
  mp double precision,
  mps double precision,
  CONSTRAINT sgd_pkey PRIMARY KEY (loc_id, tube_num)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE sgd OWNER TO paul;


--sieve
CREATE TABLE sieve
(
  loc_id integer NOT NULL,
  tube_num integer NOT NULL,
  dsve double precision NOT NULL,
  msve double precision,
  mtot double precision,
  CONSTRAINT sieve_pkey PRIMARY KEY (loc_id, tube_num, dsve)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE sieve OWNER TO paul;


--tubes
CREATE TABLE tubes
(
  loc_id INT NOT NULL,
  num integer NOT NULL,
  color character varying(50),
  soil_class character varying(50),
  top double precision,
  bottom double precision,
  CONSTRAINT tubes_pkey PRIMARY KEY (loc_id, num)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE tubes OWNER TO paul;


--WCS
CREATE TABLE wcs
(
  loc_id integer NOT NULL,
  tube_num integer NOT NULL,
  sn integer NOT NULL,
  mp double precision,
  mpsw double precision,
  mps double precision,
  wcs_type integer,
  result double precision,
  note character varying(75),
  CONSTRAINT wcs_pkey PRIMARY KEY (loc_id, tube_num, sn)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE wcs OWNER TO paul;

CREATE TABLE yieldstress
(
  loc_id integer NOT NULL,
  tube_num integer NOT NULL,
  sn integer NOT NULL,
  rn integer NOT NULL,
  gam double precision,
  tau double precision,
  eta double precision,
  gmd double precision,
  CONSTRAINT yieldstress_pkey PRIMARY KEY (loc_id, tube_num, sn, rn)
)
WITH (
  OIDS=FALSE
);
ALTER TABLE yieldstress OWNER TO paul;

COPY codes FROM '/home/paul/Documents/bridgescour/data/codes.txt' WITH DELIMITER AS E'\t';
COPY calib FROM '/home/paul/Documents/bridgescour/data/calib.txt' WITH DELIMITER AS E'\t';
COPY tubes FROM '/home/paul/Documents/bridgescour/data/tubes.txt' WITH DELIMITER AS E'\t';
COPY wcs FROM '/home/paul/Documents/bridgescour/data/wcs.txt' WITH DELIMITER AS E'\t';
COPY sieve FROM '/home/paul/Documents/bridgescour/data/sieve.txt' WITH DELIMITER AS E'\t';
COPY omd FROM '/home/paul/Documents/bridgescour/data/omd.txt' WITH DELIMITER AS E'\t';
COPY locations FROM '/home/paul/Documents/bridgescour/data/locations.txt' WITH DELIMITER AS E'\t';
COPY sgd FROM '/home/paul/Documents/bridgescour/data/sgd.txt' WITH DELIMITER AS E'\t';
COPY hydrometer FROM '/home/paul/Documents/bridgescour/data/hydrometer.txt' WITH DELIMITER AS E'\t';
COPY hydrometer_info FROM '/home/paul/Documents/bridgescour/data/hydrometer_info.txt' WITH DELIMITER AS E'\t';
COPY extrusion_info FROM '/home/paul/Documents/bridgescour/data/extrusion_info.txt' WITH DELIMITER AS E'\t';
COPY extrusion FROM '/home/paul/Documents/bridgescour/data/extrusion.txt' WITH DELIMITER AS E'\t';
COPY erosion_info FROM '/home/paul/Documents/bridgescour/data/erosion_info.txt' WITH DELIMITER AS E'\t';
COPY erosion FROM '/home/paul/Documents/bridgescour/data/erosion.txt' WITH DELIMITER AS E'\t';
COPY yieldstress_info FROM '/home/paul/Documents/bridgescour/data/yieldstress_info.txt' WITH DELIMITER AS E'\t';
COPY yieldstress FROM '/home/paul/Documents/bridgescour/data/yieldstress.txt' WITH DELIMITER AS E'\t';




--FOREIGN KEYS
ALTER TABLE calib
  ADD CONSTRAINT calib_lookup FOREIGN KEY (calib_type)
      REFERENCES codes (code) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE;
      
ALTER TABLE erosion
  ADD CONSTRAINT erosion_lookup FOREIGN KEY (loc_id, tube_num, sn)
      REFERENCES erosion_info (loc_id, tube_num, sn) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE;
      
ALTER TABLE extrusion
  ADD CONSTRAINT extrusion_lookup FOREIGN KEY (loc_id, tube_num, sn)
      REFERENCES extrusion_info (loc_id, tube_num, sn) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE;
      
ALTER TABLE hydrometer
  ADD CONSTRAINT hydrometer_lookup FOREIGN KEY (loc_id, tube_num)
      REFERENCES hydrometer_info (loc_id, tube_num) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE;
      
ALTER TABLE erosion_info
  ADD CONSTRAINT erosion_info_erosion_type FOREIGN KEY (erosion_type)
      REFERENCES codes (code) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE;
      
ALTER TABLE erosion_info
  ADD CONSTRAINT erosion_info_to_tubes FOREIGN KEY (loc_id, tube_num)
      REFERENCES tubes (loc_id, num) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE;
      
ALTER TABLE erosion_info
  ADD CONSTRAINT erosion_info_to_wcs FOREIGN KEY (loc_id, tube_num, wcs_sn)
      REFERENCES wcs (loc_id, tube_num, sn) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE;
      
ALTER TABLE erosion_info
  ADD CONSTRAINT erosion_info_to_extrusion_info FOREIGN KEY (loc_id, tube_num, ext_sn)
      REFERENCES extrusion_info (loc_id, tube_num, sn) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE;
      
ALTER TABLE extrusion_info
  ADD CONSTRAINT extrusion_info_to_tubes FOREIGN KEY (loc_id, tube_num)
      REFERENCES tubes (loc_id, num) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE;
      
ALTER TABLE extrusion_info
  ADD CONSTRAINT extrusion_info_to_wcs FOREIGN KEY (loc_id, tube_num, wcs_sn)
      REFERENCES wcs (loc_id, tube_num, sn) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE;
      
ALTER TABLE hydrometer_info
  ADD CONSTRAINT hydrometer_info_to_tubes FOREIGN KEY (loc_id, tube_num)
      REFERENCES tubes (loc_id, num) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE;
      
ALTER TABLE hydrometer_info
  ADD CONSTRAINT hydrometer_info_to_wcs FOREIGN KEY (loc_id, tube_num, wcs_sn)
      REFERENCES wcs (loc_id, tube_num, sn) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE;
      
ALTER TABLE yieldstress_info
  ADD CONSTRAINT yieldstress_info_to_tubes FOREIGN KEY (loc_id, tube_num)
      REFERENCES tubes (loc_id, num) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE;
      
ALTER TABLE omd
  ADD CONSTRAINT omd_to_tubes FOREIGN KEY (loc_id, tube_num)
      REFERENCES tubes (loc_id, num) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE;
      
ALTER TABLE sgd
  ADD CONSTRAINT sgd_to_tubes FOREIGN KEY (loc_id, tube_num)
      REFERENCES tubes (loc_id, num) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE;

ALTER TABLE sieve
  ADD CONSTRAINT sieve_to_tubes FOREIGN KEY (loc_id, tube_num)
      REFERENCES tubes (loc_id, num) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE;
      
ALTER TABLE wcs
  ADD CONSTRAINT wcs_to_tubes FOREIGN KEY (loc_id, tube_num)
      REFERENCES tubes (loc_id, num) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE;
      
ALTER TABLE wcs
  ADD CONSTRAINT wcs_loookup FOREIGN KEY (wcs_type)
      REFERENCES codes (code) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE;
      
ALTER TABLE yieldstress
  ADD CONSTRAINT ysd_lookup FOREIGN KEY (loc_id, tube_num, sn)
      REFERENCES yieldstress_info (loc_id, tube_num, sn) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE;
      
ALTER TABLE tubes
  ADD CONSTRAINT tubes_to_locations FOREIGN KEY (loc_id)
      REFERENCES locations (id) MATCH SIMPLE
      ON UPDATE CASCADE ON DELETE CASCADE;
      


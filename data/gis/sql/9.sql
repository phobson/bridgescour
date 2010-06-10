SET STANDARD_CONFORMING_STRINGS TO ON;
BEGIN;
CREATE TABLE "9table" (gid serial PRIMARY KEY,
"area" float8,
"perimeter" float8,
"gnis_" int8,
"gnis_id" int8,
"gnisid" int4,
"name" varchar(100),
"fclass" varchar(9),
"county" varchar(10),
"fips_code" int4,
"elevation" varchar(6),
"quad_name" varchar(20),
"latitude" float8,
"longitude" float8,
"latitude2" float8,
"longitude2" float8);
SELECT AddGeometryColumn('','9table','the_geom','-1','POINT',2);
INSERT INTO "9table" ("area","perimeter","gnis_","gnis_id","gnisid","name","fclass","county","fips_code","elevation","quad_name","latitude","longitude","latitude2","longitude2",the_geom) VALUES ('0.000','0.000','33127','81475','27687','Long Bridge','bridge','Berrien','13019',NULL,'Nashville West','31.1769','83.3225','0.0000','0.0000','0101000000000000A0BA7AD04000000020A8782B41');
END;

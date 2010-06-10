SET STANDARD_CONFORMING_STRINGS TO ON;
BEGIN;
CREATE TABLE "8table" (gid serial PRIMARY KEY,
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
SELECT AddGeometryColumn('','8table','the_geom','-1','POINT',2);
INSERT INTO "8table" ("area","perimeter","gnis_","gnis_id","gnisid","name","fclass","county","fips_code","elevation","quad_name","latitude","longitude","latitude2","longitude2",the_geom) VALUES ('0.000','0.000','17145','65249','11461','Culbreth Bridge','bridge','Decatur','13087',NULL,'Bainbridge','30.9061','84.5886','0.0000','0.0000','010100000000000060EB54F9C000000040E0912A41');
END;

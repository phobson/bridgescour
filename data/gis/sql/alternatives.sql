SET STANDARD_CONFORMING_STRINGS TO ON;
BEGIN;
CREATE TABLE "alternativestable" (gid serial PRIMARY KEY,
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
"longitude2" float8,
"site" varchar(5));
SELECT AddGeometryColumn('','alternativestable','the_geom','-1','POINT',2);
INSERT INTO "alternativestable" ("area","perimeter","gnis_","gnis_id","gnisid","name","fclass","county","fips_code","elevation","quad_name","latitude","longitude","latitude2","longitude2","site",the_geom) VALUES ('0.000','0.000','7796','55780','1992','Balls Ferry Bridge','bridge','Wilkinson','13319',NULL,'Oconee','32.7817','82.9583','0.0000','0.0000','5c','01010000000000004049A3E840000000C038773041');
INSERT INTO "alternativestable" ("area","perimeter","gnis_","gnis_id","gnisid","name","fclass","county","fips_code","elevation","quad_name","latitude","longitude","latitude2","longitude2","site",the_geom) VALUES ('0.000','0.000','15059','63130','9342','Claxton Bridge','bridge','Evans','13109',NULL,'Claxton','32.1839','81.8889','0.0000','0.0000','5b','0101000000000000801F7402410000002093EE2E41');
INSERT INTO "alternativestable" ("area","perimeter","gnis_","gnis_id","gnisid","name","fclass","county","fips_code","elevation","quad_name","latitude","longitude","latitude2","longitude2","site",the_geom) VALUES ('0.000','0.000','48759','97332','43544','Shepards Bridge','bridge','Tattnall','13267',NULL,'Reidsville West','32.0769','82.1767','0.0000','0.0000','5a','0101000000000000801C5BFE40000000802B8E2E41');
END;

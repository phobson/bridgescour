SET STANDARD_CONFORMING_STRINGS TO ON;
BEGIN;
CREATE TABLE "bridgestable" (gid serial PRIMARY KEY,
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
"site__" int8);
SELECT AddGeometryColumn('','bridgestable','the_geom','-1','POINT',2);
INSERT INTO "bridgestable" ("gnis_","gnis_id","gnisid","name","fclass","county","fips_code","elevation","quad_name","latitude","longitude","latitude2","longitude2","site__",the_geom) VALUES ('0','0','0',NULL,NULL,NULL,'0',NULL,NULL,'0.0000','0.0000','0.0000','0.0000','10','01010000008A775ECE10E00741BCF7AF9A782E2C41');
INSERT INTO "bridgestable" ("gnis_","gnis_id","gnisid","name","fclass","county","fips_code","elevation","quad_name","latitude","longitude","latitude2","longitude2","site__",the_geom) VALUES ('33127','81475','27687','Long Bridge','bridge','Berrien','13019',NULL,'Nashville West','31.1769','83.3225','0.0000','0.0000','9','01010000004734DDAF677FD040C7BE0BACC1782B41');
INSERT INTO "bridgestable" ("gnis_","gnis_id","gnisid","name","fclass","county","fips_code","elevation","quad_name","latitude","longitude","latitude2","longitude2","site__",the_geom) VALUES ('17145','65249','11461','Culbreth Bridge','bridge','Decatur','13087',NULL,'Bainbridge','30.9061','84.5886','0.0000','0.0000','8','010100000000000060EB54F9C000000040E0912A41');
INSERT INTO "bridgestable" ("gnis_","gnis_id","gnisid","name","fclass","county","fips_code","elevation","quad_name","latitude","longitude","latitude2","longitude2","site__",the_geom) VALUES ('0','0','0',NULL,NULL,NULL,'0',NULL,NULL,'0.0000','0.0000','0.0000','0.0000','7','0101000000DCFFF34502DC0A41DEBDB820F0262F41');
INSERT INTO "bridgestable" ("gnis_","gnis_id","gnisid","name","fclass","county","fips_code","elevation","quad_name","latitude","longitude","latitude2","longitude2","site__",the_geom) VALUES ('0','0','0',NULL,NULL,NULL,'0',NULL,NULL,'0.0000','0.0000','0.0000','0.0000','6','01010000006CCFD27539F6C5C01211230E6C8F3041');
INSERT INTO "bridgestable" ("gnis_","gnis_id","gnisid","name","fclass","county","fips_code","elevation","quad_name","latitude","longitude","latitude2","longitude2","site__",the_geom) VALUES ('0','0','0',NULL,NULL,NULL,'0',NULL,NULL,'0.0000','0.0000','0.0000','0.0000','4','0101000000C7F1C1BB7A3603C1C2C95406CE543241');
INSERT INTO "bridgestable" ("gnis_","gnis_id","gnisid","name","fclass","county","fips_code","elevation","quad_name","latitude","longitude","latitude2","longitude2","site__",the_geom) VALUES ('19128','67266','13478','Duncan Bridge','bridge','Habersham','13137',NULL,'Clarkesville','34.5406','83.6228','0.0000','0.0000','3','0101000000000000C06ED2C5C00000002027763341');
INSERT INTO "bridgestable" ("gnis_","gnis_id","gnisid","name","fclass","county","fips_code","elevation","quad_name","latitude","longitude","latitude2","longitude2","site__",the_geom) VALUES ('0','0','0',NULL,NULL,NULL,'0',NULL,NULL,'0.0000','0.0000','0.0000','0.0000','2','0101000000D2D053787522D7C05057EC00CC1F3441');
INSERT INTO "bridgestable" ("gnis_","gnis_id","gnisid","name","fclass","county","fips_code","elevation","quad_name","latitude","longitude","latitude2","longitude2","site__",the_geom) VALUES ('7541','55520','1732','B T Parks Memorial Bridge','bridge','Murray','13213',NULL,'Chatsworth','34.8189','84.7647','0.0000','0.0000','1','0101000000000000A01C03FCC0000000C0B0F23341');
INSERT INTO "bridgestable" ("gnis_","gnis_id","gnisid","name","fclass","county","fips_code","elevation","quad_name","latitude","longitude","latitude2","longitude2","site__",the_geom) VALUES ('0','0','0',NULL,NULL,NULL,'0',NULL,NULL,'0.0000','0.0000','0.0000','0.0000','5','01010000004DC831ACB799E840577D74BB4C773041');
END;

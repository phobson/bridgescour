SET STANDARD_CONFORMING_STRINGS TO ON;
BEGIN;
CREATE TABLE "donetable" (gid serial PRIMARY KEY,
"site__" int8);
SELECT AddGeometryColumn('','donetable','the_geom','-1','POINT',2);
END;

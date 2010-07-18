CREATE TABLE observations (
    sta_id character varying(4),
    obsdate date,
    obstime time without time zone,
    rain real,
    winddir smallint,
    winddirmin smallint,
    winddirmax smallint,
    windspd smallint,
    windgust smallint,
    temp smallint,
    humid smallint,
    dewpnt smallint,
    baro real
);

CREATE TABLE files
    sta_id character varying(4),
    filedate date,
    resettime smallint,
    processed boolean DEFAULT FALSE
);


CREATE TABLE stations (
    id character varying(15) NOT NULL,
    city character varying(50),
    state character varying(2)
    coords point
);

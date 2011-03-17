--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = off;
SET check_function_bodies = false;
SET client_min_messages = warning;
SET escape_string_warning = off;

SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: files; Type: TABLE; Schema: public; Owner: paul; Tablespace: 
--

CREATE TABLE files (
    sta_id character varying(4) NOT NULL,
    filedate smallint NOT NULL,
    resettime smallint,
    processed boolean DEFAULT false
);


ALTER TABLE public.files OWNER TO paul;

--
-- Name: observations; Type: TABLE; Schema: public; Owner: paul; Tablespace: 
--

CREATE TABLE observations (
    sta_id character varying(4),
    filedate smallint,
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
    baro real,
    maintenance boolean DEFAULT false
);


ALTER TABLE public.observations OWNER TO paul;

--
-- Name: stations; Type: TABLE; Schema: public; Owner: paul; Tablespace: 
--

CREATE TABLE stations (
    id character varying(15) NOT NULL,
    city character varying(50),
    state character varying(2),
    coords point
);


ALTER TABLE public.stations OWNER TO paul;

--
-- Data for Name: files; Type: TABLE DATA; Schema: public; Owner: paul
--

COPY files (sta_id, filedate, resettime, processed) FROM stdin;
\.


--
-- Data for Name: observations; Type: TABLE DATA; Schema: public; Owner: paul
--

COPY observations (sta_id, filedate, obsdate, obstime, rain, winddir, winddirmin, winddirmax, windspd, windgust, temp, humid, dewpnt, baro, maintenance) FROM stdin;
\.


--
-- Data for Name: stations; Type: TABLE DATA; Schema: public; Owner: paul
--

COPY stations (id, city, state, coords) FROM stdin;
\.


--
-- Name: files_pkey; Type: CONSTRAINT; Schema: public; Owner: paul; Tablespace: 
--

ALTER TABLE ONLY files
    ADD CONSTRAINT files_pkey PRIMARY KEY (sta_id, filedate);


--
-- Name: sta_pkey; Type: CONSTRAINT; Schema: public; Owner: paul; Tablespace: 
--

ALTER TABLE ONLY stations
    ADD CONSTRAINT sta_pkey PRIMARY KEY (id);


--
-- Name: files_to_station; Type: FK CONSTRAINT; Schema: public; Owner: paul
--

ALTER TABLE ONLY files
    ADD CONSTRAINT files_to_station FOREIGN KEY (sta_id) REFERENCES stations(id) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: obs_to_files; Type: FK CONSTRAINT; Schema: public; Owner: paul
--

ALTER TABLE ONLY observations
    ADD CONSTRAINT obs_to_files FOREIGN KEY (sta_id, filedate) REFERENCES files(sta_id, filedate) ON UPDATE CASCADE ON DELETE CASCADE;


--
-- Name: public; Type: ACL; Schema: -; Owner: postgres
--

REVOKE ALL ON SCHEMA public FROM PUBLIC;
REVOKE ALL ON SCHEMA public FROM postgres;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO PUBLIC;


--
-- PostgreSQL database dump complete
--


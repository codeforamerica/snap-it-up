--
-- PostgreSQL database dump
--

SET statement_timeout = 0;
SET lock_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SET check_function_bodies = false;
SET client_min_messages = warning;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: monitor_events; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE monitor_events (
    id integer NOT NULL,
    monitor_incident_id integer,
    status character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    triggered_at timestamp without time zone NOT NULL,
    screenshot_id character varying,
    screenshot_at timestamp without time zone
);


--
-- Name: monitor_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE monitor_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: monitor_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE monitor_events_id_seq OWNED BY monitor_events.id;


--
-- Name: monitor_incidents; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE monitor_incidents (
    id integer NOT NULL,
    web_service_id integer,
    started_at timestamp without time zone,
    finished_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: monitor_incidents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE monitor_incidents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: monitor_incidents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE monitor_incidents_id_seq OWNED BY monitor_incidents.id;


--
-- Name: que_jobs; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE que_jobs (
    priority smallint DEFAULT 100 NOT NULL,
    run_at timestamp with time zone DEFAULT now() NOT NULL,
    job_id bigint NOT NULL,
    job_class text NOT NULL,
    args json DEFAULT '[]'::json NOT NULL,
    error_count integer DEFAULT 0 NOT NULL,
    last_error text,
    queue text DEFAULT ''::text NOT NULL
);


--
-- Name: TABLE que_jobs; Type: COMMENT; Schema: public; Owner: -
--

COMMENT ON TABLE que_jobs IS '3';


--
-- Name: que_jobs_job_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE que_jobs_job_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: que_jobs_job_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE que_jobs_job_id_seq OWNED BY que_jobs.job_id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: web_services; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE web_services (
    id integer NOT NULL,
    pingometer_id character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    raw_monitor_data jsonb
);


--
-- Name: web_services_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE web_services_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: web_services_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE web_services_id_seq OWNED BY web_services.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY monitor_events ALTER COLUMN id SET DEFAULT nextval('monitor_events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY monitor_incidents ALTER COLUMN id SET DEFAULT nextval('monitor_incidents_id_seq'::regclass);


--
-- Name: job_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY que_jobs ALTER COLUMN job_id SET DEFAULT nextval('que_jobs_job_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY web_services ALTER COLUMN id SET DEFAULT nextval('web_services_id_seq'::regclass);


--
-- Name: monitor_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY monitor_events
    ADD CONSTRAINT monitor_events_pkey PRIMARY KEY (id);


--
-- Name: monitor_incidents_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY monitor_incidents
    ADD CONSTRAINT monitor_incidents_pkey PRIMARY KEY (id);


--
-- Name: que_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY que_jobs
    ADD CONSTRAINT que_jobs_pkey PRIMARY KEY (queue, priority, run_at, job_id);


--
-- Name: web_services_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY web_services
    ADD CONSTRAINT web_services_pkey PRIMARY KEY (id);


--
-- Name: index_monitor_events_on_monitor_incident_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_monitor_events_on_monitor_incident_id ON monitor_events USING btree (monitor_incident_id);


--
-- Name: index_monitor_incidents_on_web_service_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_monitor_incidents_on_web_service_id ON monitor_incidents USING btree (web_service_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: fk_rails_7a10c2cc3e; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY monitor_incidents
    ADD CONSTRAINT fk_rails_7a10c2cc3e FOREIGN KEY (web_service_id) REFERENCES web_services(id);


--
-- Name: fk_rails_ca67ea612a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY monitor_events
    ADD CONSTRAINT fk_rails_ca67ea612a FOREIGN KEY (monitor_incident_id) REFERENCES monitor_incidents(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20150313183143');

INSERT INTO schema_migrations (version) VALUES ('20150313183904');

INSERT INTO schema_migrations (version) VALUES ('20150313183947');

INSERT INTO schema_migrations (version) VALUES ('20150314023409');

INSERT INTO schema_migrations (version) VALUES ('20150315164502');

INSERT INTO schema_migrations (version) VALUES ('20150315205949');

INSERT INTO schema_migrations (version) VALUES ('20150315210808');


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
-- Name: incidents; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE incidents (
    id integer NOT NULL,
    pingometer_monitor_id integer,
    started_at timestamp without time zone,
    finished_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: incidents_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE incidents_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: incidents_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE incidents_id_seq OWNED BY incidents.id;


--
-- Name: pingometer_events; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE pingometer_events (
    id integer NOT NULL,
    incident_id integer,
    status character varying,
    triggered_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: pingometer_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE pingometer_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pingometer_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE pingometer_events_id_seq OWNED BY pingometer_events.id;


--
-- Name: pingometer_monitors; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE pingometer_monitors (
    id integer NOT NULL,
    pingometer_id character varying,
    hostname character varying,
    raw_data jsonb,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: pingometer_monitors_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE pingometer_monitors_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pingometer_monitors_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE pingometer_monitors_id_seq OWNED BY pingometer_monitors.id;


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
-- Name: screenshots; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE screenshots (
    id integer NOT NULL,
    pingometer_monitor_id integer,
    pingometer_event_id integer,
    image_id character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: screenshots_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE screenshots_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: screenshots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE screenshots_id_seq OWNED BY screenshots.id;


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY incidents ALTER COLUMN id SET DEFAULT nextval('incidents_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY pingometer_events ALTER COLUMN id SET DEFAULT nextval('pingometer_events_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY pingometer_monitors ALTER COLUMN id SET DEFAULT nextval('pingometer_monitors_id_seq'::regclass);


--
-- Name: job_id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY que_jobs ALTER COLUMN job_id SET DEFAULT nextval('que_jobs_job_id_seq'::regclass);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY screenshots ALTER COLUMN id SET DEFAULT nextval('screenshots_id_seq'::regclass);


--
-- Name: incidents_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY incidents
    ADD CONSTRAINT incidents_pkey PRIMARY KEY (id);


--
-- Name: pingometer_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pingometer_events
    ADD CONSTRAINT pingometer_events_pkey PRIMARY KEY (id);


--
-- Name: pingometer_monitors_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY pingometer_monitors
    ADD CONSTRAINT pingometer_monitors_pkey PRIMARY KEY (id);


--
-- Name: que_jobs_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY que_jobs
    ADD CONSTRAINT que_jobs_pkey PRIMARY KEY (queue, priority, run_at, job_id);


--
-- Name: screenshots_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY screenshots
    ADD CONSTRAINT screenshots_pkey PRIMARY KEY (id);


--
-- Name: index_incidents_on_pingometer_monitor_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_incidents_on_pingometer_monitor_id ON incidents USING btree (pingometer_monitor_id);


--
-- Name: index_pingometer_events_on_incident_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_pingometer_events_on_incident_id ON pingometer_events USING btree (incident_id);


--
-- Name: index_pingometer_monitors_on_hostname; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_pingometer_monitors_on_hostname ON pingometer_monitors USING btree (hostname);


--
-- Name: index_pingometer_monitors_on_pingometer_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_pingometer_monitors_on_pingometer_id ON pingometer_monitors USING btree (pingometer_id);


--
-- Name: index_screenshots_on_pingometer_event_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_screenshots_on_pingometer_event_id ON screenshots USING btree (pingometer_event_id);


--
-- Name: index_screenshots_on_pingometer_monitor_id; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE INDEX index_screenshots_on_pingometer_monitor_id ON screenshots USING btree (pingometer_monitor_id);


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- Name: fk_rails_1b2f0e27d7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY pingometer_events
    ADD CONSTRAINT fk_rails_1b2f0e27d7 FOREIGN KEY (incident_id) REFERENCES incidents(id);


--
-- Name: fk_rails_563166f18d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY incidents
    ADD CONSTRAINT fk_rails_563166f18d FOREIGN KEY (pingometer_monitor_id) REFERENCES pingometer_monitors(id);


--
-- Name: fk_rails_5fed216f41; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY screenshots
    ADD CONSTRAINT fk_rails_5fed216f41 FOREIGN KEY (pingometer_monitor_id) REFERENCES pingometer_monitors(id);


--
-- Name: fk_rails_6106f70d23; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY screenshots
    ADD CONSTRAINT fk_rails_6106f70d23 FOREIGN KEY (pingometer_event_id) REFERENCES pingometer_events(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20150313183143');

INSERT INTO schema_migrations (version) VALUES ('20150313183904');

INSERT INTO schema_migrations (version) VALUES ('20150313183947');

INSERT INTO schema_migrations (version) VALUES ('20150315164502');

INSERT INTO schema_migrations (version) VALUES ('20150317143922');


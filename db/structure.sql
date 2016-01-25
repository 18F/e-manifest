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


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


SET search_path = public, pg_catalog;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: manifests; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE manifests (
    id integer NOT NULL,
    content json,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    activity_id character varying,
    document_id character varying,
    uuid uuid DEFAULT uuid_generate_v4(),
    signed_at timestamp without time zone
);


--
-- Name: manifests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE manifests_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: manifests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE manifests_id_seq OWNED BY manifests.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -; Tablespace: 
--

CREATE TABLE schema_migrations (
    version character varying NOT NULL
);


--
-- Name: id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY manifests ALTER COLUMN id SET DEFAULT nextval('manifests_id_seq'::regclass);


--
-- Name: manifests_pkey; Type: CONSTRAINT; Schema: public; Owner: -; Tablespace: 
--

ALTER TABLE ONLY manifests
    ADD CONSTRAINT manifests_pkey PRIMARY KEY (id);


--
-- Name: index_manifests_on_uuid; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX index_manifests_on_uuid ON manifests USING btree (uuid);


--
-- Name: manifest_tracking_number_idx; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX manifest_tracking_number_idx ON manifests USING btree ((((content -> 'generator'::text) ->> 'manifest_tracking_number'::text)));


--
-- Name: unique_schema_migrations; Type: INDEX; Schema: public; Owner: -; Tablespace: 
--

CREATE UNIQUE INDEX unique_schema_migrations ON schema_migrations USING btree (version);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user",public;

INSERT INTO schema_migrations (version) VALUES ('20150909210014');

INSERT INTO schema_migrations (version) VALUES ('20150923210000');

INSERT INTO schema_migrations (version) VALUES ('20150924181500');

INSERT INTO schema_migrations (version) VALUES ('20160112190459');

INSERT INTO schema_migrations (version) VALUES ('20160115181255');

INSERT INTO schema_migrations (version) VALUES ('20160115203719');

INSERT INTO schema_migrations (version) VALUES ('20160115204128');

INSERT INTO schema_migrations (version) VALUES ('20160120171331');

INSERT INTO schema_migrations (version) VALUES ('20160125160835');


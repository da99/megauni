     rolname     | rolsuper | rolinherit | rolcreaterole | rolcreatedb | rolcanlogin | rolreplication | rolconnlimit | rolpassword | rolvaliduntil | rolbypassrls | rolconfig |  oid  
-----------------+----------+------------+---------------+-------------+-------------+----------------+--------------+-------------+---------------+--------------+-----------+-------
 production_user | f        | f          | f             | f           | t           | f              |           -1 | ********    |               | f            |           |
 web_app         | f        | f          | f             | f           | t           | f              |           -1 | ********    |               | f            |           |
(2 rows)

--
-- PostgreSQL database dump
--

-- Dumped from database version 9.6.8
-- Dumped by pg_dump version 9.6.8

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: plpgsql; Type: EXTENSION; Schema: -; Owner: 
--

CREATE EXTENSION IF NOT EXISTS plpgsql WITH SCHEMA pg_catalog;


--
-- Name: EXTENSION plpgsql; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION plpgsql IS 'PL/pgSQL procedural language';


--
-- Name: user_insert(character varying, character varying); Type: FUNCTION; Schema: public; Owner: production_user
--

CREATE FUNCTION public.user_insert(sn_name character varying, pswd_hash character varying, OUT id integer, OUT screen_name text) RETURNS record
    LANGUAGE plpgsql
    AS $$
  DECLARE
    sn_record RECORD;
  BEGIN
    IF pswd_hash IS NULL THEN
      RAISE EXCEPTION 'programmer_error: pswd_hash not set';
    END IF;

    IF length(pswd_hash) < 10 THEN
      RAISE EXCEPTION 'programmer_error: pswd_hash';
    END IF;

    SELECT *
    INTO sn_record
    FROM screen_name_insert(null, sn_name)
    ;

    INSERT INTO
    "user" ( id,                 pswd_hash )
    VALUES ( sn_record.owner_id, pswd_hash::BYTEA )
    ;

    id          := sn_record.owner_id;
    screen_name := sn_record.screen_name;
  END
$$;


ALTER FUNCTION public.user_insert(sn_name character varying, pswd_hash character varying, OUT id integer, OUT screen_name text) OWNER TO production_user;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: screen_name; Type: TABLE; Schema: public; Owner: production_user
--

CREATE TABLE public.screen_name (
    id bigint NOT NULL,
    owner_id bigint NOT NULL,
    privacy smallint NOT NULL,
    parent_id bigint DEFAULT 0 NOT NULL,
    screen_name character varying(30) NOT NULL,
    nick_name character varying(30),
    created_at timestamp without time zone,
    trashed_at timestamp without time zone
);


ALTER TABLE public.screen_name OWNER TO production_user;

--
-- Name: screen_name_id_seq; Type: SEQUENCE; Schema: public; Owner: production_user
--

CREATE SEQUENCE public.screen_name_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.screen_name_id_seq OWNER TO production_user;

--
-- Name: screen_name_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: production_user
--

ALTER SEQUENCE public.screen_name_id_seq OWNED BY public.screen_name.id;


--
-- Name: user; Type: TABLE; Schema: public; Owner: production_user
--

CREATE TABLE public."user" (
    id bigint NOT NULL,
    pswd_hash bytea NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public."user" OWNER TO production_user;

--
-- Name: user_id_seq; Type: SEQUENCE; Schema: public; Owner: production_user
--

CREATE SEQUENCE public.user_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.user_id_seq OWNER TO production_user;

--
-- Name: user_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: production_user
--

ALTER SEQUENCE public.user_id_seq OWNED BY public."user".id;


--
-- Name: screen_name id; Type: DEFAULT; Schema: public; Owner: production_user
--

ALTER TABLE ONLY public.screen_name ALTER COLUMN id SET DEFAULT nextval('public.screen_name_id_seq'::regclass);


--
-- Name: user id; Type: DEFAULT; Schema: public; Owner: production_user
--

ALTER TABLE ONLY public."user" ALTER COLUMN id SET DEFAULT nextval('public.user_id_seq'::regclass);


--
-- Name: screen_name screen_name_pkey; Type: CONSTRAINT; Schema: public; Owner: production_user
--

ALTER TABLE ONLY public.screen_name
    ADD CONSTRAINT screen_name_pkey PRIMARY KEY (id);


--
-- Name: screen_name screen_name_unique_idx; Type: CONSTRAINT; Schema: public; Owner: production_user
--

ALTER TABLE ONLY public.screen_name
    ADD CONSTRAINT screen_name_unique_idx UNIQUE (parent_id, screen_name);


--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: public; Owner: production_user
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--


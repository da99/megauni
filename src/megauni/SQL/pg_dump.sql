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
-- Name: clean_new_screen_name(character varying); Type: FUNCTION; Schema: public; Owner: production_user
--

CREATE FUNCTION public.clean_new_screen_name(INOUT sn character varying) RETURNS character varying
    LANGUAGE plpgsql IMMUTABLE
    AS $_$
  BEGIN
    sn := screen_name_canonical(sn);

    -- Banned screen names:
    IF sn ~* '(SCREEN[\_\.\-\+]+NAME|MEGAUNI|MINIUNI|OKDOKI|okjak|okjon|XXX)' OR
       sn ~* '^(BOT|ME|MINE|MY|MI|[.]+-COLA|UNDEFINED|DEF|SEX|SEXY|ALAN|TED|LARRY|ONLINE|CONTACT|INFO|OFFICIAL|ABOUT|NEWS|HOME)$'
    THEN
      RAISE EXCEPTION 'invalid screen_name: not_available';
    END IF;
  END
$_$;


ALTER FUNCTION public.clean_new_screen_name(INOUT sn character varying) OWNER TO production_user;

--
-- Name: screen_name_canonical(character varying); Type: FUNCTION; Schema: public; Owner: production_user
--

CREATE FUNCTION public.screen_name_canonical(INOUT sn character varying) RETURNS character varying
    LANGUAGE plpgsql IMMUTABLE
    AS $$
  DECLARE
    valid_chars VARCHAR;
  BEGIN
    -- screen_name
    IF sn IS NULL THEN
      RAISE EXCEPTION 'programmer_error: NULL value';
    END IF;
    sn := regexp_replace(upper(sn), '^\@|[\s[:cntrl:]]+', '', 'ig');

    IF char_length(sn) < 3 THEN
      RAISE EXCEPTION 'invalid screen_name: too short: 3';
    END IF;

    IF char_length(sn) > 30 THEN
      RAISE EXCEPTION 'invalid screen_name: too long: 30';
    END IF;

    valid_chars := 'A-Z\d\-\_\^';
    IF sn !~ ('\A[' || valid_chars || ']+\Z') THEN
      RAISE EXCEPTION 'invalid screen_name: invalid chars: %', regexp_replace(sn, ('[' || valid_chars || ']+'), '', 'ig');
    END IF;

  END
$$;


ALTER FUNCTION public.screen_name_canonical(INOUT sn character varying) OWNER TO production_user;

--
-- Name: screen_name_insert(bigint, character varying); Type: FUNCTION; Schema: public; Owner: production_user
--

CREATE FUNCTION public.screen_name_insert(owner_id bigint, raw_screen_name character varying, OUT new_screen_name character varying) RETURNS character varying
    LANGUAGE plpgsql
    AS $$
  DECLARE
    new_screen_name_record RECORD;
    clean_screen_name VARCHAR;

  BEGIN
    clean_screen_name := screen_name_canonical(raw_screen_name);
    INSERT INTO screen_name (owner_id, screen_name)
    VALUES (owner_id, clean_screen_name)
    RETURNING "screen_name".screen_name
    INTO new_screen_name;
  END
$$;


ALTER FUNCTION public.screen_name_insert(owner_id bigint, raw_screen_name character varying, OUT new_screen_name character varying) OWNER TO production_user;

--
-- Name: user_insert(character varying, character varying); Type: FUNCTION; Schema: public; Owner: production_user
--

CREATE FUNCTION public.user_insert(sn_name character varying, pswd_hash character varying, OUT new_user_id bigint, OUT new_screen_name text) RETURNS record
    LANGUAGE plpgsql
    AS $$
  DECLARE
    temp_rec RECORD;
  BEGIN
    IF pswd_hash IS NULL THEN
      RAISE EXCEPTION 'programmer_error: pswd_hash not set';
    END IF;

    IF length(pswd_hash) < 10 THEN
      RAISE EXCEPTION 'programmer_error: invalid pswd_hash';
    END IF;

    INSERT INTO
    "user" ( id, pswd_hash )
    VALUES ( DEFAULT, pswd_hash::BYTEA )
    RETURNING id INTO temp_rec;

    new_user_id := temp_rec.id;

    SELECT *
    INTO temp_rec
    FROM screen_name_insert(new_user_id, sn_name);

    new_screen_name := temp_rec.new_screen_name;
  END
$$;


ALTER FUNCTION public.user_insert(sn_name character varying, pswd_hash character varying, OUT new_user_id bigint, OUT new_screen_name text) OWNER TO production_user;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: screen_name; Type: TABLE; Schema: public; Owner: production_user
--

CREATE TABLE public.screen_name (
    id bigint NOT NULL,
    owner_id bigint NOT NULL,
    privacy smallint DEFAULT 0 NOT NULL,
    screen_name character varying(30) NOT NULL,
    nick_name character varying(30),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    trashed_at timestamp without time zone,
    CONSTRAINT screen_name_screen_name_check CHECK (((screen_name)::text = (public.clean_new_screen_name(screen_name))::text))
);


ALTER TABLE public.screen_name OWNER TO production_user;

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
-- Name: readable_screen_name; Type: VIEW; Schema: public; Owner: production_user
--

CREATE VIEW public.readable_screen_name AS
 SELECT screen_name.id,
    screen_name.owner_id,
    screen_name.privacy,
    screen_name.screen_name,
    screen_name.nick_name,
    screen_name.created_at,
    screen_name.trashed_at
   FROM (public.screen_name
     JOIN public."user" ON ((screen_name.owner_id = "user".id)));


ALTER TABLE public.readable_screen_name OWNER TO production_user;

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
-- Name: screen_name screen_name_screen_name_key; Type: CONSTRAINT; Schema: public; Owner: production_user
--

ALTER TABLE ONLY public.screen_name
    ADD CONSTRAINT screen_name_screen_name_key UNIQUE (screen_name);


--
-- Name: user user_pkey; Type: CONSTRAINT; Schema: public; Owner: production_user
--

ALTER TABLE ONLY public."user"
    ADD CONSTRAINT user_pkey PRIMARY KEY (id);


--
-- PostgreSQL database dump complete
--


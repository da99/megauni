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
-- Name: clean_new_label(character varying); Type: FUNCTION; Schema: public; Owner: production_user
--

CREATE FUNCTION public.clean_new_label(INOUT raw_label character varying) RETURNS character varying
    LANGUAGE plpgsql IMMUTABLE
    AS $_$
DECLARE
  valid_chars VARCHAR;
BEGIN

  IF raw_label IS NULL THEN
    RAISE EXCEPTION 'programmer_error: NULL VALUE';
  END IF;
  IF char_length(raw_label) < 1 THEN
    RAISE EXCEPTION 'invalid label: too short: 1';
  END IF;

  IF char_length(raw_label) > 30 THEN
    RAISE EXCEPTION 'invalid label: too long: 30';
  END IF;

  valid_chars := 'A-Za-z\d\-\_\^\%\$\@\*\!\~\+\=';
  IF raw_label !~ ('\A[' || valid_chars || ']+\Z') THEN
    RAISE EXCEPTION 'invalid label: invalid chars: %', regexp_replace(raw_label, ('[' || valid_chars || ']+'), '', 'ig');
  END IF;


END
$_$;


ALTER FUNCTION public.clean_new_label(INOUT raw_label character varying) OWNER TO production_user;

--
-- Name: clean_new_message_folder(character varying); Type: FUNCTION; Schema: public; Owner: production_user
--

CREATE FUNCTION public.clean_new_message_folder(INOUT raw_name character varying) RETURNS character varying
    LANGUAGE plpgsql IMMUTABLE
    AS $_$
DECLARE
valid_chars VARCHAR;
BEGIN
  IF raw_name IS NULL THEN
    RAISE EXCEPTION 'programmer_error: NULL VALUE';
  END IF;
  IF char_length(raw_name) < 1 THEN
    RAISE EXCEPTION 'invalid message folder: too short: 1';
  END IF;

  IF char_length(raw_name) > 30 THEN
    RAISE EXCEPTION 'invalid message folder: too long: 30';
  END IF;

  valid_chars := 'A-Za-z\d\-\_\^\%\$\@\*\!\~\+\=';
  IF raw_name !~ ('\A[' || valid_chars || ']+\Z') THEN
    RAISE EXCEPTION 'invalid message folder: invalid chars: %', regexp_replace(raw_name, ('[' || valid_chars || ']+'), '', 'ig');
  END IF;
END
$_$;


ALTER FUNCTION public.clean_new_message_folder(INOUT raw_name character varying) OWNER TO production_user;

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
-- Name: member_insert(character varying, character varying); Type: FUNCTION; Schema: public; Owner: production_user
--

CREATE FUNCTION public.member_insert(sn_name character varying, pswd_hash character varying, OUT new_member_id bigint, OUT new_screen_name text) RETURNS record
    LANGUAGE plpgsql
    AS $$
  DECLARE
    temp_rec RECORD;
  BEGIN
    IF pswd_hash IS NULL THEN
      RAISE EXCEPTION 'programmer_error: pswd_hash not set';
    END IF;

    IF length(pswd_hash) < 60 THEN
      RAISE EXCEPTION 'programmer_error: invalid pswd_hash';
    END IF;

    INSERT INTO
    "member" ( id, pswd_hash )
    VALUES ( DEFAULT, pswd_hash::BYTEA )
    RETURNING id INTO temp_rec;

    new_member_id := temp_rec.id;

    SELECT *
    INTO temp_rec
    FROM screen_name_insert(new_member_id, sn_name);

    new_screen_name := temp_rec.new_screen_name;
  END
$$;


ALTER FUNCTION public.member_insert(sn_name character varying, pswd_hash character varying, OUT new_member_id bigint, OUT new_screen_name text) OWNER TO production_user;

--
-- Name: privacy_id(character varying); Type: FUNCTION; Schema: public; Owner: production_user
--

CREATE FUNCTION public.privacy_id(raw_name character varying) RETURNS smallint
    LANGUAGE plpgsql IMMUTABLE
    AS $$
BEGIN
  CASE raw_name
  WHEN 'ME ONLY'       THEN RETURN 0;   -- Only the owner can read it.
  WHEN 'LIST'          THEN RETURN 1;   -- Only selected people.
  WHEN 'WORLD'         THEN RETURN 100; -- Readable by world

  /*
    Specification:
    An object can be viewed by 'LIST'. This means:
      - list(s) of people. These lists/groups/circles are made before or after
        object is created.
      - specific people just for this object.
  */

  ELSE
    RAISE EXCEPTION 'programmer_error: name for privacy_id not found: %', raw_name;
  END CASE;
END
$$;


ALTER FUNCTION public.privacy_id(raw_name character varying) OWNER TO production_user;

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
    INSERT INTO screen_name (owner_id, owner_type_id, screen_name)
    VALUES (owner_id, type_id('Member'), clean_screen_name)
    RETURNING "screen_name".screen_name
    INTO new_screen_name;
  END
$$;


ALTER FUNCTION public.screen_name_insert(owner_id bigint, raw_screen_name character varying, OUT new_screen_name character varying) OWNER TO production_user;

--
-- Name: type_id(character varying); Type: FUNCTION; Schema: public; Owner: production_user
--

CREATE FUNCTION public.type_id(raw_name character varying) RETURNS smallint
    LANGUAGE plpgsql IMMUTABLE
    AS $$
BEGIN
  CASE raw_name
  WHEN 'Member'      THEN RETURN 1;
  WHEN 'Screen_Name' THEN RETURN 2;
  WHEN 'Follow'      THEN RETURN 3;
  WHEN 'Contact'     THEN RETURN 4;
  WHEN 'Message'     THEN RETURN 5;

  WHEN 'Draft'       THEN RETURN 11;
  WHEN 'Publish'     THEN RETURN 12;

  ELSE
    RAISE EXCEPTION 'programmer_error: name for type_id not found: %', raw_name;
  END CASE;
END
$$;


ALTER FUNCTION public.type_id(raw_name character varying) OWNER TO production_user;

SET default_tablespace = '';

SET default_with_oids = false;

--
-- Name: label; Type: TABLE; Schema: public; Owner: production_user
--

CREATE TABLE public.label (
    id bigint NOT NULL,
    name character varying(30) NOT NULL,
    CONSTRAINT label_name_check CHECK (((name)::text = (public.clean_new_label(name))::text))
);


ALTER TABLE public.label OWNER TO production_user;

--
-- Name: label_id_seq; Type: SEQUENCE; Schema: public; Owner: production_user
--

CREATE SEQUENCE public.label_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.label_id_seq OWNER TO production_user;

--
-- Name: label_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: production_user
--

ALTER SEQUENCE public.label_id_seq OWNED BY public.label.id;


--
-- Name: megauni_tables; Type: VIEW; Schema: public; Owner: production_user
--

CREATE VIEW public.megauni_tables AS
 SELECT tables.table_name
   FROM information_schema.tables
  WHERE (((tables.table_catalog)::text = 'megauni_db'::text) AND ((tables.table_schema)::text = 'public'::text) AND ((tables.table_type)::text = 'BASE TABLE'::text))
  ORDER BY tables.table_name;


ALTER TABLE public.megauni_tables OWNER TO production_user;

--
-- Name: member; Type: TABLE; Schema: public; Owner: production_user
--

CREATE TABLE public.member (
    id bigint NOT NULL,
    pswd_hash bytea NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.member OWNER TO production_user;

--
-- Name: member_block; Type: TABLE; Schema: public; Owner: production_user
--

CREATE TABLE public.member_block (
    id bigint NOT NULL,
    screen_name_id bigint NOT NULL,
    member_id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.member_block OWNER TO production_user;

--
-- Name: member_block_id_seq; Type: SEQUENCE; Schema: public; Owner: production_user
--

CREATE SEQUENCE public.member_block_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.member_block_id_seq OWNER TO production_user;

--
-- Name: member_block_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: production_user
--

ALTER SEQUENCE public.member_block_id_seq OWNED BY public.member_block.id;


--
-- Name: member_id_seq; Type: SEQUENCE; Schema: public; Owner: production_user
--

CREATE SEQUENCE public.member_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.member_id_seq OWNER TO production_user;

--
-- Name: member_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: production_user
--

ALTER SEQUENCE public.member_id_seq OWNED BY public.member.id;


--
-- Name: message; Type: TABLE; Schema: public; Owner: production_user
--

CREATE TABLE public.message (
    id bigint NOT NULL,
    status_id smallint DEFAULT public.type_id('Draft'::character varying) NOT NULL,
    owner_id bigint NOT NULL,
    parent_id bigint NOT NULL,
    parent_type_id smallint NOT NULL,
    origin_id bigint NOT NULL,
    origin_type_id smallint NOT NULL,
    title character varying(140),
    body text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT title_or_body CHECK (((title IS NOT NULL) OR (body IS NOT NULL)))
);


ALTER TABLE public.message OWNER TO production_user;

--
-- Name: message_folder; Type: TABLE; Schema: public; Owner: production_user
--

CREATE TABLE public.message_folder (
    id bigint NOT NULL,
    owner_id bigint NOT NULL,
    owner_type_id smallint NOT NULL,
    name character varying(30) NOT NULL,
    display_name character varying(30) NOT NULL,
    CONSTRAINT message_folder_check CHECK ((((name)::text = (public.clean_new_message_folder(name))::text) AND (upper((display_name)::text) = (name)::text))),
    CONSTRAINT message_folder_name_check CHECK (((name)::text = (public.clean_new_message_folder((upper((name)::text))::character varying))::text))
);


ALTER TABLE public.message_folder OWNER TO production_user;

--
-- Name: message_folder_id_seq; Type: SEQUENCE; Schema: public; Owner: production_user
--

CREATE SEQUENCE public.message_folder_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.message_folder_id_seq OWNER TO production_user;

--
-- Name: message_folder_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: production_user
--

ALTER SEQUENCE public.message_folder_id_seq OWNED BY public.message_folder.id;


--
-- Name: message_id_seq; Type: SEQUENCE; Schema: public; Owner: production_user
--

CREATE SEQUENCE public.message_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.message_id_seq OWNER TO production_user;

--
-- Name: message_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: production_user
--

ALTER SEQUENCE public.message_id_seq OWNED BY public.message.id;


--
-- Name: screen_name; Type: TABLE; Schema: public; Owner: production_user
--

CREATE TABLE public.screen_name (
    id bigint NOT NULL,
    owner_id bigint NOT NULL,
    owner_type_id smallint NOT NULL,
    privacy smallint DEFAULT public.privacy_id('ME ONLY'::character varying) NOT NULL,
    screen_name character varying(30) NOT NULL,
    nick_name character varying(30),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    trashed_at timestamp without time zone,
    CONSTRAINT screen_name_screen_name_check CHECK (((screen_name)::text = (public.clean_new_screen_name(screen_name))::text))
);


ALTER TABLE public.screen_name OWNER TO production_user;

--
-- Name: readable_screen_name; Type: VIEW; Schema: public; Owner: production_user
--

CREATE VIEW public.readable_screen_name AS
 SELECT screen_name.id,
    screen_name.owner_id,
    screen_name.owner_type_id,
    screen_name.privacy,
    screen_name.screen_name,
    screen_name.nick_name,
    screen_name.created_at,
    screen_name.trashed_at
   FROM (public.screen_name
     JOIN public.member ON ((screen_name.owner_id = member.id)));


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
-- Name: label id; Type: DEFAULT; Schema: public; Owner: production_user
--

ALTER TABLE ONLY public.label ALTER COLUMN id SET DEFAULT nextval('public.label_id_seq'::regclass);


--
-- Name: member id; Type: DEFAULT; Schema: public; Owner: production_user
--

ALTER TABLE ONLY public.member ALTER COLUMN id SET DEFAULT nextval('public.member_id_seq'::regclass);


--
-- Name: member_block id; Type: DEFAULT; Schema: public; Owner: production_user
--

ALTER TABLE ONLY public.member_block ALTER COLUMN id SET DEFAULT nextval('public.member_block_id_seq'::regclass);


--
-- Name: message id; Type: DEFAULT; Schema: public; Owner: production_user
--

ALTER TABLE ONLY public.message ALTER COLUMN id SET DEFAULT nextval('public.message_id_seq'::regclass);


--
-- Name: message_folder id; Type: DEFAULT; Schema: public; Owner: production_user
--

ALTER TABLE ONLY public.message_folder ALTER COLUMN id SET DEFAULT nextval('public.message_folder_id_seq'::regclass);


--
-- Name: screen_name id; Type: DEFAULT; Schema: public; Owner: production_user
--

ALTER TABLE ONLY public.screen_name ALTER COLUMN id SET DEFAULT nextval('public.screen_name_id_seq'::regclass);


--
-- Name: label label_name_key; Type: CONSTRAINT; Schema: public; Owner: production_user
--

ALTER TABLE ONLY public.label
    ADD CONSTRAINT label_name_key UNIQUE (name);


--
-- Name: label label_pkey; Type: CONSTRAINT; Schema: public; Owner: production_user
--

ALTER TABLE ONLY public.label
    ADD CONSTRAINT label_pkey PRIMARY KEY (id);


--
-- Name: member_block member_block_pkey; Type: CONSTRAINT; Schema: public; Owner: production_user
--

ALTER TABLE ONLY public.member_block
    ADD CONSTRAINT member_block_pkey PRIMARY KEY (id);


--
-- Name: member member_pkey; Type: CONSTRAINT; Schema: public; Owner: production_user
--

ALTER TABLE ONLY public.member
    ADD CONSTRAINT member_pkey PRIMARY KEY (id);


--
-- Name: message_folder message_folder_owner_id_owner_type_id_name_key; Type: CONSTRAINT; Schema: public; Owner: production_user
--

ALTER TABLE ONLY public.message_folder
    ADD CONSTRAINT message_folder_owner_id_owner_type_id_name_key UNIQUE (owner_id, owner_type_id, name);


--
-- Name: message_folder message_folder_pkey; Type: CONSTRAINT; Schema: public; Owner: production_user
--

ALTER TABLE ONLY public.message_folder
    ADD CONSTRAINT message_folder_pkey PRIMARY KEY (id);


--
-- Name: message message_pkey; Type: CONSTRAINT; Schema: public; Owner: production_user
--

ALTER TABLE ONLY public.message
    ADD CONSTRAINT message_pkey PRIMARY KEY (id);


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
-- PostgreSQL database dump complete
--


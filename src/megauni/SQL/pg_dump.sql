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

CREATE FUNCTION public.clean_new_label(raw_label character varying) RETURNS character varying
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

  RETURN raw_label;

END
$_$;


ALTER FUNCTION public.clean_new_label(raw_label character varying) OWNER TO production_user;

--
-- Name: clean_new_screen_name(character varying); Type: FUNCTION; Schema: public; Owner: production_user
--

CREATE FUNCTION public.clean_new_screen_name(raw_name character varying) RETURNS character varying
    LANGUAGE plpgsql IMMUTABLE
    AS $_$
  DECLARE
    sn VARCHAR;
  BEGIN
    sn := screen_name_canonical(raw_name);

    -- Banned screen names:
    IF sn ~* '(SCREEN[\_\.\-\+]+NAME|MEGAUNI|MINIUNI|OKDOKI|okjak|okjon|XXX)' OR
       sn ~* '^(BOT|ME|MINE|MY|MI|[.]+-COLA|UNDEFINED|DEF|SEX|SEXY|ALAN|TED|LARRY|ONLINE|CONTACT|INFO|OFFICIAL|ABOUT|NEWS|HOME)$'
    THEN
      RAISE EXCEPTION 'invalid screen_name: not_available';
    END IF;

    RETURN sn;
  END
$_$;


ALTER FUNCTION public.clean_new_screen_name(raw_name character varying) OWNER TO production_user;

--
-- Name: member_insert(character varying, character varying); Type: FUNCTION; Schema: public; Owner: production_user
--

CREATE FUNCTION public.member_insert(sn_name character varying, pswd_hash character varying) RETURNS TABLE(id bigint, screen_name_id bigint, screen_name character varying)
    LANGUAGE plpgsql
    AS $$
  DECLARE
    new_member RECORD;
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
    RETURNING * INTO new_member;

    RETURN QUERY
    SELECT
    new_member.id    AS id,
    sn_i.id          AS screen_name_id,
    sn_i.screen_name AS screen_name
    FROM screen_name_insert(new_member.id, sn_name) AS sn_i;
  END
$$;


ALTER FUNCTION public.member_insert(sn_name character varying, pswd_hash character varying) OWNER TO production_user;

--
-- Name: message_folder(bigint, character varying, character varying); Type: FUNCTION; Schema: public; Owner: production_user
--

CREATE FUNCTION public.message_folder(raw_viewer_id bigint, raw_owner_name character varying, raw_name character varying) RETURNS TABLE(id bigint, name character varying, display_name character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
  canonical_name VARCHAR;
  owner          RECORD;
BEGIN
  canonical_name := message_folder_canonical(raw_name);
  owner          := screen_name(raw_viewer_id, raw_owner_name);

  RETURN QUERY
  SELECT mf.id, mf.name, mf.display_name
  FROM message_folder mf
  WHERE mf.owner_id = owner.id AND mf.name = canonical_name;

  IF NOT FOUND THEN
    RAISE EXCEPTION 'not found: message folder: %', raw_name;
  END IF;
END
$$;


ALTER FUNCTION public.message_folder(raw_viewer_id bigint, raw_owner_name character varying, raw_name character varying) OWNER TO production_user;

--
-- Name: message_folder_canonical(character varying); Type: FUNCTION; Schema: public; Owner: production_user
--

CREATE FUNCTION public.message_folder_canonical(raw_name character varying) RETURNS character varying
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
  original      CONSTANT VARCHAR NOT NULL := raw_name;
  invalid_chars VARCHAR;
  pattern       CONSTANT VARCHAR  NOT NULL := '[a-zA-Z0-9\_\-\.\ \@\!\#\%\^\&\+\~]+';
  min_length    CONSTANT SMALLINT NOT NULL := 1;
  max_length    CONSTANT SMALLINT NOT NULL := 30;
BEGIN

  IF raw_name IS NULL THEN
    RAISE EXCEPTION 'programmer_error: NULL VALUE';
  END IF;

  raw_name := squeeze_whitespace(upper(raw_name));

  IF char_length(raw_name) < min_length THEN
    RAISE EXCEPTION 'invalid message folder: too short: %', min_length;
  END IF;

  IF char_length(raw_name) > max_length THEN
    RAISE EXCEPTION 'invalid message folder: too long: %', max_length;
  END IF;

  invalid_chars := regexp_replace(raw_name, pattern, '', 'g');
  IF bit_length(invalid_chars) > 0 THEN
    RAISE EXCEPTION 'invalid message folder: invalid chars: %', invalid_chars;
  END IF;

  RETURN raw_name;
END
$$;


ALTER FUNCTION public.message_folder_canonical(raw_name character varying) OWNER TO production_user;

--
-- Name: message_folder_insert(bigint, character varying); Type: FUNCTION; Schema: public; Owner: production_user
--

CREATE FUNCTION public.message_folder_insert(raw_owner_id bigint, raw_name character varying) RETURNS TABLE(id bigint, name character varying, display_name character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE
  canonical_name VARCHAR;
BEGIN

  canonical_name := message_folder_canonical(raw_name);

  RETURN QUERY
  SELECT mf.id, mf.name, mf.display_name
  FROM message_folder AS mf
  WHERE mf.owner_id = raw_owner_id AND mf.name = canonical_name;

  IF NOT FOUND THEN
    RETURN QUERY
    INSERT INTO
    "message_folder" AS mf ( "id", "owner_id", "name", "display_name" )
    VALUES (DEFAULT, raw_owner_id, UPPER(canonical_name), canonical_name)
    RETURNING mf.id, mf.name, mf.display_name;
  END IF;

END
$$;


ALTER FUNCTION public.message_folder_insert(raw_owner_id bigint, raw_name character varying) OWNER TO production_user;

--
-- Name: message_receive_command_insert(bigint, character varying, character varying, character varying); Type: FUNCTION; Schema: public; Owner: production_user
--

CREATE FUNCTION public.message_receive_command_insert(owner_id bigint, raw_sender character varying, raw_folder_source character varying, raw_folder_dest character varying) RETURNS TABLE(id bigint, source_folder_id bigint, dest_folder_id bigint)
    LANGUAGE plpgsql
    AS $$
DECLARE
  sender        RECORD;
  source_folder RECORD;
  dest_folder   RECORD;
BEGIN
  sender        := screen_name(owner_id, raw_sender);
  source_folder := message_folder(owner_id, sender.screen_name, raw_folder_source);
  dest_folder   := message_folder_insert(owner_id, raw_folder_dest);

  RETURN QUERY
  INSERT INTO
  message_receive_command AS mrc ("id", "owner_id", "sender_id", "source_folder_id", "dest_folder_id")
  VALUES (DEFAULT, owner_id, sender.id, source_folder.id, dest_folder.id)
  RETURNING mrc.id, mrc.source_folder_id, mrc.dest_folder_id;
END
$$;


ALTER FUNCTION public.message_receive_command_insert(owner_id bigint, raw_sender character varying, raw_folder_source character varying, raw_folder_dest character varying) OWNER TO production_user;

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
-- Name: screen_name(bigint, character varying); Type: FUNCTION; Schema: public; Owner: production_user
--

CREATE FUNCTION public.screen_name(raw_view_id bigint, raw_screen_name character varying) RETURNS TABLE(id bigint, screen_name character varying)
    LANGUAGE plpgsql
    AS $$
DECLARE

BEGIN
  RETURN QUERY
  SELECT sn.id AS id, sn.screen_name AS screen_name
  FROM screen_name sn
  WHERE sn.screen_name = screen_name_canonical(raw_screen_name);
END
$$;


ALTER FUNCTION public.screen_name(raw_view_id bigint, raw_screen_name character varying) OWNER TO production_user;

--
-- Name: screen_name_canonical(character varying); Type: FUNCTION; Schema: public; Owner: production_user
--

CREATE FUNCTION public.screen_name_canonical(raw_name character varying) RETURNS character varying
    LANGUAGE plpgsql IMMUTABLE
    AS $$
  DECLARE
    sn VARCHAR;
    valid_pattern CONSTANT VARCHAR NOT NULL:= '[A-Z\d\-\_\^]+';
    invalid_chars VARCHAR;
    min_length    CONSTANT SMALLINT NOT NULL := 3;
    max_length    CONSTANT SMALLINT NOT NULL := 30;
  BEGIN

    IF raw_name IS NULL THEN
      RAISE EXCEPTION 'programmer_error: NULL value';
    END IF;

    sn := regexp_replace(upper(raw_name), '^\@|[\s[:cntrl:]]+', '', 'ig');

    IF char_length(sn) < min_length THEN
      RAISE EXCEPTION 'invalid screen_name: too short: %', min_length;
    END IF;

    IF char_length(sn) > max_length THEN
      RAISE EXCEPTION 'invalid screen_name: too long: %', max_length;
    END IF;

    invalid_chars := regexp_replace(sn, valid_pattern, '', 'g');
    IF bit_length(invalid_chars) > 0 THEN
      RAISE EXCEPTION 'invalid screen_name: invalid chars: %', invalid_chars;
    END IF;

    RETURN sn;

  END
$$;


ALTER FUNCTION public.screen_name_canonical(raw_name character varying) OWNER TO production_user;

--
-- Name: screen_name_insert(bigint, character varying); Type: FUNCTION; Schema: public; Owner: production_user
--

CREATE FUNCTION public.screen_name_insert(owner_id bigint, raw_screen_name character varying) RETURNS TABLE(id bigint, screen_name character varying)
    LANGUAGE plpgsql
    AS $$
  DECLARE
    new_screen_name_record RECORD;
    clean_screen_name VARCHAR;

  BEGIN
    clean_screen_name := screen_name_canonical(raw_screen_name);

    RETURN QUERY
    INSERT INTO
    screen_name (owner_id, owner_type_id, screen_name)
    VALUES (owner_id, type_id('Member'), clean_screen_name)
    RETURNING "screen_name".id, "screen_name".screen_name;
  END
$$;


ALTER FUNCTION public.screen_name_insert(owner_id bigint, raw_screen_name character varying) OWNER TO production_user;

--
-- Name: squeeze_whitespace(character varying); Type: FUNCTION; Schema: public; Owner: production_user
--

CREATE FUNCTION public.squeeze_whitespace(raw_string character varying) RETURNS character varying
    LANGUAGE plpgsql IMMUTABLE
    AS $$
DECLARE
  fin_string VARCHAR;
BEGIN
  fin_string := regexp_replace(trim(from raw_string), '\s+', ' ', 'g');
  RETURN fin_string;
END
$$;


ALTER FUNCTION public.squeeze_whitespace(raw_string character varying) OWNER TO production_user;

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
    name character varying(30) NOT NULL,
    display_name character varying(30) NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT message_folder_check CHECK ((((name)::text = (public.message_folder_canonical(name))::text) AND (upper((display_name)::text) = (name)::text))),
    CONSTRAINT message_folder_name_check CHECK (((name)::text = (public.message_folder_canonical((upper((name)::text))::character varying))::text))
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
-- Name: message_receive_command; Type: TABLE; Schema: public; Owner: production_user
--

CREATE TABLE public.message_receive_command (
    id bigint NOT NULL,
    owner_id bigint NOT NULL,
    sender_id bigint NOT NULL,
    source_folder_id bigint NOT NULL,
    dest_folder_id bigint NOT NULL
);


ALTER TABLE public.message_receive_command OWNER TO production_user;

--
-- Name: message_receive_command_id_seq; Type: SEQUENCE; Schema: public; Owner: production_user
--

CREATE SEQUENCE public.message_receive_command_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.message_receive_command_id_seq OWNER TO production_user;

--
-- Name: message_receive_command_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: production_user
--

ALTER SEQUENCE public.message_receive_command_id_seq OWNED BY public.message_receive_command.id;


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
-- Name: message_receive_command id; Type: DEFAULT; Schema: public; Owner: production_user
--

ALTER TABLE ONLY public.message_receive_command ALTER COLUMN id SET DEFAULT nextval('public.message_receive_command_id_seq'::regclass);


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
-- Name: message_folder message_folder_owner_id_name_key; Type: CONSTRAINT; Schema: public; Owner: production_user
--

ALTER TABLE ONLY public.message_folder
    ADD CONSTRAINT message_folder_owner_id_name_key UNIQUE (owner_id, name);


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
-- Name: message_receive_command message_receive_command_owner_id_sender_id_source_folder_id_key; Type: CONSTRAINT; Schema: public; Owner: production_user
--

ALTER TABLE ONLY public.message_receive_command
    ADD CONSTRAINT message_receive_command_owner_id_sender_id_source_folder_id_key UNIQUE (owner_id, sender_id, source_folder_id);


--
-- Name: message_receive_command message_receive_command_pkey; Type: CONSTRAINT; Schema: public; Owner: production_user
--

ALTER TABLE ONLY public.message_receive_command
    ADD CONSTRAINT message_receive_command_pkey PRIMARY KEY (id);


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


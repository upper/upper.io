--
-- PostgreSQL database dump
--

-- Dumped from database version 13.5 (Debian 13.5-1.pgdg110+1)
-- Dumped by pg_dump version 13.5 (Ubuntu 13.5-1.pgdg18.04+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE booktown;
--
-- Name: booktown; Type: DATABASE; Schema: -; Owner: demouser
--

ALTER DATABASE booktown OWNER TO demouser;

\connect booktown

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: DATABASE booktown; Type: COMMENT; Schema: -; Owner: demouser
--

COMMENT ON DATABASE booktown IS 'The Book Town Database.';

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alternate_stock; Type: TABLE; Schema: public; Owner: demouser
--

CREATE TABLE public.alternate_stock (
    isbn text,
    cost numeric(5,2),
    retail numeric(5,2),
    stock integer
);


ALTER TABLE public.alternate_stock OWNER TO demouser;

--
-- Name: author_ids; Type: SEQUENCE; Schema: public; Owner: demouser
--

CREATE SEQUENCE public.author_ids
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.author_ids OWNER TO demouser;

--
-- Name: authors; Type: TABLE; Schema: public; Owner: demouser
--

CREATE TABLE public.authors (
    id integer NOT NULL,
    last_name text,
    first_name text
);


ALTER TABLE public.authors OWNER TO demouser;

--
-- Name: book_backup; Type: TABLE; Schema: public; Owner: demouser
--

CREATE TABLE public.book_backup (
    id integer,
    title text,
    author_id integer,
    subject_id integer
);


ALTER TABLE public.book_backup OWNER TO demouser;

--
-- Name: book_ids; Type: SEQUENCE; Schema: public; Owner: demouser
--

CREATE SEQUENCE public.book_ids
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.book_ids OWNER TO demouser;

--
-- Name: book_queue; Type: TABLE; Schema: public; Owner: demouser
--

CREATE TABLE public.book_queue (
    title text NOT NULL,
    author_id integer,
    subject_id integer,
    approved boolean
);


ALTER TABLE public.book_queue OWNER TO demouser;

--
-- Name: books; Type: TABLE; Schema: public; Owner: demouser
--

CREATE TABLE public.books (
    id integer NOT NULL,
    title text NOT NULL,
    author_id integer,
    subject_id integer
);


ALTER TABLE public.books OWNER TO demouser;

--
-- Name: customers; Type: TABLE; Schema: public; Owner: demouser
--

CREATE TABLE public.customers (
    id integer NOT NULL,
    last_name text,
    first_name text
);


ALTER TABLE public.customers OWNER TO demouser;

--
-- Name: daily_inventory; Type: TABLE; Schema: public; Owner: demouser
--

CREATE TABLE public.daily_inventory (
    isbn text,
    is_stocked boolean
);


ALTER TABLE public.daily_inventory OWNER TO demouser;


--
-- Name: editions; Type: TABLE; Schema: public; Owner: demouser
--

CREATE TABLE public.editions (
    isbn text NOT NULL,
    book_id integer,
    edition integer,
    publisher_id integer,
    publication date,
    type character(1),
    CONSTRAINT integrity CHECK (((book_id IS NOT NULL) AND (edition IS NOT NULL)))
);


ALTER TABLE public.editions OWNER TO demouser;

--
-- Name: employees; Type: TABLE; Schema: public; Owner: demouser
--

CREATE TABLE public.employees (
    id integer NOT NULL,
    last_name text NOT NULL,
    first_name text,
    CONSTRAINT employees_id CHECK ((id > 100))
);


ALTER TABLE public.employees OWNER TO demouser;

--
-- Name: favorite_authors; Type: TABLE; Schema: public; Owner: demouser
--

CREATE TABLE public.favorite_authors (
    employee_id integer,
    authors_and_titles text[]
);


ALTER TABLE public.favorite_authors OWNER TO demouser;

--
-- Name: favorite_books; Type: TABLE; Schema: public; Owner: demouser
--

CREATE TABLE public.favorite_books (
    employee_id integer,
    books text[]
);


ALTER TABLE public.favorite_books OWNER TO demouser;

--
-- Name: my_list; Type: TABLE; Schema: public; Owner: demouser
--

CREATE TABLE public.my_list (
    todos text
);


ALTER TABLE public.my_list OWNER TO demouser;

--
-- Name: numeric_values; Type: TABLE; Schema: public; Owner: demouser
--

CREATE TABLE public.numeric_values (
    num numeric(30,6)
);


ALTER TABLE public.numeric_values OWNER TO demouser;

--
-- Name: publishers; Type: TABLE; Schema: public; Owner: demouser
--

CREATE TABLE public.publishers (
    id integer NOT NULL,
    name text,
    address text
);


ALTER TABLE public.publishers OWNER TO demouser;

--
-- Name: shipments; Type: TABLE; Schema: public; Owner: demouser
--

CREATE TABLE public.shipments (
    id integer DEFAULT nextval(('"shipments_ship_id_seq"'::text)::regclass) NOT NULL,
    customer_id integer,
    isbn text,
    ship_date timestamp with time zone
);


ALTER TABLE public.shipments OWNER TO demouser;

--
-- Name: recent_shipments; Type: VIEW; Schema: public; Owner: demouser
--

CREATE VIEW public.recent_shipments AS
 SELECT count(*) AS num_shipped,
    max(shipments.ship_date) AS max,
    b.title
   FROM ((public.shipments
     JOIN public.editions USING (isbn))
     JOIN public.books b(book_id, title, author_id, subject_id) USING (book_id))
  GROUP BY b.title
  ORDER BY (count(*)) DESC;


ALTER TABLE public.recent_shipments OWNER TO demouser;

--
-- Name: schedules; Type: TABLE; Schema: public; Owner: demouser
--

CREATE TABLE public.schedules (
    employee_id integer NOT NULL,
    schedule text
);


ALTER TABLE public.schedules OWNER TO demouser;

--
-- Name: shipments_ship_id_seq; Type: SEQUENCE; Schema: public; Owner: demouser
--

CREATE SEQUENCE public.shipments_ship_id_seq
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.shipments_ship_id_seq OWNER TO demouser;

--
-- Name: states; Type: TABLE; Schema: public; Owner: demouser
--

CREATE TABLE public.states (
    id integer NOT NULL,
    name text,
    abbreviation character(2)
);


ALTER TABLE public.states OWNER TO demouser;

--
-- Name: stock; Type: TABLE; Schema: public; Owner: demouser
--

CREATE TABLE public.stock (
    isbn text NOT NULL,
    cost numeric(5,2),
    retail numeric(5,2),
    stock integer
);


ALTER TABLE public.stock OWNER TO demouser;

--
-- Name: stock_backup; Type: TABLE; Schema: public; Owner: demouser
--

CREATE TABLE public.stock_backup (
    isbn text,
    cost numeric(5,2),
    retail numeric(5,2),
    stock integer
);


ALTER TABLE public.stock_backup OWNER TO demouser;

--
-- Name: stock_view; Type: VIEW; Schema: public; Owner: demouser
--

CREATE VIEW public.stock_view AS
 SELECT stock.isbn,
    stock.retail,
    stock.stock
   FROM public.stock;


ALTER TABLE public.stock_view OWNER TO demouser;

--
-- Name: subject_ids; Type: SEQUENCE; Schema: public; Owner: demouser
--

CREATE SEQUENCE public.subject_ids
    START WITH 0
    INCREMENT BY 1
    MINVALUE 0
    MAXVALUE 2147483647
    CACHE 1;


ALTER TABLE public.subject_ids OWNER TO demouser;

--
-- Name: subjects; Type: TABLE; Schema: public; Owner: demouser
--

CREATE TABLE public.subjects (
    id integer NOT NULL,
    subject text,
    location text
);


ALTER TABLE public.subjects OWNER TO demouser;

--
-- Name: text_sorting; Type: TABLE; Schema: public; Owner: demouser
--

CREATE TABLE public.text_sorting (
    letter character(1)
);


ALTER TABLE public.text_sorting OWNER TO demouser;

--
-- Data for Name: alternate_stock; Type: TABLE DATA; Schema: public; Owner: demouser
--

INSERT INTO public.alternate_stock VALUES ('0385121679', 29.00, 36.95, 65);
INSERT INTO public.alternate_stock VALUES ('039480001X', 30.00, 32.95, 31);
INSERT INTO public.alternate_stock VALUES ('0394900014', 23.00, 23.95, 0);
INSERT INTO public.alternate_stock VALUES ('044100590X', 36.00, 45.95, 89);
INSERT INTO public.alternate_stock VALUES ('0441172717', 17.00, 21.95, 77);
INSERT INTO public.alternate_stock VALUES ('0451160916', 24.00, 28.95, 22);
INSERT INTO public.alternate_stock VALUES ('0451198492', 36.00, 46.95, 0);
INSERT INTO public.alternate_stock VALUES ('0451457994', 17.00, 22.95, 0);
INSERT INTO public.alternate_stock VALUES ('0590445065', 23.00, 23.95, 10);
INSERT INTO public.alternate_stock VALUES ('0679803335', 20.00, 24.95, 18);
INSERT INTO public.alternate_stock VALUES ('0694003611', 25.00, 28.95, 50);
INSERT INTO public.alternate_stock VALUES ('0760720002', 18.00, 23.95, 28);
INSERT INTO public.alternate_stock VALUES ('0823015505', 26.00, 28.95, 16);
INSERT INTO public.alternate_stock VALUES ('0929605942', 19.00, 21.95, 25);
INSERT INTO public.alternate_stock VALUES ('1885418035', 23.00, 24.95, 77);
INSERT INTO public.alternate_stock VALUES ('0394800753', 16.00, 16.95, 4);


--
-- Data for Name: authors; Type: TABLE DATA; Schema: public; Owner: demouser
--

INSERT INTO public.authors VALUES (1111, 'Denham', 'Ariel');
INSERT INTO public.authors VALUES (1212, 'Worsley', 'John');
INSERT INTO public.authors VALUES (15990, 'Bourgeois', 'Paulette');
INSERT INTO public.authors VALUES (25041, 'Bianco', 'Margery Williams');
INSERT INTO public.authors VALUES (16, 'Alcott', 'Louisa May');
INSERT INTO public.authors VALUES (4156, 'King', 'Stephen');
INSERT INTO public.authors VALUES (1866, 'Herbert', 'Frank');
INSERT INTO public.authors VALUES (1644, 'Hogarth', 'Burne');
INSERT INTO public.authors VALUES (2031, 'Brown', 'Margaret Wise');
INSERT INTO public.authors VALUES (115, 'Poe', 'Edgar Allen');
INSERT INTO public.authors VALUES (7805, 'Lutz', 'Mark');
INSERT INTO public.authors VALUES (7806, 'Christiansen', 'Tom');
INSERT INTO public.authors VALUES (1533, 'Brautigan', 'Richard');
INSERT INTO public.authors VALUES (1717, 'Brite', 'Poppy Z.');
INSERT INTO public.authors VALUES (2112, 'Gorey', 'Edward');
INSERT INTO public.authors VALUES (2001, 'Clarke', 'Arthur C.');
INSERT INTO public.authors VALUES (1213, 'Brookins', 'Andrew');


--
-- Data for Name: book_backup; Type: TABLE DATA; Schema: public; Owner: demouser
--

INSERT INTO public.book_backup VALUES (7808, 'The Shining', 4156, 9);
INSERT INTO public.book_backup VALUES (4513, 'Dune', 1866, 15);
INSERT INTO public.book_backup VALUES (4267, '2001: A Space Odyssey', 2001, 15);
INSERT INTO public.book_backup VALUES (1608, 'The Cat in the Hat', 1809, 2);
INSERT INTO public.book_backup VALUES (1590, 'Bartholomew and the Oobleck', 1809, 2);
INSERT INTO public.book_backup VALUES (25908, 'Franklin in the Dark', 15990, 2);
INSERT INTO public.book_backup VALUES (1501, 'Goodnight Moon', 2031, 2);
INSERT INTO public.book_backup VALUES (190, 'Little Women', 16, 6);
INSERT INTO public.book_backup VALUES (1234, 'The Velveteen Rabbit', 25041, 3);
INSERT INTO public.book_backup VALUES (2038, 'Dynamic Anatomy', 1644, 0);
INSERT INTO public.book_backup VALUES (156, 'The Tell-Tale Heart', 115, 9);
INSERT INTO public.book_backup VALUES (41472, 'Practical PostgreSQL', 1212, 4);
INSERT INTO public.book_backup VALUES (41473, 'Programming Python', 7805, 4);
INSERT INTO public.book_backup VALUES (41477, 'Learning Python', 7805, 4);
INSERT INTO public.book_backup VALUES (41478, 'Perl Cookbook', 7806, 4);
INSERT INTO public.book_backup VALUES (7808, 'The Shining', 4156, 9);
INSERT INTO public.book_backup VALUES (4513, 'Dune', 1866, 15);
INSERT INTO public.book_backup VALUES (4267, '2001: A Space Odyssey', 2001, 15);
INSERT INTO public.book_backup VALUES (1608, 'The Cat in the Hat', 1809, 2);
INSERT INTO public.book_backup VALUES (1590, 'Bartholomew and the Oobleck', 1809, 2);
INSERT INTO public.book_backup VALUES (25908, 'Franklin in the Dark', 15990, 2);
INSERT INTO public.book_backup VALUES (1501, 'Goodnight Moon', 2031, 2);
INSERT INTO public.book_backup VALUES (190, 'Little Women', 16, 6);
INSERT INTO public.book_backup VALUES (1234, 'The Velveteen Rabbit', 25041, 3);
INSERT INTO public.book_backup VALUES (2038, 'Dynamic Anatomy', 1644, 0);
INSERT INTO public.book_backup VALUES (156, 'The Tell-Tale Heart', 115, 9);
INSERT INTO public.book_backup VALUES (41473, 'Programming Python', 7805, 4);
INSERT INTO public.book_backup VALUES (41477, 'Learning Python', 7805, 4);
INSERT INTO public.book_backup VALUES (41478, 'Perl Cookbook', 7806, 4);
INSERT INTO public.book_backup VALUES (41472, 'Practical PostgreSQL', 1212, 4);


--
-- Data for Name: book_queue; Type: TABLE DATA; Schema: public; Owner: demouser
--

INSERT INTO public.book_queue VALUES ('Learning Python', 7805, 4, true);
INSERT INTO public.book_queue VALUES ('Perl Cookbook', 7806, 4, true);


--
-- Data for Name: books; Type: TABLE DATA; Schema: public; Owner: demouser
--

INSERT INTO public.books VALUES (7808, 'The Shining', 4156, 9);
INSERT INTO public.books VALUES (4513, 'Dune', 1866, 15);
INSERT INTO public.books VALUES (4267, '2001: A Space Odyssey', 2001, 15);
INSERT INTO public.books VALUES (1608, 'The Cat in the Hat', 1809, 2);
INSERT INTO public.books VALUES (1590, 'Bartholomew and the Oobleck', 1809, 2);
INSERT INTO public.books VALUES (25908, 'Franklin in the Dark', 15990, 2);
INSERT INTO public.books VALUES (1501, 'Goodnight Moon', 2031, 2);
INSERT INTO public.books VALUES (190, 'Little Women', 16, 6);
INSERT INTO public.books VALUES (1234, 'The Velveteen Rabbit', 25041, 3);
INSERT INTO public.books VALUES (2038, 'Dynamic Anatomy', 1644, 0);
INSERT INTO public.books VALUES (156, 'The Tell-Tale Heart', 115, 9);
INSERT INTO public.books VALUES (41473, 'Programming Python', 7805, 4);
INSERT INTO public.books VALUES (41477, 'Learning Python', 7805, 4);
INSERT INTO public.books VALUES (41478, 'Perl Cookbook', 7806, 4);
INSERT INTO public.books VALUES (41472, 'Practical PostgreSQL', 1212, 4);


--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: demouser
--

INSERT INTO public.customers VALUES (107, 'Jackson', 'Annie');
INSERT INTO public.customers VALUES (112, 'Gould', 'Ed');
INSERT INTO public.customers VALUES (142, 'Allen', 'Chad');
INSERT INTO public.customers VALUES (146, 'Williams', 'James');
INSERT INTO public.customers VALUES (172, 'Brown', 'Richard');
INSERT INTO public.customers VALUES (185, 'Morrill', 'Eric');
INSERT INTO public.customers VALUES (221, 'King', 'Jenny');
INSERT INTO public.customers VALUES (270, 'Bollman', 'Julie');
INSERT INTO public.customers VALUES (388, 'Morrill', 'Royce');
INSERT INTO public.customers VALUES (409, 'Holloway', 'Christine');
INSERT INTO public.customers VALUES (430, 'Black', 'Jean');
INSERT INTO public.customers VALUES (476, 'Clark', 'James');
INSERT INTO public.customers VALUES (480, 'Thomas', 'Rich');
INSERT INTO public.customers VALUES (488, 'Young', 'Trevor');
INSERT INTO public.customers VALUES (574, 'Bennett', 'Laura');
INSERT INTO public.customers VALUES (652, 'Anderson', 'Jonathan');
INSERT INTO public.customers VALUES (655, 'Olson', 'Dave');
INSERT INTO public.customers VALUES (671, 'Brown', 'Chuck');
INSERT INTO public.customers VALUES (723, 'Eisele', 'Don');
INSERT INTO public.customers VALUES (724, 'Holloway', 'Adam');
INSERT INTO public.customers VALUES (738, 'Gould', 'Shirley');
INSERT INTO public.customers VALUES (830, 'Robertson', 'Royce');
INSERT INTO public.customers VALUES (853, 'Black', 'Wendy');
INSERT INTO public.customers VALUES (860, 'Owens', 'Tim');
INSERT INTO public.customers VALUES (880, 'Robinson', 'Tammy');
INSERT INTO public.customers VALUES (898, 'Gerdes', 'Kate');
INSERT INTO public.customers VALUES (964, 'Gould', 'Ramon');
INSERT INTO public.customers VALUES (1045, 'Owens', 'Jean');
INSERT INTO public.customers VALUES (1125, 'Bollman', 'Owen');
INSERT INTO public.customers VALUES (1149, 'Becker', 'Owen');
INSERT INTO public.customers VALUES (1123, 'Corner', 'Kathy');


--
-- Data for Name: daily_inventory; Type: TABLE DATA; Schema: public; Owner: demouser
--

INSERT INTO public.daily_inventory VALUES ('039480001X', true);
INSERT INTO public.daily_inventory VALUES ('044100590X', true);
INSERT INTO public.daily_inventory VALUES ('0451198492', false);
INSERT INTO public.daily_inventory VALUES ('0394900014', false);
INSERT INTO public.daily_inventory VALUES ('0441172717', true);
INSERT INTO public.daily_inventory VALUES ('0451160916', false);
INSERT INTO public.daily_inventory VALUES ('0385121679', NULL);


--
-- Data for Name: editions; Type: TABLE DATA; Schema: public; Owner: demouser
--

INSERT INTO public.editions VALUES ('039480001X', 1608, 1, 59, '1957-03-01', 'h');
INSERT INTO public.editions VALUES ('0451160916', 7808, 1, 75, '1981-08-01', 'p');
INSERT INTO public.editions VALUES ('0394800753', 1590, 1, 59, '1949-03-01', 'p');
INSERT INTO public.editions VALUES ('0590445065', 25908, 1, 150, '1987-03-01', 'p');
INSERT INTO public.editions VALUES ('0694003611', 1501, 1, 65, '1947-03-04', 'p');
INSERT INTO public.editions VALUES ('0679803335', 1234, 1, 102, '1922-01-01', 'p');
INSERT INTO public.editions VALUES ('0760720002', 190, 1, 91, '1868-01-01', 'p');
INSERT INTO public.editions VALUES ('0394900014', 1608, 1, 59, '1957-01-01', 'p');
INSERT INTO public.editions VALUES ('0385121679', 7808, 2, 75, '1993-10-01', 'h');
INSERT INTO public.editions VALUES ('1885418035', 156, 1, 163, '1995-03-28', 'p');
INSERT INTO public.editions VALUES ('0929605942', 156, 2, 171, '1998-12-01', 'p');
INSERT INTO public.editions VALUES ('0441172717', 4513, 2, 99, '1998-09-01', 'p');
INSERT INTO public.editions VALUES ('044100590X', 4513, 3, 99, '1999-10-01', 'h');
INSERT INTO public.editions VALUES ('0451457994', 4267, 3, 101, '2000-09-12', 'p');
INSERT INTO public.editions VALUES ('0451198492', 4267, 3, 101, '1999-10-01', 'h');
INSERT INTO public.editions VALUES ('0823015505', 2038, 1, 62, '1958-01-01', 'p');
INSERT INTO public.editions VALUES ('0596000855', 41473, 2, 113, '2001-03-01', 'p');


--
-- Data for Name: employees; Type: TABLE DATA; Schema: public; Owner: demouser
--

INSERT INTO public.employees VALUES (101, 'Appel', 'Vincent');
INSERT INTO public.employees VALUES (102, 'Holloway', 'Michael');
INSERT INTO public.employees VALUES (105, 'Connoly', 'Sarah');
INSERT INTO public.employees VALUES (104, 'Noble', 'Ben');
INSERT INTO public.employees VALUES (103, 'Joble', 'David');
INSERT INTO public.employees VALUES (106, 'Hall', 'Timothy');
INSERT INTO public.employees VALUES (1008, 'Williams', NULL);


--
-- Data for Name: favorite_books; Type: TABLE DATA; Schema: public; Owner: demouser
--

INSERT INTO public.favorite_books VALUES (102, '{"The Hitchhiker''s Guide to the Galaxy","The Restauraunt at the End of the Universe"}');
INSERT INTO public.favorite_books VALUES (103, '{"There and Back Again: A Hobbit''s Holiday","Kittens Squared"}');


--
-- Data for Name: my_list; Type: TABLE DATA; Schema: public; Owner: demouser
--

INSERT INTO public.my_list VALUES ('Pick up laundry.');
INSERT INTO public.my_list VALUES ('Send out bills.');
INSERT INTO public.my_list VALUES ('Wrap up Grand Unifying Theory for publication.');


--
-- Data for Name: numeric_values; Type: TABLE DATA; Schema: public; Owner: demouser
--

INSERT INTO public.numeric_values VALUES (68719476736.000000);
INSERT INTO public.numeric_values VALUES (68719476737.000000);
INSERT INTO public.numeric_values VALUES (6871947673778.000000);
INSERT INTO public.numeric_values VALUES (999999999999999999999999.999900);
INSERT INTO public.numeric_values VALUES (999999999999999999999999.999999);
INSERT INTO public.numeric_values VALUES (-999999999999999999999999.999999);
INSERT INTO public.numeric_values VALUES (-100000000000000000000000.999999);
INSERT INTO public.numeric_values VALUES (1.999999);
INSERT INTO public.numeric_values VALUES (2.000000);
INSERT INTO public.numeric_values VALUES (2.000000);
INSERT INTO public.numeric_values VALUES (999999999999999999999999.999999);
INSERT INTO public.numeric_values VALUES (999999999999999999999999.000000);


--
-- Data for Name: publishers; Type: TABLE DATA; Schema: public; Owner: demouser
--

INSERT INTO public.publishers VALUES (150, 'Kids Can Press', 'Kids Can Press, 29 Birch Ave. Toronto,ON M4V 1E2');
INSERT INTO public.publishers VALUES (91, 'Henry Holt & Company, Inc.', 'Henry Holt & Company, Inc. 115 West 18th Street New York, NY 10011');
INSERT INTO public.publishers VALUES (113, 'O''Reilly & Associates', 'O''Reilly & Associates, Inc. 101 Morris St, Sebastopol, CA 95472');
INSERT INTO public.publishers VALUES (62, 'Watson-Guptill Publications', '1515 Boradway, New York, NY 10036');
INSERT INTO public.publishers VALUES (105, 'Noonday Press', 'Farrar Straus & Giroux Inc, 19 Union Square W, New York, NY 10003');
INSERT INTO public.publishers VALUES (99, 'Ace Books', 'The Berkley Publishing Group, Penguin Putnam Inc, 375 Hudson St, New York, NY 10014');
INSERT INTO public.publishers VALUES (101, 'Roc', 'Penguin Putnam Inc, 375 Hudson St, New York, NY 10014');
INSERT INTO public.publishers VALUES (163, 'Mojo Press', 'Mojo Press, PO Box 1215, Dripping Springs, TX 78720');
INSERT INTO public.publishers VALUES (171, 'Books of Wonder', 'Books of Wonder, 16 W. 18th St. New York, NY, 10011');
INSERT INTO public.publishers VALUES (102, 'Penguin', 'Penguin Putnam Inc, 375 Hudson St, New York, NY 10014');
INSERT INTO public.publishers VALUES (75, 'Doubleday', 'Random House, Inc, 1540 Broadway, New York, NY 10036');
INSERT INTO public.publishers VALUES (65, 'HarperCollins', 'HarperCollins Publishers, 10 E 53rd St, New York, NY 10022');
INSERT INTO public.publishers VALUES (59, 'Random House', 'Random House, Inc, 1540 Broadway, New York, NY 10036');


--
-- Data for Name: schedules; Type: TABLE DATA; Schema: public; Owner: demouser
--

INSERT INTO public.schedules VALUES (102, 'Mon - Fri, 9am - 5pm');


--
-- Data for Name: shipments; Type: TABLE DATA; Schema: public; Owner: demouser
--

INSERT INTO public.shipments VALUES (375, 142, '039480001X', '2001-08-06 16:29:21+00');
INSERT INTO public.shipments VALUES (323, 671, '0451160916', '2001-08-14 17:36:41+00');
INSERT INTO public.shipments VALUES (998, 1045, '0590445065', '2001-08-12 19:09:47+00');
INSERT INTO public.shipments VALUES (749, 172, '0694003611', '2001-08-11 17:52:34+00');
INSERT INTO public.shipments VALUES (662, 655, '0679803335', '2001-08-09 14:30:07+00');
INSERT INTO public.shipments VALUES (806, 1125, '0760720002', '2001-08-05 16:34:04+00');
INSERT INTO public.shipments VALUES (102, 146, '0394900014', '2001-08-11 20:34:08+00');
INSERT INTO public.shipments VALUES (813, 112, '0385121679', '2001-08-08 16:53:46+00');
INSERT INTO public.shipments VALUES (652, 724, '1885418035', '2001-08-14 20:41:39+00');
INSERT INTO public.shipments VALUES (599, 430, '0929605942', '2001-08-10 15:29:42+00');
INSERT INTO public.shipments VALUES (969, 488, '0441172717', '2001-08-14 15:42:58+00');
INSERT INTO public.shipments VALUES (433, 898, '044100590X', '2001-08-12 15:46:35+00');
INSERT INTO public.shipments VALUES (660, 409, '0451457994', '2001-08-07 18:56:42+00');
INSERT INTO public.shipments VALUES (310, 738, '0451198492', '2001-08-15 21:02:01+00');
INSERT INTO public.shipments VALUES (510, 860, '0823015505', '2001-08-14 14:33:47+00');
INSERT INTO public.shipments VALUES (997, 185, '039480001X', '2001-08-10 20:47:52+00');
INSERT INTO public.shipments VALUES (999, 221, '0451160916', '2001-08-14 20:45:51+00');
INSERT INTO public.shipments VALUES (56, 880, '0590445065', '2001-08-14 20:49:00+00');
INSERT INTO public.shipments VALUES (72, 574, '0694003611', '2001-08-06 14:49:44+00');
INSERT INTO public.shipments VALUES (146, 270, '039480001X', '2001-08-13 16:42:10+00');
INSERT INTO public.shipments VALUES (981, 652, '0451160916', '2001-08-08 15:36:44+00');
INSERT INTO public.shipments VALUES (95, 480, '0590445065', '2001-08-10 14:29:52+00');
INSERT INTO public.shipments VALUES (593, 476, '0694003611', '2001-08-15 18:57:40+00');
INSERT INTO public.shipments VALUES (977, 853, '0679803335', '2001-08-09 16:30:46+00');
INSERT INTO public.shipments VALUES (117, 185, '0760720002', '2001-08-07 20:00:48+00');
INSERT INTO public.shipments VALUES (406, 1123, '0394900014', '2001-08-13 16:47:04+00');
INSERT INTO public.shipments VALUES (340, 1149, '0385121679', '2001-08-12 20:39:22+00');
INSERT INTO public.shipments VALUES (871, 388, '1885418035', '2001-08-07 18:31:57+00');
INSERT INTO public.shipments VALUES (1000, 221, '039480001X', '2001-09-14 23:46:32+00');
INSERT INTO public.shipments VALUES (1001, 107, '039480001X', '2001-09-15 00:42:22+00');
INSERT INTO public.shipments VALUES (754, 107, '0394800753', '2001-08-11 16:55:05+00');
INSERT INTO public.shipments VALUES (458, 107, '0394800753', '2001-08-07 17:58:36+00');
INSERT INTO public.shipments VALUES (189, 107, '0394800753', '2001-08-06 18:46:36+00');
INSERT INTO public.shipments VALUES (720, 107, '0394800753', '2001-08-08 17:46:13+00');
INSERT INTO public.shipments VALUES (1002, 107, '0394800753', '2001-09-22 18:23:28+00');
INSERT INTO public.shipments VALUES (2, 107, '0394800753', '2001-09-23 03:58:56+00');


--
-- Data for Name: states; Type: TABLE DATA; Schema: public; Owner: demouser
--

INSERT INTO public.states VALUES (42, 'Washington', 'WA');
INSERT INTO public.states VALUES (51, 'Oregon', 'OR');


--
-- Data for Name: stock; Type: TABLE DATA; Schema: public; Owner: demouser
--

INSERT INTO public.stock VALUES ('0385121679', 29.00, 36.95, 65);
INSERT INTO public.stock VALUES ('039480001X', 30.00, 32.95, 31);
INSERT INTO public.stock VALUES ('0394900014', 23.00, 23.95, 0);
INSERT INTO public.stock VALUES ('044100590X', 36.00, 45.95, 89);
INSERT INTO public.stock VALUES ('0441172717', 17.00, 21.95, 77);
INSERT INTO public.stock VALUES ('0451160916', 24.00, 28.95, 22);
INSERT INTO public.stock VALUES ('0451198492', 36.00, 46.95, 0);
INSERT INTO public.stock VALUES ('0451457994', 17.00, 22.95, 0);
INSERT INTO public.stock VALUES ('0590445065', 23.00, 23.95, 10);
INSERT INTO public.stock VALUES ('0679803335', 20.00, 24.95, 18);
INSERT INTO public.stock VALUES ('0694003611', 25.00, 28.95, 50);
INSERT INTO public.stock VALUES ('0760720002', 18.00, 23.95, 28);
INSERT INTO public.stock VALUES ('0823015505', 26.00, 28.95, 16);
INSERT INTO public.stock VALUES ('0929605942', 19.00, 21.95, 25);
INSERT INTO public.stock VALUES ('1885418035', 23.00, 24.95, 77);
INSERT INTO public.stock VALUES ('0394800753', 16.00, 16.95, 4);


--
-- Data for Name: stock_backup; Type: TABLE DATA; Schema: public; Owner: demouser
--

INSERT INTO public.stock_backup VALUES ('0385121679', 29.00, 36.95, 65);
INSERT INTO public.stock_backup VALUES ('039480001X', 30.00, 32.95, 31);
INSERT INTO public.stock_backup VALUES ('0394800753', 16.00, 16.95, 0);
INSERT INTO public.stock_backup VALUES ('0394900014', 23.00, 23.95, 0);
INSERT INTO public.stock_backup VALUES ('044100590X', 36.00, 45.95, 89);
INSERT INTO public.stock_backup VALUES ('0441172717', 17.00, 21.95, 77);
INSERT INTO public.stock_backup VALUES ('0451160916', 24.00, 28.95, 22);
INSERT INTO public.stock_backup VALUES ('0451198492', 36.00, 46.95, 0);
INSERT INTO public.stock_backup VALUES ('0451457994', 17.00, 22.95, 0);
INSERT INTO public.stock_backup VALUES ('0590445065', 23.00, 23.95, 10);
INSERT INTO public.stock_backup VALUES ('0679803335', 20.00, 24.95, 18);
INSERT INTO public.stock_backup VALUES ('0694003611', 25.00, 28.95, 50);
INSERT INTO public.stock_backup VALUES ('0760720002', 18.00, 23.95, 28);
INSERT INTO public.stock_backup VALUES ('0823015505', 26.00, 28.95, 16);
INSERT INTO public.stock_backup VALUES ('0929605942', 19.00, 21.95, 25);
INSERT INTO public.stock_backup VALUES ('1885418035', 23.00, 24.95, 77);


--
-- Data for Name: subjects; Type: TABLE DATA; Schema: public; Owner: demouser
--

INSERT INTO public.subjects VALUES (0, 'Arts', 'Creativity St');
INSERT INTO public.subjects VALUES (1, 'Business', 'Productivity Ave');
INSERT INTO public.subjects VALUES (2, 'Children''s Books', 'Kids Ct');
INSERT INTO public.subjects VALUES (3, 'Classics', 'Academic Rd');
INSERT INTO public.subjects VALUES (4, 'Computers', 'Productivity Ave');
INSERT INTO public.subjects VALUES (5, 'Cooking', 'Creativity St');
INSERT INTO public.subjects VALUES (6, 'Drama', 'Main St');
INSERT INTO public.subjects VALUES (7, 'Entertainment', 'Main St');
INSERT INTO public.subjects VALUES (8, 'History', 'Academic Rd');
INSERT INTO public.subjects VALUES (9, 'Horror', 'Black Raven Dr');
INSERT INTO public.subjects VALUES (10, 'Mystery', 'Black Raven Dr');
INSERT INTO public.subjects VALUES (11, 'Poetry', 'Sunset Dr');
INSERT INTO public.subjects VALUES (12, 'Religion', NULL);
INSERT INTO public.subjects VALUES (13, 'Romance', 'Main St');
INSERT INTO public.subjects VALUES (14, 'Science', 'Productivity Ave');
INSERT INTO public.subjects VALUES (15, 'Science Fiction', 'Main St');


--
-- Data for Name: text_sorting; Type: TABLE DATA; Schema: public; Owner: demouser
--

INSERT INTO public.text_sorting VALUES ('0');
INSERT INTO public.text_sorting VALUES ('1');
INSERT INTO public.text_sorting VALUES ('2');
INSERT INTO public.text_sorting VALUES ('3');
INSERT INTO public.text_sorting VALUES ('A');
INSERT INTO public.text_sorting VALUES ('B');
INSERT INTO public.text_sorting VALUES ('C');
INSERT INTO public.text_sorting VALUES ('D');
INSERT INTO public.text_sorting VALUES ('a');
INSERT INTO public.text_sorting VALUES ('b');
INSERT INTO public.text_sorting VALUES ('c');
INSERT INTO public.text_sorting VALUES ('d');


--
-- Name: author_ids; Type: SEQUENCE SET; Schema: public; Owner: demouser
--

SELECT pg_catalog.setval('public.author_ids', 25044, true);


--
-- Name: book_ids; Type: SEQUENCE SET; Schema: public; Owner: demouser
--

SELECT pg_catalog.setval('public.book_ids', 41478, true);


--
-- Name: shipments_ship_id_seq; Type: SEQUENCE SET; Schema: public; Owner: demouser
--

SELECT pg_catalog.setval('public.shipments_ship_id_seq', 1011, true);


--
-- Name: subject_ids; Type: SEQUENCE SET; Schema: public; Owner: demouser
--

SELECT pg_catalog.setval('public.subject_ids', 15, true);


--
-- Name: authors authors_pkey; Type: CONSTRAINT; Schema: public; Owner: demouser
--

ALTER TABLE ONLY public.authors
    ADD CONSTRAINT authors_pkey PRIMARY KEY (id);


--
-- Name: books books_id_pkey; Type: CONSTRAINT; Schema: public; Owner: demouser
--

ALTER TABLE ONLY public.books
    ADD CONSTRAINT books_id_pkey PRIMARY KEY (id);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: demouser
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- Name: employees employees_pkey; Type: CONSTRAINT; Schema: public; Owner: demouser
--

ALTER TABLE ONLY public.employees
    ADD CONSTRAINT employees_pkey PRIMARY KEY (id);


--
-- Name: editions pkey; Type: CONSTRAINT; Schema: public; Owner: demouser
--

ALTER TABLE ONLY public.editions
    ADD CONSTRAINT pkey PRIMARY KEY (isbn);


--
-- Name: publishers publishers_pkey; Type: CONSTRAINT; Schema: public; Owner: demouser
--

ALTER TABLE ONLY public.publishers
    ADD CONSTRAINT publishers_pkey PRIMARY KEY (id);


--
-- Name: schedules schedules_pkey; Type: CONSTRAINT; Schema: public; Owner: demouser
--

ALTER TABLE ONLY public.schedules
    ADD CONSTRAINT schedules_pkey PRIMARY KEY (employee_id);


--
-- Name: states state_pkey; Type: CONSTRAINT; Schema: public; Owner: demouser
--

ALTER TABLE ONLY public.states
    ADD CONSTRAINT state_pkey PRIMARY KEY (id);


--
-- Name: stock stock_pkey; Type: CONSTRAINT; Schema: public; Owner: demouser
--

ALTER TABLE ONLY public.stock
    ADD CONSTRAINT stock_pkey PRIMARY KEY (isbn);


--
-- Name: subjects subjects_pkey; Type: CONSTRAINT; Schema: public; Owner: demouser
--

ALTER TABLE ONLY public.subjects
    ADD CONSTRAINT subjects_pkey PRIMARY KEY (id);


--
-- Name: books_title_idx; Type: INDEX; Schema: public; Owner: demouser
--

CREATE INDEX books_title_idx ON public.books USING btree (title);


--
-- Name: shipments_ship_id_key; Type: INDEX; Schema: public; Owner: demouser
--

CREATE UNIQUE INDEX shipments_ship_id_key ON public.shipments USING btree (id);


--
-- Name: text_idx; Type: INDEX; Schema: public; Owner: demouser
--

CREATE INDEX text_idx ON public.text_sorting USING btree (letter);


--
-- Name: unique_publisher_idx; Type: INDEX; Schema: public; Owner: demouser
--

CREATE UNIQUE INDEX unique_publisher_idx ON public.publishers USING btree (name);


--
-- Name: TABLE alternate_stock; Type: ACL; Schema: public; Owner: demouser
--

REVOKE ALL ON TABLE public.alternate_stock FROM demouser;
GRANT SELECT ON TABLE public.alternate_stock TO demouser;


--
-- Name: TABLE authors; Type: ACL; Schema: public; Owner: demouser
--

REVOKE ALL ON TABLE public.authors FROM demouser;
GRANT SELECT ON TABLE public.authors TO demouser;


--
-- Name: TABLE book_backup; Type: ACL; Schema: public; Owner: demouser
--

REVOKE ALL ON TABLE public.book_backup FROM demouser;
GRANT SELECT ON TABLE public.book_backup TO demouser;


--
-- Name: TABLE book_queue; Type: ACL; Schema: public; Owner: demouser
--

REVOKE ALL ON TABLE public.book_queue FROM demouser;
GRANT SELECT ON TABLE public.book_queue TO demouser;


--
-- Name: TABLE books; Type: ACL; Schema: public; Owner: demouser
--

REVOKE ALL ON TABLE public.books FROM demouser;
GRANT SELECT ON TABLE public.books TO demouser;


--
-- Name: TABLE customers; Type: ACL; Schema: public; Owner: demouser
--

REVOKE ALL ON TABLE public.customers FROM demouser;
GRANT SELECT ON TABLE public.customers TO demouser;


--
-- Name: TABLE daily_inventory; Type: ACL; Schema: public; Owner: demouser
--

REVOKE ALL ON TABLE public.daily_inventory FROM demouser;
GRANT SELECT ON TABLE public.daily_inventory TO demouser;

--
-- Name: TABLE editions; Type: ACL; Schema: public; Owner: demouser
--

REVOKE ALL ON TABLE public.editions FROM demouser;
GRANT SELECT ON TABLE public.editions TO demouser;


--
-- Name: TABLE employees; Type: ACL; Schema: public; Owner: demouser
--

REVOKE ALL ON TABLE public.employees FROM demouser;
GRANT SELECT ON TABLE public.employees TO demouser;


--
-- Name: TABLE favorite_authors; Type: ACL; Schema: public; Owner: demouser
--

REVOKE ALL ON TABLE public.favorite_authors FROM demouser;
GRANT SELECT ON TABLE public.favorite_authors TO demouser;


--
-- Name: TABLE favorite_books; Type: ACL; Schema: public; Owner: demouser
--

REVOKE ALL ON TABLE public.favorite_books FROM demouser;
GRANT SELECT ON TABLE public.favorite_books TO demouser;


--
-- Name: TABLE my_list; Type: ACL; Schema: public; Owner: demouser
--

REVOKE ALL ON TABLE public.my_list FROM demouser;
GRANT SELECT ON TABLE public.my_list TO demouser;


--
-- Name: TABLE numeric_values; Type: ACL; Schema: public; Owner: demouser
--

REVOKE ALL ON TABLE public.numeric_values FROM demouser;
GRANT SELECT ON TABLE public.numeric_values TO demouser;


--
-- Name: TABLE publishers; Type: ACL; Schema: public; Owner: demouser
--

REVOKE ALL ON TABLE public.publishers FROM demouser;
GRANT SELECT ON TABLE public.publishers TO demouser;


--
-- Name: TABLE shipments; Type: ACL; Schema: public; Owner: demouser
--

REVOKE ALL ON TABLE public.shipments FROM demouser;
GRANT SELECT ON TABLE public.shipments TO demouser;


--
-- Name: TABLE recent_shipments; Type: ACL; Schema: public; Owner: demouser
--

REVOKE ALL ON TABLE public.recent_shipments FROM demouser;
GRANT SELECT ON TABLE public.recent_shipments TO demouser;


--
-- Name: TABLE schedules; Type: ACL; Schema: public; Owner: demouser
--

REVOKE ALL ON TABLE public.schedules FROM demouser;
GRANT SELECT ON TABLE public.schedules TO demouser;


--
-- Name: TABLE states; Type: ACL; Schema: public; Owner: demouser
--

REVOKE ALL ON TABLE public.states FROM demouser;
GRANT SELECT ON TABLE public.states TO demouser;


--
-- Name: TABLE stock; Type: ACL; Schema: public; Owner: demouser
--

REVOKE ALL ON TABLE public.stock FROM demouser;
GRANT SELECT ON TABLE public.stock TO demouser;


--
-- Name: TABLE stock_backup; Type: ACL; Schema: public; Owner: demouser
--

REVOKE ALL ON TABLE public.stock_backup FROM demouser;
GRANT SELECT ON TABLE public.stock_backup TO demouser;


--
-- Name: TABLE stock_view; Type: ACL; Schema: public; Owner: demouser
--

REVOKE ALL ON TABLE public.stock_view FROM demouser;
GRANT SELECT ON TABLE public.stock_view TO demouser;


--
-- Name: TABLE subjects; Type: ACL; Schema: public; Owner: demouser
--

REVOKE ALL ON TABLE public.subjects FROM demouser;
GRANT SELECT ON TABLE public.subjects TO demouser;


--
-- Name: TABLE text_sorting; Type: ACL; Schema: public; Owner: demouser
--

REVOKE ALL ON TABLE public.text_sorting FROM demouser;
GRANT SELECT ON TABLE public.text_sorting TO demouser;


--
-- PostgreSQL database dump complete
--


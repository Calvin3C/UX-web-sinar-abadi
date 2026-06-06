--
-- PostgreSQL database dump
--

\restrict gcgbDndveA7fAI199cdSiqM6nSCCQVzagL7j3W5wsrqmonNYPuAhg3khgq43enb

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: admins; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.admins (
    id bigint NOT NULL,
    username character varying(100) NOT NULL,
    password text NOT NULL,
    name character varying(200) NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    email character varying(200),
    phone character varying(50)
);


ALTER TABLE public.admins OWNER TO postgres;

--
-- Name: admins_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.admins_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.admins_id_seq OWNER TO postgres;

--
-- Name: admins_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.admins_id_seq OWNED BY public.admins.id;


--
-- Name: customer_addresses; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customer_addresses (
    id bigint NOT NULL,
    customer_id bigint NOT NULL,
    label character varying(100) NOT NULL,
    recipient_name character varying(200) NOT NULL,
    phone_number character varying(50) NOT NULL,
    city character varying(200),
    full_address text NOT NULL,
    notes character varying(200),
    postal_code character varying(20),
    biteship_area_id character varying(100),
    is_primary boolean DEFAULT false,
    pinpoint boolean DEFAULT false,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.customer_addresses OWNER TO postgres;

--
-- Name: customer_addresses_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.customer_addresses_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.customer_addresses_id_seq OWNER TO postgres;

--
-- Name: customer_addresses_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.customer_addresses_id_seq OWNED BY public.customer_addresses.id;


--
-- Name: customers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.customers (
    id bigint NOT NULL,
    username character varying(100) NOT NULL,
    password text NOT NULL,
    name character varying(200) NOT NULL,
    phone character varying(50),
    email character varying(200),
    gender character varying(20),
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.customers OWNER TO postgres;

--
-- Name: customers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.customers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.customers_id_seq OWNER TO postgres;

--
-- Name: customers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.customers_id_seq OWNED BY public.customers.id;


--
-- Name: order_items; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.order_items (
    id bigint NOT NULL,
    order_id character varying(30) NOT NULL,
    product_id character varying(20),
    name character varying(300) NOT NULL,
    qty bigint NOT NULL,
    price bigint NOT NULL,
    color character varying(100),
    weight bigint DEFAULT 0,
    length bigint DEFAULT 1,
    width bigint DEFAULT 1,
    height bigint DEFAULT 1
);


ALTER TABLE public.order_items OWNER TO postgres;

--
-- Name: order_items_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.order_items_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.order_items_id_seq OWNER TO postgres;

--
-- Name: order_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.order_items_id_seq OWNED BY public.order_items.id;


--
-- Name: orders; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.orders (
    id character varying(30) NOT NULL,
    date character varying(20) NOT NULL,
    customer_id bigint NOT NULL,
    customer_name character varying(200),
    phone character varying(30),
    address text,
    shipping_method character varying(100),
    total bigint NOT NULL,
    status character varying(20) DEFAULT 'pending'::character varying NOT NULL,
    shipping_status character varying(100) DEFAULT 'Menunggu Validasi'::character varying NOT NULL,
    proof_uploaded boolean DEFAULT false,
    proof_url text,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.orders OWNER TO postgres;

--
-- Name: owners; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.owners (
    id bigint NOT NULL,
    username character varying(100) NOT NULL,
    password text NOT NULL,
    name character varying(200) NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    email character varying(200),
    phone character varying(50)
);


ALTER TABLE public.owners OWNER TO postgres;

--
-- Name: owners_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.owners_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.owners_id_seq OWNER TO postgres;

--
-- Name: owners_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.owners_id_seq OWNED BY public.owners.id;


--
-- Name: payments; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.payments (
    id bigint NOT NULL,
    order_id character varying(30) NOT NULL,
    payment_method character varying(50),
    amount_paid bigint NOT NULL,
    payment_status character varying(20) DEFAULT 'Pending'::character varying NOT NULL,
    paid_at timestamp with time zone,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.payments OWNER TO postgres;

--
-- Name: payments_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.payments_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.payments_id_seq OWNER TO postgres;

--
-- Name: payments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.payments_id_seq OWNED BY public.payments.id;


--
-- Name: product_variants; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.product_variants (
    id bigint NOT NULL,
    product_id character varying(20) NOT NULL,
    name character varying(100) NOT NULL,
    price bigint DEFAULT 0 NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone
);


ALTER TABLE public.product_variants OWNER TO postgres;

--
-- Name: product_variants_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.product_variants_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.product_variants_id_seq OWNER TO postgres;

--
-- Name: product_variants_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.product_variants_id_seq OWNED BY public.product_variants.id;


--
-- Name: products; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.products (
    id character varying(20) NOT NULL,
    category character varying(100) NOT NULL,
    name character varying(300) NOT NULL,
    price bigint NOT NULL,
    sold bigint DEFAULT 0 NOT NULL,
    is_large boolean DEFAULT false,
    image_url character varying(500),
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    brand character varying(100),
    weight bigint DEFAULT 0,
    unit character varying(50),
    min_purchase bigint DEFAULT 1,
    length bigint DEFAULT 1,
    width bigint DEFAULT 1,
    height bigint DEFAULT 1
);


ALTER TABLE public.products OWNER TO postgres;

--
-- Name: shippings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.shippings (
    id bigint NOT NULL,
    order_id character varying(30) NOT NULL,
    shipping_method_id bigint,
    shipping_method_name character varying(100) NOT NULL,
    tracking_number character varying(30),
    shipping_cost bigint DEFAULT 0 NOT NULL,
    destination_address text NOT NULL,
    created_at timestamp with time zone,
    updated_at timestamp with time zone,
    biteship_area_id text,
    biteship_order_id character varying(100),
    waybill_id character varying(100),
    courier_company character varying(50),
    courier_type character varying(50),
    courier_code character varying(50),
    courier_service_code character varying(50)
);


ALTER TABLE public.shippings OWNER TO postgres;

--
-- Name: shippings_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.shippings_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.shippings_id_seq OWNER TO postgres;

--
-- Name: shippings_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.shippings_id_seq OWNED BY public.shippings.id;


--
-- Name: stock_logs; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.stock_logs (
    id bigint NOT NULL,
    product_id character varying(20) NOT NULL,
    owner_id bigint,
    change_type character varying(20) NOT NULL,
    qty_changed bigint NOT NULL,
    final_stock bigint NOT NULL,
    description text,
    created_at timestamp with time zone
);


ALTER TABLE public.stock_logs OWNER TO postgres;

--
-- Name: stock_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.stock_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.stock_logs_id_seq OWNER TO postgres;

--
-- Name: stock_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.stock_logs_id_seq OWNED BY public.stock_logs.id;


--
-- Name: admins id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admins ALTER COLUMN id SET DEFAULT nextval('public.admins_id_seq'::regclass);


--
-- Name: customer_addresses id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_addresses ALTER COLUMN id SET DEFAULT nextval('public.customer_addresses_id_seq'::regclass);


--
-- Name: customers id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers ALTER COLUMN id SET DEFAULT nextval('public.customers_id_seq'::regclass);


--
-- Name: order_items id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items ALTER COLUMN id SET DEFAULT nextval('public.order_items_id_seq'::regclass);


--
-- Name: owners id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.owners ALTER COLUMN id SET DEFAULT nextval('public.owners_id_seq'::regclass);


--
-- Name: payments id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments ALTER COLUMN id SET DEFAULT nextval('public.payments_id_seq'::regclass);


--
-- Name: product_variants id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_variants ALTER COLUMN id SET DEFAULT nextval('public.product_variants_id_seq'::regclass);


--
-- Name: shippings id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shippings ALTER COLUMN id SET DEFAULT nextval('public.shippings_id_seq'::regclass);


--
-- Name: stock_logs id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_logs ALTER COLUMN id SET DEFAULT nextval('public.stock_logs_id_seq'::regclass);


--
-- Data for Name: admins; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.admins (id, username, password, name, created_at, updated_at, email, phone) FROM stdin;
1	admin	$2a$10$x0Kq9JEq0rcqYP16JAJD3ejRa8dPrLN.7oWr5KgQ9ueitUkPbaa7u	Admin Operasional	2026-05-31 14:39:51.891997+07	2026-06-06 14:19:06.028369+07	admin123@gmail.com	0812345678
\.


--
-- Data for Name: customer_addresses; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.customer_addresses (id, customer_id, label, recipient_name, phone_number, city, full_address, notes, postal_code, biteship_area_id, is_primary, pinpoint, created_at, updated_at) FROM stdin;
1	1	Kantor Sinar Abadi	Budi Santoso	08123456789	Lowokwaru, Kota Malang, Jawa Timur	Jl. Letjen Sutoyo No. 12, Lowokwaru, Malang, Jawa Timur 65141		65141	IDNP11IDNC250IDND2612IDZ65141	t	f	2026-06-05 15:25:01.845476+07	2026-06-05 15:25:01.845476+07
3	3	Rumah	Christian Anthony Sucipto	+6282132148698	Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	Perumahan Ijen Nirwana Blok C3 no 11	Lewat jalan langsep	65116	IDNP11IDNC250IDND2615IDZ65116	t	f	2026-06-05 16:34:39.883664+07	2026-06-05 16:34:39.883664+07
2	2	Rumah 	Calvin Alexander Sucipto	082331339737	Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	Perumahan ijen nirwana cluster green river blokc3 no 11	Lewat jalan langsep	65116	IDNP11IDNC250IDND2615IDZ65116	t	f	2026-06-05 15:43:08.718819+07	2026-06-05 23:05:09.757383+07
\.


--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.customers (id, username, password, name, phone, email, gender, created_at, updated_at) FROM stdin;
1	budi	$2a$10$m1yC.drbFSEChraGNFUz/.UOUEeE4NgxAL3FJzjfC6Lvi3j4Xx7xC	Budi Santoso				2026-05-31 14:39:51.818583+07	2026-05-31 14:39:51.818583+07
3	SirChrizz	$2a$10$UjSkY3bxhNd9da8ENuEDfOr1HTBE0xkBH5uH8hfYou9a2YuB96GZ6	Christian Anthony Sucipto	+6282132148698	christian.anthony721@gmai.com	Laki-laki	2026-06-05 16:06:09.812996+07	2026-06-05 16:06:09.812996+07
2	Calvin3c	$2a$10$AJwgZn/Qoz9jZ0sBpilSru8EMSX1x4hFBc8NCaDMskpdPsLaib1xi	Calvin Alexander Sucipto	082331339737	calvinsucipto711@gmail.com	Laki-laki	2026-05-31 15:00:46.057297+07	2026-06-06 12:16:56.02083+07
\.


--
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.order_items (id, order_id, product_id, name, qty, price, color, weight, length, width, height) FROM stdin;
2	ORD-260402-309	P-001	Semen Gresik 40 kg	10	59000	\N	0	1	1	1
3	ORD-260531-793	P-002	Semen Merah Putih 40 kg	20	47000	\N	0	1	1	1
4	ORD-260531-793	P-004	Semen Putih Tiga Roda 40 kg	20	120000	\N	0	1	1	1
5	ORD-260531-325	P-004	Semen Putih Tiga Roda 40 kg	10	120000	\N	0	1	1	1
6	ORD-260601-785	P-004	Semen Putih Tiga Roda 40 kg	10	120000	\N	0	1	1	1
7	ORD-260601-785	P-002	Semen Merah Putih 40 kg	10	47000	\N	0	1	1	1
8	ORD-260601-741	P-061	Emco Warna Standart 1 kg	2	85000	\N	0	1	1	1
45	ORD-260605-558	P-004	Semen Putih Tiga Roda 40 kg	10	120000		40000	55	40	10
12	ORD-260603-541	P-002	Semen Merah Putih 40 kg	20	47000		0	1	1	1
13	ORD-260603-437	P-002	Semen Merah Putih 40 kg	10	47000		0	1	1	1
15	ORD-260603-820	P-002	Semen Merah Putih 40 kg	12	47000		0	1	1	1
16	ORD-260603-503	P-083	Mesin Bor Modern M2100	1	295000		0	1	1	1
17	ORD-260603-731	P-004	Semen Putih Tiga Roda 40 kg	10	120000		0	1	1	1
33	ORD-260604-871	P-001	Semen Gresik 40 kg	10	59000		40000	55	40	10
31	ORD-260604-224	P-001	Semen Gresik 40 kg	10	59000		0	1	1	1
32	ORD-260604-224	P-061	Emco Warna Standart 1 kg	3	85000	127 Pink	0	1	1	1
22	ORD-260603-210	P-074	Besi Beton 16 SNI	3	195000		0	1	1	1
21	ORD-260603-849	P-074	Besi Beton 16 SNI	4	195000		0	1	1	1
20	ORD-260603-480	P-074	Besi Beton 16 SNI	3	195000		0	1	1	1
19	ORD-260603-300	P-074	Besi Beton 16 SNI	5	195000		0	1	1	1
18	ORD-260603-256	P-074	Besi Beton 16 SNI	5	195000		0	1	1	1
14	ORD-260603-153	P-002	Semen Merah Putih 40 kg	11	47000		0	1	1	1
9	ORD-260603-721	P-002	Semen Merah Putih 40 kg	20	47000		0	1	1	1
10	ORD-260603-721	P-054	Avitex 25 kg	3	775000	601 Blue Romance	0	1	1	1
11	ORD-260603-721	P-074	Besi Beton 16 SNI	20	195000		0	1	1	1
1	ORD-260401-081	P-096	Lampu Philips LED 5 Watt	2	385000	\N	0	1	1	1
40	ORD-260604-216	P-021	Pipa Maspion 5/8 C	10	9000		900	400	2	2
23	ORD-260603-971	P-061	Emco Warna Standart 1 kg	5	85000	121 Cyan	0	1	1	1
24	ORD-260603-941	P-083	Mesin Bor Modern M2100	1	295000		0	1	1	1
25	ORD-260603-324	P-083	Mesin Bor Modern M2100	1	295000		0	1	1	1
44	ORD-260605-629	P-004	Semen Putih Tiga Roda 40 kg	10	120000		40000	55	40	10
34	ORD-260604-204	P-001	Semen Gresik 40 kg	10	59000		40000	55	40	10
26	ORD-260603-526	P-083	Mesin Bor Modern M2100	1	295000		0	1	1	1
27	ORD-260603-391	P-101	Kuas Eterna 1 Inch	10	7000		0	1	1	1
28	ORD-260603-629	P-061	Emco Warna Standart 1 kg	1	85000	48 Cream	0	1	1	1
29	ORD-260603-818	P-001	Semen Gresik 40 kg	10	59000		0	1	1	1
35	ORD-260604-204	P-074	Besi Beton 16 SNI	5	195000		18960	1200	2	2
30	ORD-260603-817	P-001	Semen Gresik 40 kg	10	59000		0	1	1	1
41	ORD-260604-787	P-061	Emco Warna Standart 1 kg	3	85000	111 Bata	1000	12	12	13
42	ORD-260604-787	P-077	Kloset Jongkok Duty	1	225000	Merah Maroon	25000	50	40	25
36	ORD-260604-705	P-101	Kuas Eterna 1 Inch	10	7000		60	18	3	1
37	ORD-260604-795	P-101	Kuas Eterna 1 Inch	10	7000		60	18	3	1
46	ORD-260605-444	P-001	Semen Gresik 40 kg	10	59000		40000	55	40	10
38	ORD-260604-969	P-101	Kuas Eterna 1 Inch	10	7000		60	18	3	1
43	ORD-260605-340	P-002	Semen Merah Putih 40 kg	10	47000		40000	55	40	10
39	ORD-260604-507	P-004	Semen Putih Tiga Roda 40 kg	10	120000		40000	55	40	10
50	ORD-260605-279	P-083	Mesin Bor Modern M2100	1	295000		1300	25	22	7
47	ORD-260605-505	P-001	Semen Gresik 40 kg	10	59000		40000	55	40	10
53	ORD-260606-964	P-106	Kuas Eterna 4 Inch	10	25000		80	23	10	2
48	ORD-260605-636	P-083	Mesin Bor Modern M2100	1	295000		1300	25	22	7
51	ORD-260605-300	P-102	Kuas Eterna 1.5 Inch	10	10000		60	19	4	1
49	ORD-260605-729	P-083	Mesin Bor Modern M2100	1	295000		1300	25	22	7
52	ORD-260605-128	P-102	Kuas Eterna 1.5 Inch	1	10000		60	19	4	1
55	ORD-260606-731	P-061	Emco Warna Standart 1 kg	5	85000	48 Kuning Krem	1000	12	12	13
54	ORD-260606-149	P-069	Besi Beton 6 SNI	10	28000		2660	1200	1	1
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.orders (id, date, customer_id, customer_name, phone, address, shipping_method, total, status, shipping_status, proof_uploaded, proof_url, created_at, updated_at) FROM stdin;
ORD-260603-256	2026-06-03	2	Calvin3c	082331339737	Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	JNE JNE Trucking	1127250	cancelled	Menunggu Validasi	t	http://localhost:8000/storage/proofs/kh5xVV1z1JUlSYZzMygrGswQiGmgnc1Nboc2h0lz.png	2026-06-03 18:02:28.556039+07	2026-06-03 19:01:58.58911+07
ORD-260603-731	2026-06-03	2	Calvin3c	082331339737	Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	Kurir Toko Sinar Abadi	1332000	COMPLETED	Menunggu Validasi	t	http://localhost:8000/storage/proofs/8p1cueNCemjPqpSITOhvd3c1chkTYbAEtJwasVHO.png	2026-06-03 14:34:02.584205+07	2026-06-03 14:37:16.6184+07
ORD-260402-309	2026-04-02	1	budi	081234567890	Toko Sinar Abadi	Ambil di Toko	721500	cancelled	Menunggu Validasi	t		2026-05-31 14:39:52.139977+07	2026-05-31 19:46:15.927171+07
ORD-260603-541	2026-06-03	2	Calvin3c	082331339737	Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	JNE JNE Trucking	2243400	COMPLETED	Kurir Sedang Dijadwalkan	t	http://localhost:8000/storage/proofs/zmQaYDcxFnWtRZV4wX0AkRDJ2CgcIkC80ryzkU6y.png	2026-06-03 12:56:55.369639+07	2026-06-03 13:55:17.727033+07
ORD-260531-793	2026-05-31	2	Calvin3c	+62 8123388670	Jalan Utara Masjid No.9, Dampit Wetan, Dampit, Kec. Dampit, Kabupaten Malang, Jawa Timur 65181	Ambil Di Toko	3707400	COMPLETED	Menunggu Validasi	t	http://localhost:8000/storage/proofs/xeCf0ZIuEMma9CIGJCQ66zuuFHshuNHeRpgbjHc5.png	2026-05-31 20:15:04.110778+07	2026-05-31 20:29:26.625628+07
ORD-260531-325	2026-05-31	2	Calvin3c	+62 8123388670	Jalan Utara Masjid No.9, Dampit Wetan, Dampit, Kec. Dampit, Kabupaten Malang, Jawa Timur 65181	Ambil Di Toko	1332000	pending	Menunggu Validasi	t	http://localhost:8000/storage/proofs/UBpgQhjvcixtsQzszkLfRQC7sPSMJ1Z3QXRWidtw.jpg	2026-05-31 21:02:38.606347+07	2026-05-31 21:02:38.63735+07
ORD-260603-820	2026-06-03	2	Calvin3c	082331339737	Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	JNE JNE Trucking	1346040	COMPLETED	Kurir Sedang Dijadwalkan	t	http://localhost:8000/storage/proofs/qhrnNT8L7hMCJ9GBkeh89O2IykoYJLTnjzpY3xgz.png	2026-06-03 14:12:25.638876+07	2026-06-03 14:20:32.656989+07
ORD-260601-785	2026-06-01	2	Calvin3c	082331339737	Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Kec.Klojen, Kota Malang	Kurir Toko Sinar Abadi	1903700	COMPLETED	Menunggu Validasi	t	http://localhost:8000/storage/proofs/GzNAWF9L87efBOTH1bATT1x5Ig2X9oyFaZwjjATc.png	2026-06-01 19:38:17.393072+07	2026-06-01 19:41:01.158241+07
ORD-260601-741	2026-06-01	2	Calvin3c	082331339737	Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Kec.Klojen, Kota Malang	Kurir Toko Sinar Abadi	238700	pending	Menunggu Validasi	t	http://localhost:8000/storage/proofs/Q5yg5fjel3k6uzDmBVMV2FKR1Z4nH2ylRAjwENnn.png	2026-06-01 19:43:12.074783+07	2026-06-01 19:43:12.111391+07
ORD-260603-437	2026-06-03	2	Calvin3c	082331339737	Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	Kurir Toko Sinar Abadi	521700	COMPLETED	Menunggu Validasi	t	http://localhost:8000/storage/proofs/uQ8KoF4yZAVZ074Tbw9BTJu8rA88kZIqsdGgdDdj.png	2026-06-03 13:56:18.757021+07	2026-06-03 13:57:48.554728+07
ORD-260401-081	2026-04-01	1	budi	081234567890	Jl. Merdeka, Malang	Kurir Toko Sinar Abadi	854700	cancelled	Selesai	t		2026-05-31 14:39:52.136779+07	2026-06-03 19:04:13.819173+07
ORD-260603-849	2026-06-03	2	Calvin3c	082331339737	Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	JNE JNE Trucking	1105800	cancelled	Kurir Sedang Dijadwalkan	t	http://localhost:8000/storage/proofs/SZ7s7lT1nwf9T7pzxuA0J4cohiMrZORsyz44NeUg.png	2026-06-03 18:32:25.600771+07	2026-06-03 19:00:47.889731+07
ORD-260603-971	2026-06-03	2	Calvin3c	082331339737	Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	JNE JNE Trucking	511750	COMPLETED	Kurir Sedang Dijadwalkan	t	http://localhost:8000/storage/proofs/lTkE5Soap4HesHJluk51LP26T6wCutLpWUSTw4wn.png	2026-06-03 19:30:22.983726+07	2026-06-03 20:33:21.555901+07
ORD-260603-503	2026-06-03	2	Calvin3c	+62 8123388670	Jalan Utara Masjid No.9, Dampit Wetan, Dampit, Kec. Dampit, Kabupaten Malang, Jawa Timur 65181	Ambil Di Toko	327450	COMPLETED	Menunggu Validasi	t	http://localhost:8000/storage/proofs/7VcClUpevFFYynYvr8tyKZodGIhjRt6WEUBEqMu5.png	2026-06-03 14:23:00.284299+07	2026-06-03 14:25:42.600166+07
ORD-260603-153	2026-06-03	2	Calvin3c	082331339737	Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	JNE	648870	cancelled	Menunggu Validasi	t	http://localhost:8000/storage/proofs/3nd94ZK3GM1uXlXTzXWv7w1P9cxSM6ta9bNEq4Lj.png	2026-06-03 14:07:54.030389+07	2026-06-03 19:02:02.237482+07
ORD-260603-721	2026-06-03	2	Calvin3c	082331339737	Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	JNE JNE Trucking	10377150	cancelled	Kurir Sedang Dijadwalkan	t	http://localhost:8000/storage/proofs/VnJTa1ydjT9wTOFf60t8SjXSmgDg1Duq8maWfbN3.png	2026-06-03 12:43:09.765501+07	2026-06-03 19:02:05.563297+07
ORD-260603-480	2026-06-03	2	Calvin3c	082331339737	Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	JNE JNE Trucking	684350	cancelled	Menunggu Validasi	t	http://localhost:8000/storage/proofs/kUrOjwp0OhjAqwJA2gmyEd9qJgDleMUm3U9Syqs0.png	2026-06-03 18:21:57.438075+07	2026-06-03 19:01:54.765004+07
ORD-260603-300	2026-06-03	2	Calvin3c	082331339737	Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	JNE JNE Trucking	1127250	cancelled	Menunggu Validasi	t	http://localhost:8000/storage/proofs/obtFex1hotjNCc0NkSmgkhz26XW1eFeyhVrsVDjc.png	2026-06-03 18:09:36.866011+07	2026-06-03 19:01:56.426173+07
ORD-260603-210	2026-06-03	2	Calvin3c	082331339737	Perumahan Ijen Nirwana Cluster Green River Blok C3 No 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	JNE JNE Trucking	829350	cancelled	Kurir Sedang Dijadwalkan	t	http://localhost:8000/storage/proofs/I3qCz3Exzv7KSqG7gNgNxcx20I3bKPHuOCxAtqYr.png	2026-06-03 18:42:25.491473+07	2026-06-03 18:58:17.948579+07
ORD-260603-941	2026-06-03	2	Calvin3c	082331339737	Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	JNE Reguler	341450	success	Kurir Sedang Dijadwalkan	t	http://localhost:8000/storage/proofs/UXNBmTKH1vNg5dbFJH56tvInJcOvWzgoRngX1VVB.png	2026-06-03 20:35:00.097887+07	2026-06-03 20:36:08.195473+07
ORD-260603-324	2026-06-03	2	Calvin3c	082331339737	Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	JNE JNE Trucking	367450	COMPLETED	Kurir Sedang Dijadwalkan	t	http://localhost:8000/storage/proofs/qntYPJLm6lLOQkPfiwbXgF31jdBD3KRdIlwVH780.png	2026-06-03 20:39:29.376263+07	2026-06-03 20:43:42.263298+07
ORD-260604-705	2026-06-04	2	Calvin3c	082331339737	Perumahan Nirwana Residence No.C3/11, Klojen, Malang, Jawa Timur. 65116	JNE Reguler	84700	cancelled	Kurir Sedang Dijadwalkan	t	http://localhost:8000/storage/proofs/qB0pxnt9JnvZ75FXGZHKq1wdD7QPg0KTrbgQ1ohh.png	2026-06-04 20:15:41.652405+07	2026-06-04 20:26:12.950921+07
ORD-260603-526	2026-06-03	2	Calvin3c	082331339737	Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	JNE	341450	SHIPPING	Kurir Sedang Dijadwalkan	t	http://localhost:8000/storage/proofs/A10LyA379zWOaIopzfCVcGY6YdYJqQfibyeR9k7q.png	2026-06-03 21:01:13.646391+07	2026-06-03 21:08:47.805066+07
ORD-260603-391	2026-06-03	2	Calvin3c	082331339737	Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	JNE	217700	success	Menunggu Validasi	t	http://localhost:8000/storage/proofs/pTKP2SMOl1YZEDqUHoxmL7CEtOOLsShi8SL2nfh7.png	2026-06-03 21:22:38.207669+07	2026-06-03 21:23:09.142237+07
ORD-260603-629	2026-06-03	2	Calvin3c	082331339737	Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	JNE	134350	pending	Menunggu Validasi	t	http://localhost:8000/storage/proofs/B9j5w6VXT4jAGxS4GvO5LNPpD6QFdL8VKwcwIsdn.png	2026-06-03 21:30:02.744526+07	2026-06-03 21:30:02.761375+07
ORD-260603-818	2026-06-03	2	Calvin3c	082331339737	Perumahan Nirwana Residence No.C3/11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	JNE	1254900	success	Menunggu Validasi	t	http://localhost:8000/storage/proofs/RICAipTTwaEtnh0NA4yEdvxWb50XxRH5xW92cvMJ.png	2026-06-03 21:33:29.824554+07	2026-06-03 21:34:47.351099+07
ORD-260604-871	2026-06-04	2	Calvin3c	082331339737	Perumahan Nirwana Residence No.C3/11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	SiCepat Cargo per kg with minimum 10 kg	2054900	cancelled	Kurir Sedang Dijadwalkan	t	http://localhost:8000/storage/proofs/VzeqjOqLybPjs3nZh0FR3YZN4Ggc2AYChR0SW47L.png	2026-06-04 19:02:01.163007+07	2026-06-04 19:13:24.193606+07
ORD-260604-224	2026-06-04	2	Calvin3c	082331339737	Perumahan Nirwana Residence No.C3/11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	SiCepat Cargo per kg with minimum 10 kg	1483950	cancelled	Kurir Sedang Dijadwalkan	t	http://localhost:8000/storage/proofs/3dEERsy0cjRmzwCdFfyHsguPz1w9yL9xnCEdg5dD.png	2026-06-04 18:13:00.957274+07	2026-06-04 19:32:35.307+07
ORD-260604-795	2026-06-04	2	Calvin3c	082331339737	Perumahan Nirwana Residence No.C3/11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	JNE Reguler	84700	cancelled	Menunggu Validasi	t	http://localhost:8000/storage/proofs/XEdESdzFMFDdm1UlqHwdmC5MCfODIgdZ6Q8f1C5f.png	2026-06-04 20:29:13.16172+07	2026-06-04 20:29:45.788679+07
ORD-260603-817	2026-06-03	2	Calvin3c	082331339737	Perumahan Nirwana Residence No.C3/11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	JNE JNE Trucking	1254900	COMPLETED	Kurir Sedang Dijadwalkan	t	http://localhost:8000/storage/proofs/oVqaSJw7gzzWxNp4FVri35cxbofdjamKjR3i4XCA.png	2026-06-03 21:38:19.442259+07	2026-06-03 21:57:30.158478+07
ORD-260604-787	2026-06-04	2	Calvin Alexander Sucipto	082331339737	Perumahan Nirwana Residence No.C3/11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	JNE JNE Trucking	644800	success	Kurir Sedang Dijadwalkan	t	http://localhost:8000/storage/proofs/3a1U1wk1PcrQ5cw2vKtp6nKyeIjubpxKLQhezRYu.png	2026-06-04 22:41:12.787118+07	2026-06-04 22:47:24.626379+07
ORD-260604-969	2026-06-04	2	Calvin3c	+62 8123388670	Jalan Utara Masjid No.9, Dampit Wetan, Dampit, Kec. Dampit, Kabupaten Malang, Jawa Timur 65181	Ambil Di Toko	77700	COMPLETED	Menunggu Validasi	t	http://localhost:8000/storage/proofs/4ImFpz2ARPD1Xkp3bSVXPjTdm8VKa9jDtGnw34ss.png	2026-06-04 20:32:14.766349+07	2026-06-04 20:34:02.6065+07
ORD-260604-204	2026-06-04	2	Calvin3c	082331339737	Perumahan Nirwana Residence No.C3/11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	SiCepat Cargo per kg with minimum 10 kg	3469650	COMPLETED	Kurir Sedang Dijadwalkan	t	http://localhost:8000/storage/proofs/TRX41UOMUOBdTL5QeAU2ipyBknRbKuDTxbU2Nid7.png	2026-06-04 19:51:34.408617+07	2026-06-04 20:00:11.806675+07
ORD-260605-558	2026-06-05	3	Christian Anthony Sucipto	+6282132148698	Perumahan Ijen Nirwana Blok C3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	SiCepat Cargo per kg with minimum 10 kg	2732000	COMPLETED	Kurir Sedang Dijadwalkan	t	http://localhost:8000/storage/proofs/naSY2OH6hFGM3bGTRl6yanZPr97r6nAyn3vA071D.png	2026-06-05 16:36:47.720974+07	2026-06-05 16:54:07.776833+07
ORD-260604-216	2026-06-04	2	Calvin Alexander Sucipto	082331339737	Perumahan Nirwana Residence No.C3/11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	JNE JNE Trucking	139900	cancelled	Kurir Sedang Dijadwalkan	t	http://localhost:8000/storage/proofs/tbpzlvWGzSyiIg5lSuFdNjZs5K781ofepDuHM2zO.png	2026-06-04 21:15:20.643802+07	2026-06-04 21:20:57.003455+07
ORD-260604-507	2026-06-04	2	Calvin3c	082331339737	Perumahan Nirwana Residence No.C3/11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	Kurir Toko Sinar Abadi	1332000	COMPLETED	Menunggu Validasi	t	http://localhost:8000/storage/proofs/I34zqzorYTUn7aAwM5qldUiWq1XzTtOhsMJpLUNW.png	2026-06-04 20:36:37.788674+07	2026-06-04 20:44:16.345137+07
ORD-260605-629	2026-06-05	2	Calvin Alexander Sucipto	082331339737	Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116	SiCepat Cargo per kg with minimum 10 kg	2732000	cancelled	Kurir Sedang Dijadwalkan	t	http://localhost:8000/storage/proofs/G0K2Cpw6e3Vsw9bQnriKT1bJr8JitER2rQI2duKG.png	2026-06-05 15:44:02.096292+07	2026-06-05 16:55:19.151188+07
ORD-260605-444	2026-06-05	2	Calvin Alexander Sucipto	082331339737	Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116	SiCepat Cargo per kg with minimum 10 kg	2054900	cancelled	Menunggu Validasi	t	http://localhost:8000/storage/proofs/wCIYmVDFsUKuKjdh6rgpShZycHvcMqnZCAF1IeIH.png	2026-06-05 20:25:48.686921+07	2026-06-05 20:27:51.902015+07
ORD-260605-340	2026-06-05	2	Calvin Alexander Sucipto	082331339737	Perumahan Nirwana Residence No.C3/11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	SiCepat Cargo per kg with minimum 10 kg	1921700	COMPLETED	Kurir Sedang Dijadwalkan	t	http://localhost:8000/storage/proofs/nqJ82PKxe8ew3oTNA6m6a0NmmYyKOmAMIGs6I76T.png	2026-06-05 10:25:25.563087+07	2026-06-05 10:38:17.083006+07
ORD-260605-505	2026-06-05	2	Calvin Alexander Sucipto	082331339737	Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116	SiCepat Cargo per kg with minimum 10 kg	2054900	COMPLETED	Kurir Sedang Dijadwalkan	t	http://localhost:8000/storage/proofs/T5i93Yhve7lD3vrz45ZzC6XedrfEMTvi3TPQj0eM.png	2026-06-05 20:31:16.24613+07	2026-06-05 20:41:27.654841+07
ORD-260605-636	2026-06-05	2	Calvin Alexander Sucipto	082331339737	Perumahan ijen nirwana cluster green river blokc3 no 11, Gambir, Jakarta Pusat, DKI Jakarta. 10110	Kurir Toko Sinar Abadi	327450	cancelled	Menunggu Validasi	t	http://localhost:8000/storage/proofs/I9B0Eyg6nvnqxjpBr7P13UZJCaJmyaj3uNxkmNQw.png	2026-06-05 22:09:03.377179+07	2026-06-05 22:16:25.710575+07
ORD-260605-729	2026-06-05	2	Calvin Alexander Sucipto	082331339737	Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116	JNE Reguler	334450	COMPLETED	Kurir Sedang Dijadwalkan	t	http://localhost:8000/storage/proofs/1sd3qCDO0zAFiO1EcrQHw1bec9zZ5BlgQQhVNRzC.png	2026-06-05 22:21:44.924195+07	2026-06-05 23:01:39.912029+07
ORD-260605-279	2026-06-05	2	Calvin Alexander Sucipto	082331339737	Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116	JNE Reguler	334450	success	Kurir Sedang Dijadwalkan	t	http://localhost:8000/storage/proofs/T2KCe31TMA1dNEQ1pBDUaT2XOFHt0ZakhbAolqBM.png	2026-06-05 22:59:15.51669+07	2026-06-05 23:02:32.33826+07
ORD-260605-300	2026-06-05	2	Calvin Alexander Sucipto	+62 8123388670	Jalan Utara Masjid No.9, Dampit Wetan, Dampit, Kec. Dampit, Kabupaten Malang, Jawa Timur 65181	Ambil Di Toko	111000	COMPLETED	Menunggu Validasi	t	http://localhost:8000/storage/proofs/WYuiUkxjCADHnPUMcqVdNAqGZe8bM7EooklPJYiJ.png	2026-06-05 23:06:56.935182+07	2026-06-05 23:07:51.079879+07
ORD-260606-731	2026-06-06	2	Calvin Alexander Sucipto	082331339737	Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	JNE Reguler	506750	success	Kurir Sedang Dijadwalkan	t	http://localhost:8000/storage/proofs/bEbcia4NPw0LLnWTxcfN6oWYLcg6e3ryDts4jSoW.png	2026-06-06 14:56:38.025216+07	2026-06-06 14:58:17.778049+07
ORD-260605-128	2026-06-05	2	Calvin Alexander Sucipto	+62 8123388670	Jalan Utara Masjid No.9, Dampit Wetan, Dampit, Kec. Dampit, Kabupaten Malang, Jawa Timur 65181	Ambil Di Toko	11100	COMPLETED	Menunggu Validasi	t	http://localhost:8000/storage/proofs/NoP6W1Y8KHlOfN3JlA9RUn99Y16QzGzIwRY5QcR2.png	2026-06-05 23:09:54.046139+07	2026-06-05 23:10:41.678875+07
ORD-260606-964	2026-06-06	2	Calvin Alexander Sucipto	082331339737	Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	JNE Reguler	284500	SHIPPING	Kurir Sedang Dijadwalkan	t	http://localhost:8000/storage/proofs/vDElCEBs6gpoPHVK3Dlxhg3b7QS2FlzowkxqJGOZ.png	2026-06-06 10:10:18.514186+07	2026-06-06 10:26:59.822853+07
ORD-260606-149	2026-06-06	2	Calvin Alexander Sucipto	082331339737	Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	SiCepat Cargo per kg with minimum 10 kg	405300	SHIPPING	Kurir Sedang Dijadwalkan	t	http://localhost:8000/storage/proofs/0Z2DahWjmwwcbKhdO1X1gzCmAHf2BeCsSTPmYHtb.png	2026-06-06 10:54:28.531067+07	2026-06-06 10:58:53.05103+07
\.


--
-- Data for Name: owners; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.owners (id, username, password, name, created_at, updated_at, email, phone) FROM stdin;
1	owner	$2a$10$AEqIKrMy2iNiIEpaa2f8Vu/RmlkzjnC2b63QHqTS2sj2mVYpBVJTS	Duvaltina Prihatini	2026-05-31 14:39:51.96124+07	2026-06-06 12:30:01.286589+07	prihatini.duvaltina@gmail.com	082132148699
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.payments (id, order_id, payment_method, amount_paid, payment_status, paid_at, created_at, updated_at) FROM stdin;
1	ORD-260531-793	Transfer Bank BCA	3707400	Pending	\N	2026-05-31 20:15:04.120787+07	2026-05-31 20:15:04.120787+07
2	ORD-260531-325	Transfer Bank BCA	1332000	Pending	\N	2026-05-31 21:02:38.610584+07	2026-05-31 21:02:38.610584+07
3	ORD-260601-785	Transfer Bank BCA	1903700	Pending	\N	2026-06-01 19:38:17.411193+07	2026-06-01 19:38:17.411193+07
4	ORD-260601-741	Transfer Bank BCA	238700	Pending	\N	2026-06-01 19:43:12.080496+07	2026-06-01 19:43:12.080496+07
5	ORD-260603-721	Transfer Bank BCA	10377150	Pending	\N	2026-06-03 12:43:09.775378+07	2026-06-03 12:43:09.775378+07
6	ORD-260603-541	Transfer Bank BCA	2243400	Pending	\N	2026-06-03 12:56:55.374804+07	2026-06-03 12:56:55.374804+07
7	ORD-260603-437	Transfer Bank BCA	521700	Pending	\N	2026-06-03 13:56:18.762306+07	2026-06-03 13:56:18.762306+07
8	ORD-260603-153	Transfer Bank BCA	648870	Pending	\N	2026-06-03 14:07:54.032978+07	2026-06-03 14:07:54.032978+07
9	ORD-260603-820	Transfer Bank BCA	1346040	Pending	\N	2026-06-03 14:12:25.640642+07	2026-06-03 14:12:25.640642+07
10	ORD-260603-503	Transfer Bank BCA	327450	Pending	\N	2026-06-03 14:23:00.286944+07	2026-06-03 14:23:00.286944+07
11	ORD-260603-731	Transfer Bank BCA	1332000	Pending	\N	2026-06-03 14:34:02.585738+07	2026-06-03 14:34:02.585738+07
12	ORD-260603-256	Transfer Bank BCA	1127250	Pending	\N	2026-06-03 18:02:28.566854+07	2026-06-03 18:02:28.566854+07
13	ORD-260603-300	Transfer Bank BCA	1127250	Pending	\N	2026-06-03 18:09:36.875732+07	2026-06-03 18:09:36.875732+07
14	ORD-260603-480	Transfer Bank BCA	684350	Pending	\N	2026-06-03 18:21:57.444871+07	2026-06-03 18:21:57.444871+07
15	ORD-260603-849	Transfer Bank BCA	1105800	Pending	\N	2026-06-03 18:32:25.606623+07	2026-06-03 18:32:25.606623+07
16	ORD-260603-210	Transfer Bank BCA	829350	Pending	\N	2026-06-03 18:42:25.494397+07	2026-06-03 18:42:25.494397+07
17	ORD-260603-971	Transfer Bank BCA	511750	Pending	\N	2026-06-03 19:30:22.985804+07	2026-06-03 19:30:22.985804+07
18	ORD-260603-941	Transfer Bank BCA	341450	Pending	\N	2026-06-03 20:35:00.103106+07	2026-06-03 20:35:00.103106+07
19	ORD-260603-324	Transfer Bank BCA	367450	Pending	\N	2026-06-03 20:39:29.377839+07	2026-06-03 20:39:29.377839+07
20	ORD-260603-526	Transfer Bank BCA	341450	Pending	\N	2026-06-03 21:01:13.649796+07	2026-06-03 21:01:13.649796+07
21	ORD-260603-391	Transfer Bank BCA	217700	Pending	\N	2026-06-03 21:22:38.219809+07	2026-06-03 21:22:38.219809+07
22	ORD-260603-629	Transfer Bank BCA	134350	Pending	\N	2026-06-03 21:30:02.746863+07	2026-06-03 21:30:02.746863+07
23	ORD-260603-818	Transfer Bank BCA	1254900	Pending	\N	2026-06-03 21:33:29.826314+07	2026-06-03 21:33:29.826314+07
24	ORD-260603-817	Transfer Bank BCA	1254900	Pending	\N	2026-06-03 21:38:19.444355+07	2026-06-03 21:38:19.444355+07
25	ORD-260604-224	Transfer Bank BCA	1483950	Pending	\N	2026-06-04 18:13:00.972294+07	2026-06-04 18:13:00.972294+07
26	ORD-260604-871	Transfer Bank BCA	2054900	Pending	\N	2026-06-04 19:02:01.176554+07	2026-06-04 19:02:01.176554+07
27	ORD-260604-204	Transfer Bank BCA	3469650	Pending	\N	2026-06-04 19:51:34.44507+07	2026-06-04 19:51:34.44507+07
28	ORD-260604-705	Transfer Bank BCA	84700	Pending	\N	2026-06-04 20:15:41.658065+07	2026-06-04 20:15:41.658065+07
29	ORD-260604-795	Transfer Bank BCA	84700	Pending	\N	2026-06-04 20:29:13.16945+07	2026-06-04 20:29:13.16945+07
30	ORD-260604-969	Transfer Bank BCA	77700	Pending	\N	2026-06-04 20:32:14.769862+07	2026-06-04 20:32:14.769862+07
31	ORD-260604-507	Transfer Bank BCA	1332000	Pending	\N	2026-06-04 20:36:37.792132+07	2026-06-04 20:36:37.792132+07
32	ORD-260604-216	Transfer Bank BCA	139900	Pending	\N	2026-06-04 21:15:20.65021+07	2026-06-04 21:15:20.65021+07
33	ORD-260604-787	Transfer Bank BCA	644800	Pending	\N	2026-06-04 22:41:12.81431+07	2026-06-04 22:41:12.81431+07
34	ORD-260605-340	Transfer Bank BCA	1921700	Pending	\N	2026-06-05 10:25:25.589989+07	2026-06-05 10:25:25.589989+07
35	ORD-260605-629	Transfer Bank BCA	2732000	Pending	\N	2026-06-05 15:44:02.118791+07	2026-06-05 15:44:02.118791+07
36	ORD-260605-558	Transfer Bank BCA	2732000	Pending	\N	2026-06-05 16:36:47.730693+07	2026-06-05 16:36:47.730693+07
37	ORD-260605-444	Transfer Bank BCA	2054900	Pending	\N	2026-06-05 20:25:48.74254+07	2026-06-05 20:25:48.74254+07
38	ORD-260605-505	Transfer Bank BCA	2054900	Pending	\N	2026-06-05 20:31:16.296801+07	2026-06-05 20:31:16.296801+07
39	ORD-260605-636	Transfer Bank BCA	327450	Pending	\N	2026-06-05 22:09:03.383326+07	2026-06-05 22:09:03.383326+07
40	ORD-260605-729	Transfer Bank BCA	334450	Pending	\N	2026-06-05 22:21:44.928387+07	2026-06-05 22:21:44.928387+07
41	ORD-260605-279	Transfer Bank BCA	334450	Pending	\N	2026-06-05 22:59:15.52052+07	2026-06-05 22:59:15.52052+07
42	ORD-260605-300	Transfer Bank BCA	111000	Pending	\N	2026-06-05 23:06:56.936577+07	2026-06-05 23:06:56.936577+07
43	ORD-260605-128	Transfer Bank BCA	11100	Pending	\N	2026-06-05 23:09:54.04878+07	2026-06-05 23:09:54.04878+07
44	ORD-260606-964	Transfer Bank BCA	284500	Pending	\N	2026-06-06 10:10:18.539629+07	2026-06-06 10:10:18.539629+07
45	ORD-260606-149	Transfer Bank BCA	405300	Pending	\N	2026-06-06 10:54:28.536584+07	2026-06-06 10:54:28.536584+07
46	ORD-260606-731	Transfer Bank BCA	506750	Pending	\N	2026-06-06 14:56:38.054393+07	2026-06-06 14:56:38.054393+07
\.


--
-- Data for Name: product_variants; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.product_variants (id, product_id, name, price, created_at, updated_at) FROM stdin;
1	P-075	Biru Muda	0	2026-06-04 22:34:31.511437+07	2026-06-04 22:34:31.511437+07
2	P-075	Merah Muda	0	2026-06-04 22:34:31.513113+07	2026-06-04 22:34:31.513113+07
3	P-075	Putih	0	2026-06-04 22:34:31.514292+07	2026-06-04 22:34:31.514292+07
4	P-075	Merah Maroon	295000	2026-06-04 22:34:31.515424+07	2026-06-04 22:34:31.515424+07
5	P-076	Biru Muda	0	2026-06-04 22:34:31.51599+07	2026-06-04 22:34:31.51599+07
6	P-076	Merah Muda	0	2026-06-04 22:34:31.516515+07	2026-06-04 22:34:31.516515+07
7	P-076	Putih	0	2026-06-04 22:34:31.517038+07	2026-06-04 22:34:31.517038+07
8	P-076	Merah Maroon	295000	2026-06-04 22:34:31.517555+07	2026-06-04 22:34:31.517555+07
9	P-077	Biru Muda	0	2026-06-04 22:34:31.518077+07	2026-06-04 22:34:31.518077+07
10	P-077	Merah Muda	0	2026-06-04 22:34:31.518077+07	2026-06-04 22:34:31.518077+07
11	P-077	Putih	0	2026-06-04 22:34:31.518624+07	2026-06-04 22:34:31.518624+07
12	P-077	Merah Maroon	225000	2026-06-04 22:34:31.519139+07	2026-06-04 22:34:31.519139+07
13	P-078	Biru Muda	0	2026-06-04 22:34:31.519139+07	2026-06-04 22:34:31.519139+07
14	P-078	Merah Muda	0	2026-06-04 22:34:31.519658+07	2026-06-04 22:34:31.519658+07
15	P-078	Putih	0	2026-06-04 22:34:31.520173+07	2026-06-04 22:34:31.520173+07
16	P-079	Biru Muda	0	2026-06-04 22:34:31.520173+07	2026-06-04 22:34:31.520173+07
17	P-079	Merah Muda	0	2026-06-04 22:34:31.520682+07	2026-06-04 22:34:31.520682+07
18	P-079	Putih	0	2026-06-04 22:34:31.521205+07	2026-06-04 22:34:31.521205+07
19	P-080	Biru Muda	0	2026-06-04 22:34:31.521205+07	2026-06-04 22:34:31.521205+07
20	P-080	Merah Muda	0	2026-06-04 22:34:31.521725+07	2026-06-04 22:34:31.521725+07
21	P-080	Putih	0	2026-06-04 22:34:31.522242+07	2026-06-04 22:34:31.522242+07
\.


--
-- Data for Name: products; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.products (id, category, name, price, sold, is_large, image_url, created_at, updated_at, brand, weight, unit, min_purchase, length, width, height) FROM stdin;
P-034	Perpipaan	Pipa Maspion 3 D	137000	0	f	http://localhost:8000/images/products/pipa_maspion_d.png	2026-05-31 14:39:51.999763+07	2026-06-04 18:57:11.588665+07	Maspion	4600	Batang	1	400	9	9
P-049	Perpipaan	Pipa Rucika 6 AW	775000	0	f	http://localhost:8000/images/products/pipa_rucika_aw.png	2026-05-31 14:39:52.011758+07	2026-06-04 18:57:11.596245+07	Rucika	26800	Batang	1	400	17	17
P-005	Semen	Semen Putih Panda 40 kg	65000	0	t	http://localhost:8000/storage/products/gLi6KnGcN2rXRKmlmN85p4exwlKvcVEWJ8N1oHip.jpg	2026-05-31 14:39:51.980982+07	2026-06-04 18:57:11.598412+07	Semen	40000	Sak	10	55	40	10
P-008	Semen	Semen Perekat Bata Ringan Eco 20 kg	65000	0	t	http://localhost:8000/storage/products/bic9BLkcAlKZZrOFiF865G3BG9q3SOUWa0a3CgWT.jpg	2026-05-31 14:39:51.983034+07	2026-06-04 18:57:11.598928+07	Semen	20000	Sak	10	45	30	10
P-004	Semen	Semen Putih Tiga Roda 40 kg	120000	70	t	http://localhost:8000/storage/products/cmGmj5IHrv0slwi2DMwbbMfCob96DvevrO9Oqaml.png	2026-05-31 14:39:51.979954+07	2026-06-05 16:55:19.134123+07	Tiga Roda	40000	Sak	10	55	40	10
P-106	Kuas Cat	Kuas Eterna 4 Inch	25000	10	f	http://localhost:8000/images/products/kuas_eterna.png	2026-05-31 14:39:52.114084+07	2026-06-06 10:10:18.484807+07	Eterna	80	Pcs	1	23	10	2
P-007	Semen	Semen Perekat Bata Ringan Drymix 20 kg	75000	0	t	http://localhost:8000/storage/products/S3NfbPKArpwQvhsrXID8v4r2Ogm230j98yu6mpEh.jpg	2026-05-31 14:39:51.982006+07	2026-06-04 18:57:11.598928+07	Semen	20000	Sak	10	45	30	10
P-006	Semen	Semen Sika Perekat Granit 20 kg	110000	0	t	http://localhost:8000/storage/products/3Y8x3QJVFEdbESNZzZxhpwDHpdQkn3FoqU1HaqCQ.jpg	2026-05-31 14:39:51.981494+07	2026-06-04 18:57:11.599448+07	Semen	20000	Sak	10	45	30	10
P-021	Perpipaan	Pipa Maspion 5/8 C	9000	0	f	http://localhost:8000/images/products/pipa_maspion_c.png	2026-05-31 14:39:51.991542+07	2026-06-04 21:20:56.984348+07	Maspion	900	Batang	1	400	2	2
P-002	Semen	Semen Merah Putih 40 kg	47000	113	t	http://localhost:8000/storage/products/ZYwrrTxO2wMc42tafedWKWp6VtVftC6pX15BptSo.webp	2026-05-31 14:39:51.977791+07	2026-06-05 10:25:25.534757+07	Merah Putih	40000	Sak	10	55	40	10
P-066	Cat Kayu	Emco Warna Bintang 0.5 kg	60000	0	f	http://localhost:8000/images/products/cat_emco.png	2026-05-31 14:39:52.025815+07	2026-06-04 18:57:11.480695+07	Lokal / Tanpa Merek	500	Pcs	1	10	10	10
P-131	Keramik & Granite	Keramik Lantai 60x60 cm	135000	0	t	http://localhost:8000/images/products/keramik_lantai.png	2026-05-31 14:39:52.130162+07	2026-06-04 18:57:11.512873+07	Lokal / Tanpa Merek	17000	Dus	1	60	60	1
P-137	Keramik & Granite	Granite Warna Gelap 60x60 cm	255000	0	t	http://localhost:8000/images/products/granite_tile.png	2026-05-31 14:39:52.134081+07	2026-06-04 18:57:11.513914+07	Lokal / Tanpa Merek	30000	Dus	1	60	60	1
P-115	Kunci Pintu	Kunci Pintu WanLi Kecil	75000	0	f	http://localhost:8000/images/products/kunci_pintu_wanli.png	2026-05-31 14:39:52.119212+07	2026-06-04 18:57:11.533011+07	WanLi	600	Buah	1	17	7	7
P-096	Listrik	Lampu Philips LED 5 Watt	25000	0	f	http://localhost:8000/storage/products/CvsUIVkxLIHqDAcZkQcm0vXE5veItAGlAEKeST2S.jpg	2026-05-31 14:39:52.092449+07	2026-06-04 18:57:11.53748+07	Philips	60	Buah	1	11	6	6
P-022	Perpipaan	Pipa Maspion 3/4 C	16000	0	f	http://localhost:8000/images/products/pipa_maspion_c.png	2026-05-31 14:39:51.992802+07	2026-06-04 18:57:11.5654+07	Maspion	1600	Batang	1	400	3	3
P-023	Perpipaan	Pipa Maspion 1 C	26000	0	f	http://localhost:8000/images/products/pipa_maspion_c.png	2026-05-31 14:39:51.993359+07	2026-06-04 18:57:11.566175+07	Maspion	2200	Batang	1	400	3	3
P-024	Perpipaan	Pipa Maspion 1 1/4 C	31000	0	f	http://localhost:8000/images/products/pipa_maspion_c.png	2026-05-31 14:39:51.993978+07	2026-06-04 18:57:11.567284+07	Maspion	3200	Batang	1	400	4	4
P-009	Perpipaan	Pipa Maspion 1/2 AW	35000	0	f	http://localhost:8000/images/products/pipa_maspion_aw.png	2026-05-31 14:39:51.983591+07	2026-06-04 18:57:11.568274+07	Maspion	1000	Batang	1	400	2	2
P-025	Perpipaan	Pipa Maspion 1 1/2 C	37000	0	f	http://localhost:8000/images/products/pipa_maspion_c.png	2026-05-31 14:39:51.994492+07	2026-06-04 18:57:11.572507+07	Maspion	4000	Batang	1	400	5	5
P-041	Perpipaan	Pipa Rucika 1 AW	55000	0	f	http://localhost:8000/images/products/pipa_rucika_aw.png	2026-05-31 14:39:52.003916+07	2026-06-04 18:57:11.579431+07	Rucika	1790	Batang	1	400	3	3
P-100	Listrik	Lampu Philips LED 13 Watt	49500	0	f	http://localhost:8000/storage/products/P7l7ELMT0OlnwsUqEkv61hdozBPbF9vDmnDuzval.jpg	2026-05-31 14:39:52.110341+07	2026-06-04 18:57:11.546102+07	Philips	100	Buah	1	13	7	7
P-061	Cat Kayu	Emco Warna Standart 1 kg	85000	19	f	http://localhost:8000/images/products/cat_emco.png	2026-05-31 14:39:52.020021+07	2026-06-06 14:56:38.017694+07	Emco	1000	Kaleng	1	12	12	13
P-053	Cat Tembok	Avitex 5 kg	155000	0	f	http://localhost:8000/images/products/cat_avitex.png	2026-05-31 14:39:52.015689+07	2026-06-04 18:57:11.494317+07	Avitex	5000	Galon	1	20	20	21
P-057	Cat Tembok	Aquaproof 4 kg	265000	0	f	http://localhost:8000/images/products/cat_aquaproof.png	2026-05-31 14:39:52.01783+07	2026-06-04 18:57:11.499407+07	Aquaproof	4000	Galon	1	20	20	21
P-060	Cat Tembok	Aries 20 kg	280000	0	f	http://localhost:8000/images/products/cat_aries.png	2026-05-31 14:39:52.01948+07	2026-06-04 18:57:11.500705+07	Cat Tembok	20000	Pail	1	32	32	38
P-058	Cat Tembok	Aquaproof 20 kg	1275000	0	f	http://localhost:8000/images/products/cat_aquaproof.png	2026-05-31 14:39:52.018376+07	2026-06-04 18:57:11.502805+07	Aquaproof	20000	Pail	1	32	32	38
P-054	Cat Tembok	Avitex 25 kg	775000	3	f	http://localhost:8000/images/products/cat_avitex.png	2026-05-31 14:39:52.016211+07	2026-06-04 18:57:11.50176+07	Avitex	25000	Pail	1	32	32	38
P-056	Cat Tembok	No. Drop 20 kg	1225000	0	f	http://localhost:8000/images/products/cat_nodrop.png	2026-05-31 14:39:52.017243+07	2026-06-04 18:57:11.502282+07	Cat Tembok	20000	Pail	1	32	32	38
P-084	Perkakas	Mesin Bor Modern M2130	395000	0	f	http://localhost:8000/images/products/P-084.png	2026-05-31 14:39:52.064272+07	2026-06-04 18:57:11.560096+07	Modern	3000	Unit	1	21	20	7
P-059	Cat Tembok	Aries 5 kg	70000	0	f	http://localhost:8000/images/products/cat_aries.png	2026-05-31 14:39:52.018943+07	2026-06-04 18:57:11.488621+07	Cat Tembok	5000	Galon	1	20	20	21
P-067	Cat Kayu	Avian 1 kg	85000	0	f	http://localhost:8000/images/products/cat_avian.png	2026-05-31 14:39:52.027204+07	2026-06-04 18:57:11.485202+07	Lokal / Tanpa Merek	1000	Galon	1	12	12	13
P-069	Besi Beton	Besi Beton 6 SNI	28000	10	t	http://localhost:8000/images/products/besi_beton.png	2026-05-31 14:39:52.029651+07	2026-06-06 10:54:28.527552+07	Lokal / Tanpa Merek	2660	Batang	1	1200	1	1
P-075	Kloset	Kloset Jongkok INA	210000	0	t	http://localhost:8000/images/products/kloset_jongkok.png	2026-05-31 14:39:52.034827+07	2026-06-04 18:57:11.526856+07	INA	25000	Buah	1	50	40	24
P-098	Listrik	Lampu Philips LED 9 Watt	35000	0	f	http://localhost:8000/storage/products/ZKSqy459MDsHotOFFmOwsUv4z6I4tZCQQGGmA4g3.webp	2026-05-31 14:39:52.108225+07	2026-06-04 18:57:11.540935+07	Philips	80	Buah	1	11	6	6
P-083	Perkakas	Mesin Bor Modern M2100	295000	6	f	http://localhost:8000/storage/products/GAzS5efr0iMSBQS1zfA57tiIcwjqoY2pB8KMBN2h.jpg	2026-05-31 14:39:52.062476+07	2026-06-05 22:59:15.513395+07	Modern	1300	Unit	1	25	22	7
P-051	Cat Tembok	Decolith 5 kg	145000	0	f	http://localhost:8000/images/products/cat_decolith.png	2026-05-31 14:39:52.013452+07	2026-06-04 18:57:11.49023+07	Decolith	5000	Galon	1	20	20	21
P-099	Listrik	Lampu Philips LED 11 Watt	42500	0	f	http://localhost:8000/storage/products/QA0BglgcAbqnH6UIsPPugwbzFb4CZAnFBt4Te9bx.jpg	2026-05-31 14:39:52.10964+07	2026-06-04 18:57:11.54361+07	Philips	100	Buah	1	13	7	7
P-081	Perkakas	Mesin Pasrah Modern M2900	495000	0	f	http://localhost:8000/storage/products/eiBlavf8EPRe0WrEvgmAJpth8PZzT6ZQLIDFoivw.jpg	2026-05-31 14:39:52.055069+07	2026-06-04 18:57:11.563094+07	Modern	3000	Unit	1	30	17	16
P-082	Perkakas	Mesin Pasrah Modern M2950	475000	0	f	http://localhost:8000/storage/products/YlWflsmlH8vx8FLfp1svFsdkVdd7jIUDpMGmiPzm.webp	2026-05-31 14:39:52.058216+07	2026-06-04 18:57:11.560603+07	Modern	4000	Unit	1	30	17	16
P-076	Kloset	Kloset Jongkok Triliun	205000	0	t	http://localhost:8000/images/products/kloset_jongkok.png	2026-05-31 14:39:52.036426+07	2026-06-04 18:57:11.525715+07	Triliun	25000	Buah	1	51	41	24
P-071	Besi Beton	Besi Beton 10 SNI	71000	0	t	http://localhost:8000/images/products/besi_beton.png	2026-05-31 14:39:52.030857+07	2026-06-04 18:57:11.470492+07	Lokal / Tanpa Merek	7400	Batang	1	1200	1	1
P-072	Besi Beton	Besi Beton 12 SNI	105000	0	t	http://localhost:8000/images/products/besi_beton.png	2026-05-31 14:39:52.031946+07	2026-06-04 18:57:11.471543+07	Lokal / Tanpa Merek	10660	Batang	1	1200	1	1
P-073	Besi Beton	Besi Beton 14 SNI	134000	0	t	http://localhost:8000/images/products/besi_beton.png	2026-05-31 14:39:52.033126+07	2026-06-04 18:57:11.472588+07	Lokal / Tanpa Merek	13500	Batang	1	1200	1	1
P-074	Besi Beton	Besi Beton 16 SNI	195000	45	t	http://localhost:8000/images/products/besi_beton.png	2026-05-31 14:39:52.034298+07	2026-06-04 19:51:34.406411+07	Lokal / Tanpa Merek	18960	Batang	1	1200	2	2
P-062	Cat Kayu	Emco Warna Standart 0.5 kg	47500	0	f	http://localhost:8000/images/products/cat_emco.png	2026-05-31 14:39:52.020583+07	2026-06-04 18:57:11.473631+07	Lokal / Tanpa Merek	500	Pcs	1	10	10	10
P-079	Kloset	Monoblok Triliun	1525000	0	t	http://localhost:8000/images/products/monoblok.png	2026-05-31 14:39:52.042023+07	2026-06-04 18:57:11.527379+07	Triliun	25000	Buah	1	65	37	75
P-087	Perkakas	Mesin Gergaji Modern M2600	625000	0	f	http://localhost:8000/images/products/P-087.png	2026-05-31 14:39:52.066418+07	2026-06-04 18:57:11.563615+07	Modern	5000	Unit	1	30	23	24
P-055	Cat Tembok	No. Drop 4 kg	245000	0	f	http://localhost:8000/images/products/cat_nodrop.png	2026-05-31 14:39:52.016722+07	2026-06-04 18:57:11.496909+07	Cat Tembok	4000	Galon	1	20	20	21
P-078	Kloset	Monoblok INA	1550000	0	t	http://localhost:8000/images/products/monoblok.png	2026-05-31 14:39:52.038121+07	2026-06-04 18:57:11.527901+07	INA	25000	Buah	1	69	40	79
P-080	Kloset	Monoblok Volk	1250000	0	t	http://localhost:8000/images/products/monoblok.png	2026-05-31 14:39:52.045146+07	2026-06-04 18:57:11.527379+07	Volk	25000	Buah	1	66	35	77
P-070	Besi Beton	Besi Beton 8 SNI	46000	0	t	http://localhost:8000/images/products/besi_beton.png	2026-05-31 14:39:52.030209+07	2026-06-04 18:57:11.469977+07	Lokal / Tanpa Merek	4740	Batang	1	1200	1	1
P-068	Cat Kayu	Avian 0.5 kg	47500	0	f	http://localhost:8000/images/products/cat_avian.png	2026-05-31 14:39:52.028496+07	2026-06-04 18:57:11.478692+07	Lokal / Tanpa Merek	500	Pcs	1	10	10	10
P-077	Kloset	Kloset Jongkok Duty	145000	1	t	http://localhost:8000/images/products/kloset_jongkok.png	2026-05-31 14:39:52.037042+07	2026-06-04 22:41:12.786565+07	Duty	25000	Buah	1	50	40	25
P-010	Perpipaan	Pipa Maspion 3/4 AW	42000	0	f	http://localhost:8000/images/products/pipa_maspion_aw.png	2026-05-31 14:39:51.984233+07	2026-06-04 18:57:11.573132+07	Maspion	1200	Batang	1	400	3	3
P-126	Engsel	Engsel Lemari Tipis 3 Inch	10000	0	f	http://localhost:8000/images/products/engsel_lemari.png	2026-05-31 14:39:52.127349+07	2026-06-04 18:57:11.504984+07	Lokal / Tanpa Merek	100	Buah	1	8	5	1
P-127	Engsel	Engsel Lemari Tipis 2.5 Inch	8000	0	f	http://localhost:8000/images/products/engsel_lemari.png	2026-05-31 14:39:52.127868+07	2026-06-04 18:57:11.504456+07	Lokal / Tanpa Merek	100	Buah	1	6	4	1
P-134	Keramik & Granite	Keramik Dinding 30x60 cm	90000	0	t	http://localhost:8000/images/products/keramik_dinding.png	2026-05-31 14:39:52.131875+07	2026-06-04 18:57:11.512351+07	Lokal / Tanpa Merek	16000	Dus	1	60	30	1
P-110	Kuas Cat	Kuas Roll 4 Inch	15000	0	f	http://localhost:8000/images/products/kuas_roll.png	2026-05-31 14:39:52.116373+07	2026-06-04 18:57:11.530167+07	Lokal / Tanpa Merek	1000	Pcs	1	30	10	5
P-119	Kunci Pintu	Kunci Pintu Kuda Kecil	95000	0	f	http://localhost:8000/images/products/kunci_pintu.png	2026-05-31 14:39:52.121969+07	2026-06-04 18:57:11.533541+07	Lokal / Tanpa Merek	600	Buah	1	20	13	7
P-124	Engsel	Engsel Pintu Nishio 4 Inch	35000	0	f	http://localhost:8000/images/products/engsel_pintu.png	2026-05-31 14:39:52.126219+07	2026-06-04 18:57:11.506029+07	Nishio	200	Buah	1	10	8	1
P-132	Keramik & Granite	Keramik Dinding 25x40 cm	65000	0	t	http://localhost:8000/images/products/keramik_dinding.png	2026-05-31 14:39:52.130712+07	2026-06-04 18:57:11.510267+07	Lokal / Tanpa Merek	16000	Dus	1	40	25	1
P-121	Engsel	Engsel Pintu Muller 4 Inch	75000	0	f	http://localhost:8000/images/products/engsel_pintu.png	2026-05-31 14:39:52.123095+07	2026-06-04 18:57:11.508119+07	Muller	200	Buah	1	10	8	1
P-109	Kuas Cat	Kuas Roll Eterna 9 Inch	30000	0	f	http://localhost:8000/images/products/kuas_roll.png	2026-05-31 14:39:52.115807+07	2026-06-04 18:57:11.531985+07	Eterna	1000	Pcs	1	33	23	7
P-114	Kunci Pintu	Kunci Pintu Zeona Tanggung	110000	0	f	http://localhost:8000/images/products/kunci_pintu_zeona.png	2026-05-31 14:39:52.118648+07	2026-06-04 18:57:11.533541+07	Zeona	800	Buah	1	24	14	8
P-136	Keramik & Granite	Granite Motif 60x60 cm	165000	0	t	http://localhost:8000/images/products/granite_tile.png	2026-05-31 14:39:52.133564+07	2026-06-04 18:57:11.513394+07	Lokal / Tanpa Merek	30000	Dus	1	60	60	1
P-135	Keramik & Granite	Granite Polos 60x60 cm	145000	0	t	http://localhost:8000/images/products/granite_tile.png	2026-05-31 14:39:52.132463+07	2026-06-04 18:57:11.512873+07	Lokal / Tanpa Merek	30000	Dus	1	60	60	1
P-129	Keramik & Granite	Keramik Lantai 40x40 cm	55000	0	t	http://localhost:8000/images/products/keramik_lantai.png	2026-05-31 14:39:52.129018+07	2026-06-04 18:57:11.50973+07	Lokal / Tanpa Merek	17000	Dus	1	40	40	1
P-013	Perpipaan	Pipa Maspion 1 1/2 AW	98000	0	f	http://localhost:8000/images/products/pipa_maspion_aw.png	2026-05-31 14:39:51.985925+07	2026-06-04 18:57:11.587561+07	Maspion	3100	Batang	1	400	5	5
P-111	Kuas Cat	Kuas Roll Imundex 9 Inch	30000	0	f	http://localhost:8000/images/products/kuas_roll_imundex.png	2026-05-31 14:39:52.116944+07	2026-06-04 18:57:11.531985+07	Imundex	1000	Pcs	1	33	23	7
P-011	Perpipaan	Pipa Maspion 1 AW	56000	0	f	http://localhost:8000/images/products/pipa_maspion_aw.png	2026-05-31 14:39:51.984831+07	2026-06-04 18:57:11.579935+07	Maspion	1800	Batang	1	400	3	3
P-112	Kuas Cat	Kuas Roll Imundex 7 Inch	25000	0	f	http://localhost:8000/images/products/kuas_roll_imundex.png	2026-05-31 14:39:52.117502+07	2026-06-04 18:57:11.531415+07	Imundex	1000	Pcs	1	30	18	6
P-133	Keramik & Granite	Keramik Dinding 25x50 cm	75000	0	t	http://localhost:8000/images/products/keramik_dinding.png	2026-05-31 14:39:52.131302+07	2026-06-04 18:57:11.511819+07	Lokal / Tanpa Merek	16000	Dus	1	50	25	1
P-012	Perpipaan	Pipa Maspion 1 1/4 AW	74000	0	f	http://localhost:8000/images/products/pipa_maspion_aw.png	2026-05-31 14:39:51.985415+07	2026-06-04 18:57:11.584516+07	Maspion	2400	Batang	1	400	4	4
P-123	Engsel	Engsel Pintu Nishio 5 Inch	45000	0	f	http://localhost:8000/images/products/engsel_pintu.png	2026-05-31 14:39:52.12514+07	2026-06-04 18:57:11.506545+07	Nishio	300	Buah	1	13	8	1
P-014	Perpipaan	Pipa Maspion 2 AW	138000	0	f	http://localhost:8000/images/products/pipa_maspion_aw.png	2026-05-31 14:39:51.986459+07	2026-06-04 18:57:11.589208+07	Maspion	4500	Batang	1	400	6	6
P-125	Engsel	Engsel Pintu Nishio 3 Inch	20000	0	f	http://localhost:8000/images/products/engsel_pintu.png	2026-05-31 14:39:52.126761+07	2026-06-04 18:57:11.505504+07	Nishio	100	Buah	1	8	6	1
P-118	Kunci Pintu	Kunci Pintu Kuda Besar	125000	0	f	http://localhost:8000/images/products/kunci_pintu.png	2026-05-31 14:39:52.120818+07	2026-06-04 18:57:11.534071+07	Lokal / Tanpa Merek	1000	Buah	1	26	15	8
P-113	Kunci Pintu	Kunci Pintu Zeona Besar	175000	0	f	http://localhost:8000/images/products/kunci_pintu_zeona.png	2026-05-31 14:39:52.118099+07	2026-06-04 18:57:11.535626+07	Zeona	1000	Buah	1	26	15	8
P-117	Kunci Pintu	Kunci Pintu Muller Tanggung	245000	0	f	http://localhost:8000/images/products/kunci_pintu_muller.png	2026-05-31 14:39:52.120308+07	2026-06-04 18:57:11.536144+07	Muller	800	Buah	1	24	14	8
P-015	Perpipaan	Pipa Maspion 2 1/2 AW	185000	0	f	http://localhost:8000/images/products/pipa_maspion_aw.png	2026-05-31 14:39:51.987042+07	2026-06-04 18:57:11.589733+07	Maspion	5700	Batang	1	400	8	8
P-001	Semen	Semen Gresik 40 kg	59000	60	t	http://localhost:8000/storage/products/fAJGAgbmYmDrLyWexmBWKeoTnHLg7UB8d8Dsw8IA.jpg	2026-05-31 14:39:51.972869+07	2026-06-05 20:31:16.224736+07	Semen Gresik	40000	Sak	10	55	40	10
P-116	Kunci Pintu	Kunci Pintu Muller Besar	325000	0	f	http://localhost:8000/images/products/kunci_pintu_muller.png	2026-05-31 14:39:52.11976+07	2026-06-04 18:57:11.536775+07	Muller	1000	Buah	1	30	16	9
P-120	Engsel	Engsel Pintu Muller 5 Inch	95000	0	f	http://localhost:8000/images/products/engsel_pintu.png	2026-05-31 14:39:52.122497+07	2026-06-04 18:57:11.508642+07	Muller	300	Buah	1	13	8	1
P-130	Keramik & Granite	Keramik Lantai 50x50 cm	65000	0	t	http://localhost:8000/images/products/keramik_lantai.png	2026-05-31 14:39:52.129583+07	2026-06-04 18:57:11.511297+07	Lokal / Tanpa Merek	17000	Dus	1	50	50	1
P-128	Engsel	Engsel Lemari Tipis 2 Inch	7000	0	f	http://localhost:8000/images/products/engsel_lemari.png	2026-05-31 14:39:52.128423+07	2026-06-04 18:57:11.50333+07	Lokal / Tanpa Merek	100	Buah	1	5	4	1
P-003	Semen	Semen Singa Merah 40 kg	45000	0	t	http://localhost:8000/storage/products/TQMhtGWD7ZCbL8BRjLbSqdxcKXCUpHdM4LmrcHAa.jpg	2026-05-31 14:39:51.978921+07	2026-06-04 18:57:11.597367+07	Semen	40000	Sak	10	55	40	10
P-122	Engsel	Engsel Pintu Muller 3 Inch	45000	0	f	http://localhost:8000/images/products/engsel_pintu.png	2026-05-31 14:39:52.123625+07	2026-06-04 18:57:11.507068+07	Muller	100	Buah	1	8	6	1
P-048	Perpipaan	Pipa Rucika 5 AW	595000	0	f	http://localhost:8000/images/products/pipa_rucika_aw.png	2026-05-31 14:39:52.011244+07	2026-06-04 18:57:11.595726+07	Rucika	17850	Batang	1	400	14	14
P-044	Perpipaan	Pipa Rucika 2 AW	128000	0	f	http://localhost:8000/images/products/pipa_rucika_aw.png	2026-05-31 14:39:52.006316+07	2026-06-04 18:57:11.588665+07	Rucika	4490	Batang	1	400	6	6
P-035	Perpipaan	Pipa Maspion 4 D	189000	0	f	http://localhost:8000/images/products/pipa_maspion_d.png	2026-05-31 14:39:52.000348+07	2026-06-04 18:57:11.590245+07	Maspion	7000	Batang	1	400	11	11
P-108	Kuas Cat	Kuas Eterna 6 Inch	35000	0	f	http://localhost:8000/images/products/kuas_eterna.png	2026-05-31 14:39:52.115245+07	2026-06-04 18:57:11.532506+07	Eterna	80	Pcs	1	25	15	2
P-017	Perpipaan	Pipa Maspion 4 AW	385000	0	f	http://localhost:8000/images/products/pipa_maspion_aw.png	2026-05-31 14:39:51.98871+07	2026-06-04 18:57:11.593451+07	Maspion	13600	Batang	1	400	11	11
P-065	Cat Kayu	Emco Warna Bintang 1 kg	102000	0	f	http://localhost:8000/images/products/cat_emco.png	2026-05-31 14:39:52.02355+07	2026-06-04 18:57:11.488114+07	Lokal / Tanpa Merek	1000	Galon	1	12	12	13
P-063	Cat Kayu	Emco Warna Gunung 1 kg	95000	0	f	http://localhost:8000/images/products/cat_emco.png	2026-05-31 14:39:52.021619+07	2026-06-04 18:57:11.487083+07	Lokal / Tanpa Merek	1000	Galon	1	12	12	13
P-052	Cat Tembok	Decolith 25 kg	725000	0	f	http://localhost:8000/images/products/cat_decolith.png	2026-05-31 14:39:52.015031+07	2026-06-04 18:57:11.50123+07	Decolith	25000	Pail	1	32	32	38
P-016	Perpipaan	Pipa Maspion 3 AW	255000	0	f	http://localhost:8000/images/products/pipa_maspion_aw.png	2026-05-31 14:39:51.987616+07	2026-06-04 18:57:11.590245+07	Maspion	8800	Batang	1	400	9	9
P-029	Perpipaan	Pipa Maspion 4 C	102000	0	f	http://localhost:8000/images/products/pipa_maspion_c.png	2026-05-31 14:39:51.996827+07	2026-06-04 18:57:11.588074+07	Maspion	13200	Batang	1	400	11	11
P-085	Perkakas	Mesin Gerinda Modern M2350	325000	0	f	http://localhost:8000/images/products/P-085.png	2026-05-31 14:39:52.065288+07	2026-06-04 18:57:11.558887+07	Modern	2000	Unit	1	30	12	11
P-026	Perpipaan	Pipa Maspion 2 C	58000	0	f	http://localhost:8000/images/products/pipa_maspion_c.png	2026-05-31 14:39:51.995067+07	2026-06-04 18:57:11.581666+07	Maspion	5200	Batang	1	400	6	6
P-101	Kuas Cat	Kuas Eterna 1 Inch	7000	20	f	http://localhost:8000/images/products/kuas_eterna.png	2026-05-31 14:39:52.111384+07	2026-06-04 20:32:14.764098+07	Eterna	60	Pcs	1	18	3	1
P-039	Perpipaan	Pipa Rucika 1/2 AW	32000	0	f	http://localhost:8000/images/products/pipa_rucika_aw.png	2026-05-31 14:39:52.002734+07	2026-06-04 18:57:11.567771+07	Rucika	1020	Batang	1	400	2	2
P-018	Perpipaan	Pipa Maspion 5 AW	575000	0	f	http://localhost:8000/images/products/pipa_maspion_aw.png	2026-05-31 14:39:51.989223+07	2026-06-04 18:57:11.595219+07	Maspion	17800	Batang	1	400	14	14
P-064	Cat Kayu	Emco Warna Gunung 0.5 kg	55000	0	f	http://localhost:8000/images/products/cat_emco.png	2026-05-31 14:39:52.022136+07	2026-06-04 18:57:11.480695+07	Lokal / Tanpa Merek	500	Pcs	1	10	10	10
P-107	Kuas Cat	Kuas Eterna 5 Inch	30000	0	f	http://localhost:8000/images/products/kuas_eterna.png	2026-05-31 14:39:52.114666+07	2026-06-04 18:57:11.531415+07	Eterna	80	Pcs	1	24	13	2
P-045	Perpipaan	Pipa Rucika 2 1/2 AW	175000	0	f	http://localhost:8000/images/products/pipa_rucika_aw.png	2026-05-31 14:39:52.006858+07	2026-06-04 18:57:11.589733+07	Rucika	5780	Batang	1	400	8	8
P-040	Perpipaan	Pipa Rucika 3/4 AW	42000	0	f	http://localhost:8000/images/products/pipa_rucika_aw.png	2026-05-31 14:39:52.003304+07	2026-06-04 18:57:11.5745+07	Rucika	1240	Batang	1	400	3	3
P-046	Perpipaan	Pipa Rucika 3 AW	255000	0	f	http://localhost:8000/images/products/pipa_rucika_aw.png	2026-05-31 14:39:52.00907+07	2026-06-04 18:57:11.590793+07	Rucika	8810	Batang	1	400	9	9
P-105	Kuas Cat	Kuas Eterna 3 Inch	18000	0	f	http://localhost:8000/images/products/kuas_eterna.png	2026-05-31 14:39:52.113546+07	2026-06-04 18:57:11.530167+07	Eterna	80	Pcs	1	22	8	1
P-027	Perpipaan	Pipa Maspion 2 1/2 C	69000	0	f	http://localhost:8000/images/products/pipa_maspion_c.png	2026-05-31 14:39:51.995666+07	2026-06-04 18:57:11.583329+07	Maspion	6500	Batang	1	400	8	8
P-104	Kuas Cat	Kuas Eterna 2.5 Inch	15000	0	f	http://localhost:8000/images/products/kuas_eterna.png	2026-05-31 14:39:52.11295+07	2026-06-04 18:57:11.529661+07	Eterna	60	Pcs	1	21	6	1
P-030	Perpipaan	Pipa Maspion 1 1/4 D	45000	0	f	http://localhost:8000/images/products/pipa_maspion_d.png	2026-05-31 14:39:51.997445+07	2026-06-04 18:57:11.577052+07	Maspion	1200	Batang	1	400	4	4
P-036	Perpipaan	Pipa Maspion 5 D	320000	0	f	http://localhost:8000/images/products/pipa_maspion_d.png	2026-05-31 14:39:52.000977+07	2026-06-04 18:57:11.591386+07	Maspion	10900	Batang	1	400	14	14
P-032	Perpipaan	Pipa Maspion 2 D	68000	0	f	http://localhost:8000/images/products/pipa_maspion_d.png	2026-05-31 14:39:51.998573+07	2026-06-04 18:57:11.582712+07	Maspion	2100	Batang	1	400	6	6
P-020	Perpipaan	Pipa Maspion 8 AW	1275000	0	f	http://localhost:8000/images/products/pipa_maspion_aw.png	2026-05-31 14:39:51.990424+07	2026-06-04 18:57:11.59679+07	Maspion	40500	Batang	1	400	22	22
P-103	Kuas Cat	Kuas Eterna 2 Inch	12000	0	f	http://localhost:8000/images/products/kuas_eterna.png	2026-05-31 14:39:52.112428+07	2026-06-04 18:57:11.528924+07	Eterna	60	Pcs	1	20	5	1
P-033	Perpipaan	Pipa Maspion 2 1/2 D	98000	0	f	http://localhost:8000/images/products/pipa_maspion_d.png	2026-05-31 14:39:51.999155+07	2026-06-04 18:57:11.587561+07	Maspion	3300	Batang	1	400	8	8
P-038	Perpipaan	Pipa Maspion 8 D	730000	0	f	http://localhost:8000/images/products/pipa_maspion_d.png	2026-05-31 14:39:52.002145+07	2026-06-04 18:57:11.595726+07	Maspion	25000	Batang	1	400	22	22
P-050	Perpipaan	Pipa Rucika 8 AW	1325000	0	f	http://localhost:8000/images/products/pipa_rucika_aw.png	2026-05-31 14:39:52.01237+07	2026-06-04 18:57:11.59679+07	Rucika	40500	Batang	1	400	22	22
P-028	Perpipaan	Pipa Maspion 3 C	79000	0	f	http://localhost:8000/images/products/pipa_maspion_c.png	2026-05-31 14:39:51.996273+07	2026-06-04 18:57:11.586255+07	Maspion	8000	Batang	1	400	9	9
P-102	Kuas Cat	Kuas Eterna 1.5 Inch	10000	11	f	http://localhost:8000/images/products/kuas_eterna.png	2026-05-31 14:39:52.1119+07	2026-06-05 23:09:54.044499+07	Eterna	60	Pcs	1	19	4	1
P-043	Perpipaan	Pipa Rucika 1 1/2 AW	92000	0	f	http://localhost:8000/images/products/pipa_rucika_aw.png	2026-05-31 14:39:52.005098+07	2026-06-04 18:57:11.587014+07	Rucika	3160	Batang	1	400	5	5
P-031	Perpipaan	Pipa Maspion 1 1/2 D	55000	0	f	http://localhost:8000/images/products/pipa_maspion_d.png	2026-05-31 14:39:51.997991+07	2026-06-04 18:57:11.577805+07	Maspion	1700	Batang	1	400	5	5
P-097	Listrik	Lampu Philips LED 7 Watt	29000	0	f	http://localhost:8000/storage/products/j4dV3hjEHL1p38w8hM6bkrdAhteqBJ4EW5TT6I3N.webp	2026-05-31 14:39:52.102459+07	2026-06-04 18:57:11.538508+07	Philips	80	Buah	1	11	6	6
P-088	Perkakas	Meteran Tukang 3 m	25000	0	f	http://localhost:8000/images/products/meteran_tukang.png	2026-05-31 14:39:52.066933+07	2026-06-04 18:57:11.546709+07	Perkakas	150	Unit	1	7	7	3
P-094	Perkakas	Palu Tukang Kotak 200 gram	35000	0	f	http://localhost:8000/images/products/palu_kotak.png	2026-05-31 14:39:52.07218+07	2026-06-04 18:57:11.549193+07	Perkakas	200	Unit	1	28	10	3
P-089	Perkakas	Meteran Tukang 5 m	35000	0	f	http://localhost:8000/images/products/meteran_tukang.png	2026-05-31 14:39:52.067495+07	2026-06-04 18:57:11.549695+07	Perkakas	300	Unit	1	8	8	4
P-092	Perkakas	Palu Tukang Supit 8 oz	35000	0	f	http://localhost:8000/images/products/palu_supit.png	2026-05-31 14:39:52.069156+07	2026-06-04 18:57:11.55044+07	Perkakas	250	Unit	1	28	10	3
P-095	Perkakas	Palu Tukang Kotak 300 gram	45000	0	f	http://localhost:8000/images/products/palu_kotak.png	2026-05-31 14:39:52.083282+07	2026-06-04 18:57:11.55114+07	Perkakas	300	Unit	1	30	11	3
P-093	Perkakas	Palu Tukang Supit 12 oz	45000	0	f	http://localhost:8000/images/products/palu_supit.png	2026-05-31 14:39:52.069677+07	2026-06-04 18:57:11.552942+07	Perkakas	350	Unit	1	32	12	3
P-090	Perkakas	Meteran Tukang 7.5 m	55000	0	f	http://localhost:8000/images/products/meteran_tukang.png	2026-05-31 14:39:52.068033+07	2026-06-04 18:57:11.554015+07	Perkakas	300	Unit	1	9	9	4
P-091	Perkakas	Meteran Tukang 10 m	55000	0	f	http://localhost:8000/images/products/meteran_tukang.png	2026-05-31 14:39:52.068589+07	2026-06-04 18:57:11.554561+07	Perkakas	600	Unit	1	10	10	5
P-086	Perkakas	Mesin Profil Modern M2700	425000	0	f	http://localhost:8000/images/products/P-086.png	2026-05-31 14:39:52.065829+07	2026-06-04 18:57:11.560603+07	Modern	2800	Unit	1	20	15	20
P-042	Perpipaan	Pipa Rucika 1 1/4 AW	74000	0	f	http://localhost:8000/images/products/pipa_rucika_aw.png	2026-05-31 14:39:52.004529+07	2026-06-04 18:57:11.585752+07	Rucika	2420	Batang	1	400	4	4
P-047	Perpipaan	Pipa Rucika 4 AW	385000	0	f	http://localhost:8000/images/products/pipa_rucika_aw.png	2026-05-31 14:39:52.010145+07	2026-06-04 18:57:11.592946+07	Rucika	13630	Batang	1	400	11	11
P-037	Perpipaan	Pipa Maspion 6 D	410000	0	f	http://localhost:8000/images/products/pipa_maspion_d.png	2026-05-31 14:39:52.001548+07	2026-06-04 18:57:11.594702+07	Maspion	15700	Batang	1	400	17	17
P-019	Perpipaan	Pipa Maspion 6 AW	765000	0	f	http://localhost:8000/images/products/pipa_maspion_aw.png	2026-05-31 14:39:51.989822+07	2026-06-04 18:57:11.596245+07	Maspion	26800	Batang	1	400	17	17
\.


--
-- Data for Name: shippings; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.shippings (id, order_id, shipping_method_id, shipping_method_name, tracking_number, shipping_cost, destination_address, created_at, updated_at, biteship_area_id, biteship_order_id, waybill_id, courier_company, courier_type, courier_code, courier_service_code) FROM stdin;
1	ORD-260531-793	0	Ambil Di Toko	+62 8123388670	0	Jalan Utara Masjid No.9, Dampit Wetan, Dampit, Kec. Dampit, Kabupaten Malang, Jawa Timur 65181	2026-05-31 20:15:04.117735+07	2026-05-31 20:15:04.117735+07	\N	\N	\N	\N	\N	\N	\N
2	ORD-260531-325	0	Ambil Di Toko	+62 8123388670	0	Jalan Utara Masjid No.9, Dampit Wetan, Dampit, Kec. Dampit, Kabupaten Malang, Jawa Timur 65181	2026-05-31 21:02:38.608987+07	2026-05-31 21:02:38.608987+07	\N	\N	\N	\N	\N	\N	\N
3	ORD-260601-785	0	Kurir Toko Sinar Abadi	082331339737	50000	Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Kec.Klojen, Kota Malang	2026-06-01 19:38:17.40838+07	2026-06-01 19:38:17.40838+07	\N	\N	\N	\N	\N	\N	\N
4	ORD-260601-741	0	Kurir Toko Sinar Abadi	082331339737	50000	Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Kec.Klojen, Kota Malang	2026-06-01 19:43:12.079096+07	2026-06-01 19:43:12.079096+07	\N	\N	\N	\N	\N	\N	\N
6	ORD-260603-541	0	JNE JNE Trucking	082331339737	1200000	Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	2026-06-03 12:56:55.373742+07	2026-06-03 13:04:20.398524+07	IDNP11IDNC250IDND2615IDZ65116	6a1fc3e4cbc65424d57325cf	WYB-1780466660482	\N	\N	\N	\N
7	ORD-260603-437	0	Kurir Toko Sinar Abadi	082331339737	0	Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	2026-06-03 13:56:18.760667+07	2026-06-03 13:56:18.760667+07	IDNP11IDNC250IDND2615IDZ65116			\N	\N	\N	\N
9	ORD-260603-820	0	JNE JNE Trucking	082331339737	720000	Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	2026-06-03 14:12:25.640116+07	2026-06-03 14:12:50.919082+07	IDNP11IDNC250IDND2615IDZ65116	6a1fd3f2023c6a44c4aba971	WYB-1780470770989	\N	\N	\N	\N
10	ORD-260603-503	0	Ambil Di Toko	+62 8123388670	0	Jalan Utara Masjid No.9, Dampit Wetan, Dampit, Kec. Dampit, Kabupaten Malang, Jawa Timur 65181	2026-06-03 14:23:00.285802+07	2026-06-03 14:23:00.285802+07				\N	\N	\N	\N
11	ORD-260603-731	0	Kurir Toko Sinar Abadi	082331339737	0	Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	2026-06-03 14:34:02.584727+07	2026-06-03 14:34:02.584727+07	IDNP11IDNC250IDND2615IDZ65116			\N	\N	\N	\N
20	ORD-260603-526	0	JNE	082331339737	14000	Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	2026-06-03 21:01:13.648671+07	2026-06-03 21:02:10.046842+07	IDNP11IDNC250IDND2615IDZ65116	TEST-ORDER-ID-210210	TEST-WAYBILL-ID	\N	\N	\N	\N
17	ORD-260603-971	0	JNE JNE Trucking	082331339737	40000	Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	2026-06-03 19:30:22.984957+07	2026-06-03 19:31:05.800237+07	IDNP11IDNC250IDND2615IDZ65116	6a201e89b039b955b610526d	WYB-1780489865951	\N	\N	\N	\N
19	ORD-260603-324	0	JNE JNE Trucking	082331339737	40000	Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	2026-06-03 20:39:29.377323+07	2026-06-03 20:39:59.273208+07	IDNP11IDNC250IDND2615IDZ65116	6a202eafb494767c15e4a51a	WYB-1780493999199	\N	\N	\N	\N
18	ORD-260603-941	0	JNE Reguler	082331339737	14000	Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	2026-06-03 20:35:00.101123+07	2026-06-03 20:36:08.19402+07	IDNP11IDNC250IDND2615IDZ65116	TEST-ORDER-ID-203608	TEST-WAYBILL-ID	\N	\N	\N	\N
16	ORD-260603-210	0	JNE JNE Trucking	082331339737	180000	Perumahan Ijen Nirwana Cluster Green River Blok C3 No 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	2026-06-03 18:42:25.493049+07	2026-06-03 18:43:01.259918+07	IDNP11IDNC250IDND2615IDZ65116	6a201345fc5a3062a06561a1	WYB-1780486981486	\N	\N	\N	\N
15	ORD-260603-849	0	JNE JNE Trucking	082331339737	240000	Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	2026-06-03 18:32:25.604474+07	2026-06-03 18:33:03.467064+07	IDNP11IDNC250IDND2615IDZ65116	6a2010efb49476dde6e404f4	WYB-1780486383638	\N	\N	\N	\N
14	ORD-260603-480	0	JNE JNE Trucking	082331339737	35000	Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	2026-06-03 18:21:57.442688+07	2026-06-03 18:30:28.357701+07	IDNP11IDNC250IDND2600IDZ65116			\N	\N	\N	\N
13	ORD-260603-300	0	JNE JNE Trucking	082331339737	45000	Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	2026-06-03 18:09:36.873266+07	2026-06-03 18:30:28.356221+07	IDNP11IDNC250IDND2600IDZ65116			\N	\N	\N	\N
12	ORD-260603-256	0	JNE JNE Trucking	082331339737	45000	Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	2026-06-03 18:02:28.564516+07	2026-06-03 18:30:28.353979+07	IDNP11IDNC250IDND2600IDZ65116			\N	\N	\N	\N
8	ORD-260603-153	0	JNE	082331339737	75000	Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	2026-06-03 14:07:54.031833+07	2026-06-03 18:30:28.34964+07	IDNP11IDNC250IDND2600IDZ65116			\N	\N	\N	\N
5	ORD-260603-721	0	JNE JNE Trucking	082331339737	2424000	Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	2026-06-03 12:43:09.772773+07	2026-06-03 12:52:25.47935+07	IDNP11IDNC250IDND2615IDZ65116	TEST-ORDER-ID-12345	TEST-WAYBILL-ID	\N	\N	\N	\N
23	ORD-260603-818	0	JNE	082331339737	600000	Perumahan Nirwana Residence No.C3/11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	2026-06-03 21:33:29.825719+07	2026-06-03 21:33:29.825719+07	IDNP11IDNC250IDND2615IDZ65116					\N	\N
21	ORD-260603-391	0	JNE	082331339737	140000	Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	2026-06-03 21:22:38.218653+07	2026-06-03 21:22:38.218653+07	IDNP11IDNC250IDND2615IDZ65116					\N	\N
22	ORD-260603-629	0	JNE	082331339737	40000	Jl. Ijen Nirwana Residence No.C3/11, Bareng, Kec. Klojen, Kota Malang, Jawa Timur 65116, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	2026-06-03 21:30:02.74633+07	2026-06-03 21:30:02.74633+07	IDNP11IDNC250IDND2615IDZ65116					\N	\N
24	ORD-260603-817	0	JNE JNE Trucking	082331339737	600000	Perumahan Nirwana Residence No.C3/11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	2026-06-03 21:38:19.443334+07	2026-06-03 21:38:55.613714+07	IDNP11IDNC250IDND2615IDZ65116	6a203c7f3c6b1eb4c5464713	WYB-1780497535260			\N	\N
25	ORD-260604-224	0	SiCepat Cargo per kg with minimum 10 kg	082331339737	546000	Perumahan Nirwana Residence No.C3/11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	2026-06-04 18:13:00.970167+07	2026-06-04 18:13:48.698943+07	IDNP11IDNC250IDND2615IDZ65116	6a215dede2940a2ed4bd75ff	WYB-1780571629236	\N	\N	sicepat	gokil
26	ORD-260604-871	0	SiCepat Cargo per kg with minimum 10 kg	082331339737	1400000	Perumahan Nirwana Residence No.C3/11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	2026-06-04 19:02:01.173541+07	2026-06-04 19:02:44.049259+07	IDNP11IDNC250IDND2615IDZ65116	6a216964d0b0cf146ccaff3f	WYB-1780574564529	\N	\N	sicepat	gokil
36	ORD-260605-558	0	SiCepat Cargo per kg with minimum 10 kg	+6282132148698	1400000	Perumahan Ijen Nirwana Blok C3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	2026-06-05 16:36:47.726333+07	2026-06-05 16:37:18.441033+07	IDNP11IDNC250IDND2615IDZ65116	6a2298ce910e73db97e34508	WYB-1780652238694	\N	\N	sicepat	gokil
35	ORD-260605-629	0	SiCepat Cargo per kg with minimum 10 kg	082331339737	1400000	Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116	2026-06-05 15:44:02.10981+07	2026-06-05 15:51:18.617431+07	IDNP11IDNC250IDND2615IDZ65116	6a228e06cfb90453454968bb	WYB-1780649478843	\N	\N	sicepat	gokil
27	ORD-260604-204	0	SiCepat Cargo per kg with minimum 10 kg	082331339737	1732500	Perumahan Nirwana Residence No.C3/11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	2026-06-04 19:51:34.414058+07	2026-06-04 19:52:48.884328+07	IDNP11IDNC250IDND2615IDZ65116	6a2175214c47f43a6329d657	WYB-1780577569085	\N	\N	sicepat	gokil
33	ORD-260604-787	0	JNE JNE Trucking	082331339737	112000	Perumahan Nirwana Residence No.C3/11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	2026-06-04 22:41:12.802688+07	2026-06-04 22:47:24.623649+07	IDNP11IDNC250IDND2615IDZ65116	6a219e0c3c6b1ebd6f4eac7d	WYB-1780588044450	\N	\N	jne	jtr
28	ORD-260604-705	0	JNE Reguler	082331339737	7000	Perumahan Nirwana Residence No.C3/11, Klojen, Malang, Jawa Timur. 65116	2026-06-04 20:15:41.655741+07	2026-06-04 20:19:12.265681+07	IDNP11IDNC250IDND2615IDZ65116	6a217b50f5bd98286373e3c2	WYB-1780579152219	\N	\N	jne	reg
29	ORD-260604-795	0	JNE Reguler	082331339737	7000	Perumahan Nirwana Residence No.C3/11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	2026-06-04 20:29:13.166322+07	2026-06-04 20:29:13.166322+07	IDNP11IDNC250IDND2615IDZ65116			\N	\N	jne	reg
37	ORD-260605-444	0	SiCepat Cargo per kg with minimum 10 kg	082331339737	1400000	Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116	2026-06-05 20:25:48.71584+07	2026-06-05 20:25:48.71584+07	IDNP11IDNC250IDND2615IDZ65116			\N	\N	sicepat	gokil
30	ORD-260604-969	0	Ambil Di Toko	+62 8123388670	0	Jalan Utara Masjid No.9, Dampit Wetan, Dampit, Kec. Dampit, Kabupaten Malang, Jawa Timur 65181	2026-06-04 20:32:14.768082+07	2026-06-04 20:32:14.768082+07				\N	\N		
34	ORD-260605-340	0	SiCepat Cargo per kg with minimum 10 kg	082331339737	1400000	Perumahan Nirwana Residence No.C3/11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	2026-06-05 10:25:25.577801+07	2026-06-05 10:27:03.023196+07	IDNP11IDNC250IDND2615IDZ65116	6a224207cfb904596b478a29	WYB-1780630023314	\N	\N	sicepat	gokil
31	ORD-260604-507	0	Kurir Toko Sinar Abadi	082331339737	0	Perumahan Nirwana Residence No.C3/11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	2026-06-04 20:36:37.790421+07	2026-06-04 20:36:37.790421+07	IDNP11IDNC250IDND2615IDZ65116			\N	\N		
43	ORD-260605-128	0	Ambil Di Toko	+62 8123388670	0	Jalan Utara Masjid No.9, Dampit Wetan, Dampit, Kec. Dampit, Kabupaten Malang, Jawa Timur 65181	2026-06-05 23:09:54.048255+07	2026-06-05 23:09:54.048255+07				\N	\N		
40	ORD-260605-729	0	JNE Reguler	082331339737	7000	Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116	2026-06-05 22:21:44.926951+07	2026-06-05 22:22:18.698249+07	IDNP11IDNC250IDND2615IDZ65116	6a22e9a9b039b9126b2156f1	WYB-1780672937884	\N	\N	jne	reg
32	ORD-260604-216	0	JNE JNE Trucking	082331339737	40000	Perumahan Nirwana Residence No.C3/11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	2026-06-04 21:15:20.64804+07	2026-06-04 21:16:05.843354+07	IDNP11IDNC250IDND2615IDZ65116	6a2188a5e2940a4e82be6cf0	WYB-1780582565674	\N	\N	jne	jtr
38	ORD-260605-505	0	SiCepat Cargo per kg with minimum 10 kg	082331339737	1400000	Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116	2026-06-05 20:31:16.264906+07	2026-06-05 20:31:56.314274+07	IDNP11IDNC250IDND2615IDZ65116	6a22cfcbb039b9f5eb20ad63	WYB-1780666315610	\N	\N	sicepat	gokil
39	ORD-260605-636	0	Kurir Toko Sinar Abadi	082331339737	0	Perumahan ijen nirwana cluster green river blokc3 no 11, Gambir, Jakarta Pusat, DKI Jakarta. 10110	2026-06-05 22:09:03.381613+07	2026-06-05 22:09:03.381613+07	IDNP6IDNC147IDND829IDZ10110			\N	\N	jne	reg
41	ORD-260605-279	0	JNE Reguler	082331339737	7000	Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116	2026-06-05 22:59:15.52+07	2026-06-05 23:02:32.335716+07	IDNP11IDNC250IDND2615IDZ65116	6a22f312cfb90459dd4bf116	WYB-1780675346481	\N	\N	jne	reg
42	ORD-260605-300	0	Ambil Di Toko	+62 8123388670	0	Jalan Utara Masjid No.9, Dampit Wetan, Dampit, Kec. Dampit, Kabupaten Malang, Jawa Timur 65181	2026-06-05 23:06:56.935763+07	2026-06-05 23:06:56.935763+07				\N	\N		
45	ORD-260606-149	0	SiCepat Cargo per kg with minimum 10 kg	082331339737	94500	Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	2026-06-06 10:54:28.534878+07	2026-06-06 10:55:23.350629+07	IDNP11IDNC250IDND2615IDZ65116	6a239a2b35e4ab234e78d177	WYB-1780718123329	\N	\N	sicepat	gokil
44	ORD-260606-964	0	JNE Reguler	082331339737	7000	Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	2026-06-06 10:10:18.528861+07	2026-06-06 10:11:28.645867+07	IDNP11IDNC250IDND2615IDZ65116	6a238fe03c6b1ea2805a832b	WYB-1780715488532	\N	\N	jne	reg
46	ORD-260606-731	0	JNE Reguler	082331339737	35000	Perumahan ijen nirwana cluster green river blokc3 no 11, Klojen, Malang, Jawa Timur. 65116, Malang, Jawa Timur	2026-06-06 14:56:38.051148+07	2026-06-06 14:58:17.769778+07	IDNP11IDNC250IDND2615IDZ65116	6a23d319910e734986eb37af	WYB-1780732697284	\N	\N	jne	reg
\.


--
-- Data for Name: stock_logs; Type: TABLE DATA; Schema: public; Owner: postgres
--

COPY public.stock_logs (id, product_id, owner_id, change_type, qty_changed, final_stock, description, created_at) FROM stdin;
1	P-001	\N	addition	100	100	Stok Awal (Seeder)	2026-05-31 14:39:51.974391+07
2	P-002	\N	addition	120	120	Stok Awal (Seeder)	2026-05-31 14:39:51.978397+07
3	P-003	\N	addition	100	100	Stok Awal (Seeder)	2026-05-31 14:39:51.97944+07
4	P-004	\N	addition	60	60	Stok Awal (Seeder)	2026-05-31 14:39:51.980467+07
5	P-005	\N	addition	80	80	Stok Awal (Seeder)	2026-05-31 14:39:51.980982+07
6	P-006	\N	addition	50	50	Stok Awal (Seeder)	2026-05-31 14:39:51.982006+07
7	P-007	\N	addition	70	70	Stok Awal (Seeder)	2026-05-31 14:39:51.982521+07
8	P-008	\N	addition	70	70	Stok Awal (Seeder)	2026-05-31 14:39:51.983034+07
9	P-009	\N	addition	200	200	Stok Awal (Seeder)	2026-05-31 14:39:51.983591+07
10	P-010	\N	addition	200	200	Stok Awal (Seeder)	2026-05-31 14:39:51.984233+07
11	P-011	\N	addition	150	150	Stok Awal (Seeder)	2026-05-31 14:39:51.984831+07
12	P-012	\N	addition	100	100	Stok Awal (Seeder)	2026-05-31 14:39:51.985415+07
13	P-013	\N	addition	100	100	Stok Awal (Seeder)	2026-05-31 14:39:51.985925+07
14	P-014	\N	addition	80	80	Stok Awal (Seeder)	2026-05-31 14:39:51.986459+07
15	P-015	\N	addition	60	60	Stok Awal (Seeder)	2026-05-31 14:39:51.987616+07
16	P-016	\N	addition	50	50	Stok Awal (Seeder)	2026-05-31 14:39:51.988126+07
17	P-017	\N	addition	40	40	Stok Awal (Seeder)	2026-05-31 14:39:51.98871+07
18	P-018	\N	addition	30	30	Stok Awal (Seeder)	2026-05-31 14:39:51.989223+07
19	P-019	\N	addition	20	20	Stok Awal (Seeder)	2026-05-31 14:39:51.989822+07
20	P-020	\N	addition	15	15	Stok Awal (Seeder)	2026-05-31 14:39:51.990424+07
21	P-021	\N	addition	300	300	Stok Awal (Seeder)	2026-05-31 14:39:51.992272+07
22	P-022	\N	addition	250	250	Stok Awal (Seeder)	2026-05-31 14:39:51.992802+07
23	P-023	\N	addition	200	200	Stok Awal (Seeder)	2026-05-31 14:39:51.993978+07
24	P-024	\N	addition	150	150	Stok Awal (Seeder)	2026-05-31 14:39:51.994492+07
25	P-025	\N	addition	150	150	Stok Awal (Seeder)	2026-05-31 14:39:51.995067+07
26	P-026	\N	addition	100	100	Stok Awal (Seeder)	2026-05-31 14:39:51.995666+07
27	P-027	\N	addition	80	80	Stok Awal (Seeder)	2026-05-31 14:39:51.996273+07
28	P-028	\N	addition	60	60	Stok Awal (Seeder)	2026-05-31 14:39:51.996827+07
29	P-029	\N	addition	50	50	Stok Awal (Seeder)	2026-05-31 14:39:51.997445+07
30	P-030	\N	addition	100	100	Stok Awal (Seeder)	2026-05-31 14:39:51.997991+07
31	P-031	\N	addition	100	100	Stok Awal (Seeder)	2026-05-31 14:39:51.998573+07
32	P-032	\N	addition	80	80	Stok Awal (Seeder)	2026-05-31 14:39:51.999155+07
33	P-033	\N	addition	60	60	Stok Awal (Seeder)	2026-05-31 14:39:51.999763+07
34	P-034	\N	addition	50	50	Stok Awal (Seeder)	2026-05-31 14:39:52.000348+07
35	P-035	\N	addition	40	40	Stok Awal (Seeder)	2026-05-31 14:39:52.000977+07
36	P-036	\N	addition	30	30	Stok Awal (Seeder)	2026-05-31 14:39:52.001548+07
37	P-037	\N	addition	20	20	Stok Awal (Seeder)	2026-05-31 14:39:52.002145+07
38	P-038	\N	addition	15	15	Stok Awal (Seeder)	2026-05-31 14:39:52.002734+07
39	P-039	\N	addition	200	200	Stok Awal (Seeder)	2026-05-31 14:39:52.003304+07
40	P-040	\N	addition	200	200	Stok Awal (Seeder)	2026-05-31 14:39:52.003916+07
41	P-041	\N	addition	150	150	Stok Awal (Seeder)	2026-05-31 14:39:52.004529+07
42	P-042	\N	addition	100	100	Stok Awal (Seeder)	2026-05-31 14:39:52.005098+07
43	P-043	\N	addition	100	100	Stok Awal (Seeder)	2026-05-31 14:39:52.005675+07
44	P-044	\N	addition	80	80	Stok Awal (Seeder)	2026-05-31 14:39:52.006316+07
45	P-045	\N	addition	60	60	Stok Awal (Seeder)	2026-05-31 14:39:52.007702+07
46	P-046	\N	addition	50	50	Stok Awal (Seeder)	2026-05-31 14:39:52.009603+07
47	P-047	\N	addition	40	40	Stok Awal (Seeder)	2026-05-31 14:39:52.010727+07
48	P-048	\N	addition	25	25	Stok Awal (Seeder)	2026-05-31 14:39:52.011244+07
49	P-049	\N	addition	20	20	Stok Awal (Seeder)	2026-05-31 14:39:52.01237+07
50	P-050	\N	addition	10	10	Stok Awal (Seeder)	2026-05-31 14:39:52.012937+07
51	P-051	\N	addition	100	100	Stok Awal (Seeder)	2026-05-31 14:39:52.014528+07
52	P-052	\N	addition	40	40	Stok Awal (Seeder)	2026-05-31 14:39:52.015031+07
53	P-053	\N	addition	100	100	Stok Awal (Seeder)	2026-05-31 14:39:52.015689+07
54	P-054	\N	addition	35	35	Stok Awal (Seeder)	2026-05-31 14:39:52.016722+07
55	P-055	\N	addition	60	60	Stok Awal (Seeder)	2026-05-31 14:39:52.017243+07
56	P-056	\N	addition	20	20	Stok Awal (Seeder)	2026-05-31 14:39:52.01783+07
57	P-057	\N	addition	50	50	Stok Awal (Seeder)	2026-05-31 14:39:52.018376+07
58	P-058	\N	addition	15	15	Stok Awal (Seeder)	2026-05-31 14:39:52.018943+07
59	P-059	\N	addition	120	120	Stok Awal (Seeder)	2026-05-31 14:39:52.01948+07
60	P-060	\N	addition	40	40	Stok Awal (Seeder)	2026-05-31 14:39:52.020021+07
61	P-061	\N	addition	80	80	Stok Awal (Seeder)	2026-05-31 14:39:52.020583+07
62	P-062	\N	addition	100	100	Stok Awal (Seeder)	2026-05-31 14:39:52.021094+07
63	P-063	\N	addition	60	60	Stok Awal (Seeder)	2026-05-31 14:39:52.021619+07
64	P-064	\N	addition	80	80	Stok Awal (Seeder)	2026-05-31 14:39:52.022935+07
65	P-065	\N	addition	50	50	Stok Awal (Seeder)	2026-05-31 14:39:52.024465+07
66	P-066	\N	addition	70	70	Stok Awal (Seeder)	2026-05-31 14:39:52.026699+07
67	P-067	\N	addition	80	80	Stok Awal (Seeder)	2026-05-31 14:39:52.027969+07
68	P-068	\N	addition	100	100	Stok Awal (Seeder)	2026-05-31 14:39:52.029127+07
69	P-069	\N	addition	200	200	Stok Awal (Seeder)	2026-05-31 14:39:52.029651+07
70	P-070	\N	addition	150	150	Stok Awal (Seeder)	2026-05-31 14:39:52.030857+07
71	P-071	\N	addition	120	120	Stok Awal (Seeder)	2026-05-31 14:39:52.031408+07
72	P-072	\N	addition	100	100	Stok Awal (Seeder)	2026-05-31 14:39:52.032557+07
73	P-073	\N	addition	80	80	Stok Awal (Seeder)	2026-05-31 14:39:52.033768+07
74	P-074	\N	addition	60	60	Stok Awal (Seeder)	2026-05-31 14:39:52.034298+07
75	P-075	\N	addition	30	30	Stok Awal (Seeder)	2026-05-31 14:39:52.035909+07
76	P-076	\N	addition	30	30	Stok Awal (Seeder)	2026-05-31 14:39:52.037042+07
77	P-077	\N	addition	40	40	Stok Awal (Seeder)	2026-05-31 14:39:52.037598+07
78	P-078	\N	addition	10	10	Stok Awal (Seeder)	2026-05-31 14:39:52.038121+07
79	P-079	\N	addition	10	10	Stok Awal (Seeder)	2026-05-31 14:39:52.04405+07
80	P-080	\N	addition	12	12	Stok Awal (Seeder)	2026-05-31 14:39:52.050377+07
81	P-081	\N	addition	15	15	Stok Awal (Seeder)	2026-05-31 14:39:52.057419+07
82	P-082	\N	addition	15	15	Stok Awal (Seeder)	2026-05-31 14:39:52.058927+07
83	P-083	\N	addition	20	20	Stok Awal (Seeder)	2026-05-31 14:39:52.064272+07
84	P-084	\N	addition	15	15	Stok Awal (Seeder)	2026-05-31 14:39:52.064775+07
85	P-085	\N	addition	18	18	Stok Awal (Seeder)	2026-05-31 14:39:52.065288+07
86	P-086	\N	addition	12	12	Stok Awal (Seeder)	2026-05-31 14:39:52.065829+07
87	P-087	\N	addition	10	10	Stok Awal (Seeder)	2026-05-31 14:39:52.066418+07
88	P-088	\N	addition	200	200	Stok Awal (Seeder)	2026-05-31 14:39:52.066933+07
89	P-089	\N	addition	200	200	Stok Awal (Seeder)	2026-05-31 14:39:52.067495+07
90	P-090	\N	addition	150	150	Stok Awal (Seeder)	2026-05-31 14:39:52.068033+07
91	P-091	\N	addition	150	150	Stok Awal (Seeder)	2026-05-31 14:39:52.068589+07
92	P-092	\N	addition	100	100	Stok Awal (Seeder)	2026-05-31 14:39:52.069156+07
93	P-093	\N	addition	100	100	Stok Awal (Seeder)	2026-05-31 14:39:52.069677+07
94	P-094	\N	addition	100	100	Stok Awal (Seeder)	2026-05-31 14:39:52.078145+07
95	P-095	\N	addition	100	100	Stok Awal (Seeder)	2026-05-31 14:39:52.088337+07
96	P-096	\N	addition	300	300	Stok Awal (Seeder)	2026-05-31 14:39:52.097366+07
97	P-097	\N	addition	300	300	Stok Awal (Seeder)	2026-05-31 14:39:52.107047+07
98	P-098	\N	addition	250	250	Stok Awal (Seeder)	2026-05-31 14:39:52.108983+07
99	P-099	\N	addition	200	200	Stok Awal (Seeder)	2026-05-31 14:39:52.110341+07
100	P-100	\N	addition	200	200	Stok Awal (Seeder)	2026-05-31 14:39:52.110858+07
101	P-101	\N	addition	300	300	Stok Awal (Seeder)	2026-05-31 14:39:52.111384+07
102	P-102	\N	addition	300	300	Stok Awal (Seeder)	2026-05-31 14:39:52.112428+07
103	P-103	\N	addition	250	250	Stok Awal (Seeder)	2026-05-31 14:39:52.11295+07
104	P-104	\N	addition	250	250	Stok Awal (Seeder)	2026-05-31 14:39:52.113546+07
105	P-105	\N	addition	200	200	Stok Awal (Seeder)	2026-05-31 14:39:52.114084+07
106	P-106	\N	addition	200	200	Stok Awal (Seeder)	2026-05-31 14:39:52.114666+07
107	P-107	\N	addition	150	150	Stok Awal (Seeder)	2026-05-31 14:39:52.115245+07
108	P-108	\N	addition	150	150	Stok Awal (Seeder)	2026-05-31 14:39:52.115807+07
109	P-109	\N	addition	100	100	Stok Awal (Seeder)	2026-05-31 14:39:52.116373+07
110	P-110	\N	addition	150	150	Stok Awal (Seeder)	2026-05-31 14:39:52.116944+07
111	P-111	\N	addition	100	100	Stok Awal (Seeder)	2026-05-31 14:39:52.117502+07
112	P-112	\N	addition	120	120	Stok Awal (Seeder)	2026-05-31 14:39:52.118099+07
113	P-113	\N	addition	50	50	Stok Awal (Seeder)	2026-05-31 14:39:52.118648+07
114	P-114	\N	addition	60	60	Stok Awal (Seeder)	2026-05-31 14:39:52.119212+07
115	P-115	\N	addition	80	80	Stok Awal (Seeder)	2026-05-31 14:39:52.11976+07
116	P-116	\N	addition	30	30	Stok Awal (Seeder)	2026-05-31 14:39:52.120308+07
117	P-117	\N	addition	40	40	Stok Awal (Seeder)	2026-05-31 14:39:52.120818+07
118	P-118	\N	addition	60	60	Stok Awal (Seeder)	2026-05-31 14:39:52.121434+07
119	P-119	\N	addition	70	70	Stok Awal (Seeder)	2026-05-31 14:39:52.121969+07
120	P-120	\N	addition	100	100	Stok Awal (Seeder)	2026-05-31 14:39:52.123095+07
121	P-121	\N	addition	100	100	Stok Awal (Seeder)	2026-05-31 14:39:52.123625+07
122	P-122	\N	addition	120	120	Stok Awal (Seeder)	2026-05-31 14:39:52.124197+07
123	P-123	\N	addition	100	100	Stok Awal (Seeder)	2026-05-31 14:39:52.125655+07
124	P-124	\N	addition	120	120	Stok Awal (Seeder)	2026-05-31 14:39:52.126219+07
125	P-125	\N	addition	150	150	Stok Awal (Seeder)	2026-05-31 14:39:52.127349+07
126	P-126	\N	addition	200	200	Stok Awal (Seeder)	2026-05-31 14:39:52.127868+07
127	P-127	\N	addition	200	200	Stok Awal (Seeder)	2026-05-31 14:39:52.128423+07
128	P-128	\N	addition	250	250	Stok Awal (Seeder)	2026-05-31 14:39:52.129018+07
129	P-129	\N	addition	200	200	Stok Awal (Seeder)	2026-05-31 14:39:52.129583+07
130	P-130	\N	addition	180	180	Stok Awal (Seeder)	2026-05-31 14:39:52.130162+07
131	P-131	\N	addition	100	100	Stok Awal (Seeder)	2026-05-31 14:39:52.130712+07
132	P-132	\N	addition	150	150	Stok Awal (Seeder)	2026-05-31 14:39:52.131302+07
133	P-133	\N	addition	130	130	Stok Awal (Seeder)	2026-05-31 14:39:52.131875+07
134	P-134	\N	addition	100	100	Stok Awal (Seeder)	2026-05-31 14:39:52.132463+07
135	P-135	\N	addition	80	80	Stok Awal (Seeder)	2026-05-31 14:39:52.133028+07
136	P-136	\N	addition	70	70	Stok Awal (Seeder)	2026-05-31 14:39:52.133564+07
137	P-137	\N	addition	50	50	Stok Awal (Seeder)	2026-05-31 14:39:52.134682+07
138	P-002	\N	deduction	-20	100	Penjualan (Order ORD-260531-793)	2026-05-31 20:15:04.088969+07
139	P-004	\N	deduction	-20	40	Penjualan (Order ORD-260531-793)	2026-05-31 20:15:04.110039+07
140	P-004	\N	deduction	-10	30	Penjualan (Order ORD-260531-325)	2026-05-31 21:02:38.602973+07
141	P-004	\N	deduction	-10	20	Penjualan (Order ORD-260601-785)	2026-06-01 19:38:17.355383+07
142	P-002	\N	deduction	-10	90	Penjualan (Order ORD-260601-785)	2026-06-01 19:38:17.391078+07
143	P-061	\N	deduction	-2	78	Penjualan (Order ORD-260601-741)	2026-06-01 19:43:12.072926+07
144	P-002	\N	deduction	-20	70	Penjualan (Order ORD-260603-721)	2026-06-03 12:43:09.746838+07
145	P-054	\N	deduction	-3	32	Penjualan (Order ORD-260603-721)	2026-06-03 12:43:09.762873+07
146	P-074	\N	deduction	-20	40	Penjualan (Order ORD-260603-721)	2026-06-03 12:43:09.764978+07
147	P-002	\N	deduction	-20	50	Penjualan (Order ORD-260603-541)	2026-06-03 12:56:55.366055+07
148	P-002	\N	deduction	-10	40	Penjualan (Order ORD-260603-437)	2026-06-03 13:56:18.755981+07
149	P-002	\N	deduction	-11	29	Penjualan (Order ORD-260603-153)	2026-06-03 14:07:54.029792+07
150	P-002	\N	deduction	-12	17	Penjualan (Order ORD-260603-820)	2026-06-03 14:12:25.638354+07
151	P-083	\N	deduction	-1	19	Penjualan (Order ORD-260603-503)	2026-06-03 14:23:00.283674+07
152	P-004	\N	deduction	-10	10	Penjualan (Order ORD-260603-731)	2026-06-03 14:34:02.569738+07
153	P-004	1	addition	39	49	Penambahan Manual Owner	2026-06-03 17:12:09.301716+07
154	P-074	\N	deduction	-5	35	Penjualan (Order ORD-260603-256)	2026-06-03 18:02:28.553313+07
155	P-074	\N	deduction	-5	30	Penjualan (Order ORD-260603-300)	2026-06-03 18:09:36.858282+07
156	P-074	\N	deduction	-3	27	Penjualan (Order ORD-260603-480)	2026-06-03 18:21:57.435867+07
157	P-074	\N	deduction	-4	23	Penjualan (Order ORD-260603-849)	2026-06-03 18:32:25.599183+07
158	P-074	\N	deduction	-3	20	Penjualan (Order ORD-260603-210)	2026-06-03 18:42:25.482532+07
159	P-061	\N	deduction	-5	73	Penjualan (Order ORD-260603-971)	2026-06-03 19:30:22.982841+07
160	P-083	\N	deduction	-1	18	Penjualan (Order ORD-260603-941)	2026-06-03 20:35:00.095313+07
161	P-083	\N	deduction	-1	17	Penjualan (Order ORD-260603-324)	2026-06-03 20:39:29.375749+07
162	P-083	\N	deduction	-1	16	Penjualan (Order ORD-260603-526)	2026-06-03 21:01:13.64501+07
163	P-101	\N	deduction	-10	290	Penjualan (Order ORD-260603-391)	2026-06-03 21:22:38.206143+07
164	P-061	\N	deduction	-1	72	Penjualan (Order ORD-260603-629)	2026-06-03 21:30:02.743295+07
165	P-001	\N	deduction	-10	90	Penjualan (Order ORD-260603-818)	2026-06-03 21:33:29.824051+07
166	P-001	\N	deduction	-10	80	Penjualan (Order ORD-260603-817)	2026-06-03 21:38:19.441745+07
167	P-001	\N	deduction	-10	70	Penjualan (Order ORD-260604-224)	2026-06-04 18:13:00.940989+07
168	P-061	\N	deduction	-3	69	Penjualan (Order ORD-260604-224)	2026-06-04 18:13:00.956755+07
169	P-001	\N	deduction	-10	60	Penjualan (Order ORD-260604-871)	2026-06-04 19:02:01.158844+07
170	P-001	\N	deduction	-10	50	Penjualan (Order ORD-260604-204)	2026-06-04 19:51:34.397833+07
171	P-074	\N	deduction	-5	15	Penjualan (Order ORD-260604-204)	2026-06-04 19:51:34.40751+07
172	P-101	\N	deduction	-10	280	Penjualan (Order ORD-260604-705)	2026-06-04 20:15:41.651252+07
173	P-101	\N	addition	10	290	Pembatalan Pesanan (Order ORD-260604-705)	2026-06-04 20:26:12.946295+07
174	P-101	\N	deduction	-10	280	Penjualan (Order ORD-260604-795)	2026-06-04 20:29:13.159303+07
175	P-101	\N	addition	10	290	Pembatalan Pesanan (Order ORD-260604-795)	2026-06-04 20:29:45.785573+07
176	P-101	\N	deduction	-10	280	Penjualan (Order ORD-260604-969)	2026-06-04 20:32:14.765185+07
177	P-004	\N	deduction	-10	39	Penjualan (Order ORD-260604-507)	2026-06-04 20:36:37.788145+07
178	P-021	\N	deduction	-10	290	Penjualan (Order ORD-260604-216)	2026-06-04 21:15:20.640936+07
179	P-021	\N	addition	10	300	Pembatalan Pesanan (Order ORD-260604-216)	2026-06-04 21:20:57.001003+07
180	P-061	\N	deduction	-3	66	Penjualan (Order ORD-260604-787)	2026-06-04 22:41:12.775773+07
181	P-077	\N	deduction	-1	39	Penjualan (Order ORD-260604-787)	2026-06-04 22:41:12.787118+07
182	P-002	\N	deduction	-10	7	Penjualan (Order ORD-260605-340)	2026-06-05 10:25:25.546283+07
183	P-004	\N	deduction	-10	29	Penjualan (Order ORD-260605-629)	2026-06-05 15:44:02.083999+07
184	P-004	\N	deduction	-10	19	Penjualan (Order ORD-260605-558)	2026-06-05 16:36:47.717954+07
185	P-004	\N	addition	10	29	Pembatalan Pesanan (Order ORD-260605-629)	2026-06-05 16:55:19.14839+07
186	P-001	\N	deduction	-10	40	Penjualan (Order ORD-260605-444)	2026-06-05 20:25:48.64962+07
187	P-001	\N	addition	10	50	Pembatalan Pesanan (Order ORD-260605-444)	2026-06-05 20:27:51.88705+07
188	P-001	\N	deduction	-10	40	Penjualan (Order ORD-260605-505)	2026-06-05 20:31:16.238222+07
189	P-083	\N	deduction	-1	15	Penjualan (Order ORD-260605-636)	2026-06-05 22:09:03.371882+07
190	P-083	\N	addition	1	16	Pembatalan Pesanan (Order ORD-260605-636)	2026-06-05 22:16:25.709238+07
191	P-083	\N	deduction	-1	15	Penjualan (Order ORD-260605-729)	2026-06-05 22:21:44.923134+07
192	P-083	\N	deduction	-1	14	Penjualan (Order ORD-260605-279)	2026-06-05 22:59:15.514943+07
193	P-102	\N	deduction	-10	290	Penjualan (Order ORD-260605-300)	2026-06-05 23:06:56.934644+07
194	P-102	\N	deduction	-1	289	Penjualan (Order ORD-260605-128)	2026-06-05 23:09:54.045017+07
195	P-106	\N	deduction	-10	190	Penjualan (Order ORD-260606-964)	2026-06-06 10:10:18.487555+07
196	P-069	\N	deduction	-10	190	Penjualan (Order ORD-260606-149)	2026-06-06 10:54:28.529421+07
197	P-061	\N	deduction	-5	61	Penjualan (Order ORD-260606-731)	2026-06-06 14:56:38.021205+07
\.


--
-- Name: admins_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.admins_id_seq', 1, true);


--
-- Name: customer_addresses_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.customer_addresses_id_seq', 3, true);


--
-- Name: customers_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.customers_id_seq', 3, true);


--
-- Name: order_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.order_items_id_seq', 55, true);


--
-- Name: owners_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.owners_id_seq', 1, true);


--
-- Name: payments_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.payments_id_seq', 46, true);


--
-- Name: product_variants_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.product_variants_id_seq', 21, true);


--
-- Name: shippings_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.shippings_id_seq', 46, true);


--
-- Name: stock_logs_id_seq; Type: SEQUENCE SET; Schema: public; Owner: postgres
--

SELECT pg_catalog.setval('public.stock_logs_id_seq', 197, true);


--
-- Name: admins admins_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.admins
    ADD CONSTRAINT admins_pkey PRIMARY KEY (id);


--
-- Name: customer_addresses customer_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customer_addresses
    ADD CONSTRAINT customer_addresses_pkey PRIMARY KEY (id);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- Name: order_items order_items_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT order_items_pkey PRIMARY KEY (id);


--
-- Name: orders orders_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT orders_pkey PRIMARY KEY (id);


--
-- Name: owners owners_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.owners
    ADD CONSTRAINT owners_pkey PRIMARY KEY (id);


--
-- Name: payments payments_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);


--
-- Name: product_variants product_variants_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.product_variants
    ADD CONSTRAINT product_variants_pkey PRIMARY KEY (id);


--
-- Name: products products_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);


--
-- Name: shippings shippings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shippings
    ADD CONSTRAINT shippings_pkey PRIMARY KEY (id);


--
-- Name: stock_logs stock_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_logs
    ADD CONSTRAINT stock_logs_pkey PRIMARY KEY (id);


--
-- Name: idx_admins_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_admins_email ON public.admins USING btree (email);


--
-- Name: idx_admins_username; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_admins_username ON public.admins USING btree (username);


--
-- Name: idx_customers_username; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_customers_username ON public.customers USING btree (username);


--
-- Name: idx_order_items_order_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_order_items_order_id ON public.order_items USING btree (order_id);


--
-- Name: idx_owners_email; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_owners_email ON public.owners USING btree (email);


--
-- Name: idx_owners_username; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_owners_username ON public.owners USING btree (username);


--
-- Name: idx_payments_order_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_payments_order_id ON public.payments USING btree (order_id);


--
-- Name: idx_product_variants_product_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_product_variants_product_id ON public.product_variants USING btree (product_id);


--
-- Name: idx_shippings_order_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX idx_shippings_order_id ON public.shippings USING btree (order_id);


--
-- Name: idx_stock_logs_product_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_stock_logs_product_id ON public.stock_logs USING btree (product_id);


--
-- Name: orders fk_orders_customer; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.orders
    ADD CONSTRAINT fk_orders_customer FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: order_items fk_orders_items; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.order_items
    ADD CONSTRAINT fk_orders_items FOREIGN KEY (order_id) REFERENCES public.orders(id);


--
-- Name: payments fk_orders_payment; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT fk_orders_payment FOREIGN KEY (order_id) REFERENCES public.orders(id);


--
-- Name: shippings fk_orders_shipping; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.shippings
    ADD CONSTRAINT fk_orders_shipping FOREIGN KEY (order_id) REFERENCES public.orders(id);


--
-- Name: stock_logs fk_stock_logs_owner; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_logs
    ADD CONSTRAINT fk_stock_logs_owner FOREIGN KEY (owner_id) REFERENCES public.owners(id);


--
-- Name: stock_logs fk_stock_logs_product; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.stock_logs
    ADD CONSTRAINT fk_stock_logs_product FOREIGN KEY (product_id) REFERENCES public.products(id);


--
-- PostgreSQL database dump complete
--

\unrestrict gcgbDndveA7fAI199cdSiqM6nSCCQVzagL7j3W5wsrqmonNYPuAhg3khgq43enb


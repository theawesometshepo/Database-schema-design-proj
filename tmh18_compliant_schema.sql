-- =============================================================================
-- TMH 18 ROAD ASSET DATA ELECTRONIC EXCHANGE FORMATS
-- Committee Draft 5.0 - February 2016
-- Committee of Transport Officials (COTO) - South Africa
-- 
-- PostgreSQL / PostGIS Compliant Database Schema
-- Geometry: EPSG:4326 (WGS84) as mandated by TMH18 Section 2.3.2
-- =============================================================================

-- =============================================================================
-- SCHEMA CREATION
-- =============================================================================

CREATE SCHEMA IF NOT EXISTS tmh18;       -- Core TMH18 network & classification tables
CREATE SCHEMA IF NOT EXISTS condition;   -- Visual condition & instrument data
CREATE SCHEMA IF NOT EXISTS reference;   -- COTO code lists & lookup tables
CREATE SCHEMA IF NOT EXISTS reporting;   -- Views for dashboards & QGIS layers

-- Enable PostGIS
CREATE EXTENSION IF NOT EXISTS postgis;

-- =============================================================================
-- SECTION 1: REFERENCE / LOOKUP TABLES
-- Source: TMH18 CD5.0 field definitions throughout document
-- =============================================================================

-- Authority IDs (Table 2)
CREATE TABLE reference.auth_ids (
    auth_id     VARCHAR(5)   PRIMARY KEY,
    authority   VARCHAR(200) NOT NULL,
    auth_type   VARCHAR(20)  NOT NULL CHECK (auth_type IN ('PROVINCE','METRO','NATIONAL'))
);
INSERT INTO reference.auth_ids VALUES
    ('ECP',  'Eastern Cape Province',                    'PROVINCE'),
    ('FSP',  'Free State Province',                      'PROVINCE'),
    ('GTP',  'Gauteng Province',                         'PROVINCE'),
    ('KZN',  'KwaZulu-Natal Province',                   'PROVINCE'),
    ('LPP',  'Limpopo Province',                         'PROVINCE'),
    ('MPP',  'Mpumalanga Province',                      'PROVINCE'),
    ('NCP',  'Northern Cape Province',                   'PROVINCE'),
    ('NWP',  'North West Province',                      'PROVINCE'),
    ('WCP',  'Western Cape Province',                    'PROVINCE'),
    ('BUF',  'Buffalo City Metropolitan Municipality',   'METRO'),
    ('CTP',  'City of Cape Town Metropolitan Municipality','METRO'),
    ('JHB',  'City of Johannesburg Metropolitan Municipality','METRO'),
    ('TSH',  'City of Tshwane Metropolitan Municipality','METRO'),
    ('EKU',  'Ekurhuleni Metropolitan Municipality',     'METRO'),
    ('ETH',  'eThekwini Metropolitan Municipality',      'METRO'),
    ('MAN',  'Mangaung Metropolitan Municipality',       'METRO'),
    ('NMA',  'Nelson Mandela Bay Metropolitan Municipality','METRO');

-- RISFSA Classifications (Table 7: RISFSA_CLS field)
CREATE TABLE reference.risfsa_classes (
    code        VARCHAR(15)  PRIMARY KEY,
    description VARCHAR(200) NOT NULL,
    road_env    VARCHAR(10)  NOT NULL CHECK (road_env IN ('RURAL','URBAN'))
);
INSERT INTO reference.risfsa_classes VALUES
    ('R1',  'Rural principal distributor',      'RURAL'),
    ('R2',  'Rural major distributor',          'RURAL'),
    ('R3',  'Rural minor distributor',          'RURAL'),
    ('R4',  'Rural collector road',             'RURAL'),
    ('R4B', 'Rural collector road',             'RURAL'),
    ('R5',  'Rural local road',                 'RURAL'),
    ('R5B', 'Rural local road',                 'RURAL'),
    ('R6B', 'Rural walkway',                    'RURAL'),
    ('R7B', 'Other',                            'RURAL'),
    ('R7C', 'Other',                            'RURAL'),
    ('R7D', 'Other',                            'RURAL'),
    ('R7E', 'Other',                            'RURAL'),
    ('R7F', 'Other',                            'RURAL'),
    ('R7G', 'Other',                            'RURAL'),
    ('R7H', 'Other',                            'RURAL'),
    ('U1',  'Urban principal arterial',         'URBAN'),
    ('U2',  'Urban major arterial',             'URBAN'),
    ('U3',  'Urban minor arterial',             'URBAN'),
    ('U4a', 'Urban Commercial collector street','URBAN'),
    ('U4b', 'Urban Residential collector street','URBAN'),
    ('U5a', 'Urban Commercial local street',    'URBAN'),
    ('U5b', 'Urban Residential local street',   'URBAN'),
    ('U6a', 'Urban Pedestrian priority street or area','URBAN'),
    ('U6b', 'Urban Pedestrian only street or area','URBAN');

-- Surface Types (Table 7: SURF_TYPE field)
CREATE TABLE reference.surface_types (
    code        VARCHAR(5)   PRIMARY KEY,
    description VARCHAR(100) NOT NULL,
    category    VARCHAR(20)  NOT NULL CHECK (category IN ('UNPAVED','CONCRETE','FLEXIBLE','BLOCK'))
);
INSERT INTO reference.surface_types VALUES
    ('GRAV',  'Gravel',                                      'UNPAVED'),
    ('EARTH', 'Earth road',                                  'UNPAVED'),
    ('TRACK', 'Track road',                                  'UNPAVED'),
    ('SAND',  'Sand road',                                   'UNPAVED'),
    ('CJP',   'Jointed Concrete plain',                      'CONCRETE'),
    ('DJP',   'Dowelled Jointed Concrete',                   'CONCRETE'),
    ('CRC',   'Continuously Reinforced Concrete',            'CONCRETE'),
    ('UTCP',  'Ultra-thin Concrete Reinforced Pavement',     'CONCRETE'),
    ('JRCP',  'Jointed Reinforced Concrete Pavement',        'CONCRETE'),
    ('FLEX',  'Bituminous/Flexible Pavement Surface',        'FLEXIBLE'),
    ('BLOC',  'Concrete Block Paving',                       'BLOCK');

-- Road Status Codes (Table 9: STATUS field)
CREATE TABLE reference.road_statuses (
    code        SMALLINT     PRIMARY KEY,
    description VARCHAR(100) NOT NULL
);
INSERT INTO reference.road_statuses VALUES
    (1, 'Current (Built)'),
    (2, 'To be verified'),
    (3, 'Under construction'),
    (4, 'Planned (New Link)'),
    (5, 'Upgrade to Paved'),
    (6, 'Road Closed'),
    (7, 'Inaccessible');

-- Road Types (Table 9: ROAD_TYPE field)
CREATE TABLE reference.road_types (
    code        VARCHAR(3)   PRIMARY KEY,
    description VARCHAR(200) NOT NULL
);
INSERT INTO reference.road_types VALUES
    ('S2U', 'Single carriageway, unpaved shoulders, 2 lanes'),
    ('S2P', 'Single carriageway, paved shoulders, 2 lanes'),
    ('N2U', 'Undivided, unpaved shoulders'),
    ('N2P', 'Undivided, paved shoulders'),
    ('D2P', 'Dual carriageway, paved shoulders, 2 lanes'),
    ('D3P', 'Dual carriageway, paved shoulders, 3 lanes');

-- Surfacing Types for Flexible Condition (Table 13: SURFACE field, TRH14 codes)
CREATE TABLE reference.surfacing_types (
    code        VARCHAR(2)   PRIMARY KEY,
    description VARCHAR(100) NOT NULL
);
INSERT INTO reference.surfacing_types VALUES
    ('AC', 'Asphalt surfacing - continuously graded'),
    ('AG', 'Asphalt surfacing - gap-graded'),
    ('AS', 'Asphalt surfacing - semi-gap-graded'),
    ('AO', 'Asphalt surfacing - open-graded'),
    ('S1', 'Surface Treatment - single seal'),
    ('S2', 'Surface Treatment - multiple seal'),
    ('S3', 'Sand Seal'),
    ('S4', 'Cape Seal / Single seal and slurry'),
    ('S5', 'Slurry Seal');

-- Node Types (Table 11: FROM_NODE_TYPE / TO_NODE_TYPE)
CREATE TABLE reference.node_types (
    code        VARCHAR(20)  PRIMARY KEY,
    description VARCHAR(100) NOT NULL
);
INSERT INTO reference.node_types VALUES
    ('+',      'Road crossing / Intersection'),
    ('BD',     'Begin Dual'),
    ('BEGIN',  'Begin Freeway'),
    ('BO',     'Borders / Boundaries'),
    ('BR',     'Over / Bridge'),
    ('BRIDGE', 'Bridge'),
    ('BS:UB',  'Begin Subsidy'),
    ('CP',     'Change of Pavement Type'),
    ('CLOSED', 'Closed / Gated'),
    ('ED',     'End Dual'),
    ('EN',     'End of segment (no node)'),
    ('END',    'End of Road'),
    ('EP',     'End of Paved Segment'),
    ('ESUB',   'End Subsidy'),
    ('MBOUND', 'Municipal Boundary'),
    ('SP',     'Start of Paved Segment'),
    ('ST',     'Start of segment (no node)'),
    ('T',      'T Junction'),
    ('TL',     'T Junction Left'),
    ('TR',     'T Junction Right'),
    ('V',      'Village / Town'),
    ('MX',     'Maximum segment length used as segment end');


-- =============================================================================
-- SECTION 2: NETWORK DEFINITION TABLE
-- Source: TMH18 CD5.0 Table 7 — Network definition
-- File extension: .net
-- =============================================================================

CREATE TABLE tmh18.network (

    -- Internal surrogate key (PostGIS best practice — not in TMH18 spec)
    pk              BIGSERIAL   PRIMARY KEY,

    -- TMH18 Table 7 fields (exact field names preserved)
    auth_id         VARCHAR(5)   NOT NULL
                    REFERENCES reference.auth_ids(auth_id),
    road_id         VARCHAR(50)  NOT NULL,
    route           VARCHAR(12),
    route_seq       NUMERIC(3,0),
    start_km        NUMERIC(6,3) NOT NULL,
    end_km          NUMERIC(6,3) NOT NULL,
    start_date      DATE         NOT NULL,
    end_date        DATE,                            -- NULL = still active
    rdda_id         VARCHAR(8),
    auth_rd_id      VARCHAR(7),
    sadc_route      VARCHAR(12),
    auth_rddir      VARCHAR(2)   CHECK (auth_rddir IN ('N','S','E','W')),
    risfsa_cls      VARCHAR(15)
                    REFERENCES reference.risfsa_classes(code),
    surf_type       VARCHAR(5)
                    REFERENCES reference.surface_types(code),
    start_desc      VARCHAR(100),
    end_desc        VARCHAR(100),
    gis_linkid      VARCHAR(20),

    -- Geometry: WGS84 LINESTRING as required by TMH18 Section 2.3.2
    -- "Must have only a single line string geometry element" (Section 2.1d)
    -- EPSG:4326 as mandated by Section 2.3.2
    geom            GEOMETRY(LINESTRING, 4326),

    -- Constraints
    CONSTRAINT chk_net_km        CHECK (end_km > start_km),
    CONSTRAINT chk_net_dates     CHECK (end_date IS NULL OR end_date > start_date),
    CONSTRAINT chk_net_geom_valid CHECK (geom IS NULL OR ST_IsValid(geom)),
    CONSTRAINT uq_road_id_dates  UNIQUE (road_id, start_date)
);

-- Spatial index (mandatory for PostGIS performance)
CREATE INDEX idx_network_geom     ON tmh18.network USING GIST (geom);
CREATE INDEX idx_network_road_id  ON tmh18.network (road_id);
CREATE INDEX idx_network_auth_id  ON tmh18.network (auth_id);
CREATE INDEX idx_network_route    ON tmh18.network (route);
CREATE INDEX idx_network_surf     ON tmh18.network (surf_type);
CREATE INDEX idx_network_active   ON tmh18.network (end_date) WHERE end_date IS NULL;

COMMENT ON TABLE  tmh18.network          IS 'TMH18 CD5.0 Table 7 — Network Definition File (.net)';
COMMENT ON COLUMN tmh18.network.road_id  IS 'Unique road identifier per authority — base reference for all linear data';
COMMENT ON COLUMN tmh18.network.geom     IS 'WGS84 LINESTRING EPSG:4326. Coordinates in chainage order: first vertex = start_km, last vertex = end_km';
COMMENT ON COLUMN tmh18.network.end_date IS 'NULL if the network definition is still current';


-- =============================================================================
-- SECTION 3: ROAD CLASSIFICATION TABLE
-- Source: TMH18 CD5.0 Table 9 — Road Classification Information
-- File extension: .rcl
-- Segment ID format: [ROAD_ID]_00000 (start in metres, 5-digit zero-padded)
-- =============================================================================

CREATE TABLE tmh18.road_classification (

    pk              BIGSERIAL    PRIMARY KEY,

    -- TMH18 Table 9 fields
    seg_id          VARCHAR(60)  UNIQUE NOT NULL,    -- [ROAD_ID]_00000
    auth_id         VARCHAR(5)   NOT NULL
                    REFERENCES reference.auth_ids(auth_id),
    road_id         VARCHAR(50)  NOT NULL,
    start_km        NUMERIC(6,3) NOT NULL,
    end_km          NUMERIC(6,3) NOT NULL,
    start_date      DATE         NOT NULL,
    end_date        DATE,
    status          SMALLINT     NOT NULL
                    REFERENCES reference.road_statuses(code),
    road_type       VARCHAR(3)
                    REFERENCES reference.road_types(code),
    road_width      NUMERIC(4,2),                   -- metres, format 99.99
    nr_lanes        SMALLINT     CHECK (nr_lanes BETWEEN 1 AND 20),
    nr_shoulders    SMALLINT     CHECK (nr_shoulders BETWEEN 0 AND 4),
    base_date       DATE,
    surf_date       DATE,
    terr_class      VARCHAR(1)   CHECK (terr_class IN ('F','R','M')),
    region          VARCHAR(5),
    district        VARCHAR(20),
    munic           VARCHAR(20),
    start_longitude NUMERIC(23,20),
    start_latitude  NUMERIC(23,20),
    end_longitude   NUMERIC(23,20),
    end_latitude    NUMERIC(23,20),

    -- Derived geometry (PostGIS convenience — extracted from network geom via LRS)
    geom            GEOMETRY(LINESTRING, 4326),

    CONSTRAINT chk_rcl_km     CHECK (end_km > start_km),
    CONSTRAINT chk_rcl_width  CHECK (road_width > 0),
    CONSTRAINT chk_rcl_geom_valid CHECK (geom IS NULL OR ST_IsValid(geom)),
    CONSTRAINT fk_rcl_road_id FOREIGN KEY (road_id, start_date)
                              REFERENCES tmh18.network(road_id, start_date)
);

CREATE INDEX idx_rcl_geom     ON tmh18.road_classification USING GIST (geom);
CREATE INDEX idx_rcl_road_id  ON tmh18.road_classification (road_id);
CREATE INDEX idx_rcl_seg_id   ON tmh18.road_classification (seg_id);
CREATE INDEX idx_rcl_district ON tmh18.road_classification (district);
CREATE INDEX idx_rcl_munic    ON tmh18.road_classification (munic);
CREATE INDEX idx_rcl_km       ON tmh18.road_classification (start_km, end_km);

COMMENT ON TABLE  tmh18.road_classification         IS 'TMH18 CD5.0 Table 9 — Road Classification File (.rcl)';
COMMENT ON COLUMN tmh18.road_classification.seg_id  IS 'Unique segment ID: [ROAD_ID]_00000 where 00000 = start in metres, left-zero-padded';
COMMENT ON COLUMN tmh18.road_classification.status  IS '1=Current, 2=To be verified, 3=Under construction, 4=Planned, 5=Upgrade to Paved, 6=Closed, 7=Inaccessible';


-- =============================================================================
-- SECTION 4: LANE CONFIGURATION TABLE
-- Source: TMH18 CD5.0 Table 10 — Lane Configuration Information
-- File extension: .lan
-- Lane Segment ID format: [ROAD_ID]_[LANE_CODE]_00000
-- =============================================================================

CREATE TABLE tmh18.lane_configuration (

    pk              BIGSERIAL    PRIMARY KEY,

    -- TMH18 Table 10 fields
    lane_seg_id     VARCHAR(60)  UNIQUE NOT NULL,  -- [ROAD_ID]_[LANE_CODE]_00000
    lane_code       VARCHAR(4)   NOT NULL,         -- P1, S1, PS, SS, PF, SF etc.
    auth_id         VARCHAR(5)   NOT NULL
                    REFERENCES reference.auth_ids(auth_id),
    road_id         VARCHAR(50)  NOT NULL,
    start_km        NUMERIC(6,3) NOT NULL,
    end_km          NUMERIC(6,3) NOT NULL,
    lane_width      NUMERIC(4,2),                  -- metres, format 99.99
    cl_offset       NUMERIC(5,2),                  -- offset from centre line, metres
    shoulder_type   VARCHAR(20)
                    CHECK (shoulder_type IN ('GRAVEL','PAVED','TALL GRASS')),
    start_longitude NUMERIC(23,20),
    start_latitude  NUMERIC(23,20),
    start_date      DATE         NOT NULL,
    end_date        DATE,

    CONSTRAINT chk_lan_km CHECK (end_km > start_km)
);

CREATE INDEX idx_lan_road_id  ON tmh18.lane_configuration (road_id);
CREATE INDEX idx_lan_km       ON tmh18.lane_configuration (start_km, end_km);
CREATE INDEX idx_lan_lane     ON tmh18.lane_configuration (lane_code);

COMMENT ON TABLE  tmh18.lane_configuration              IS 'TMH18 CD5.0 Table 10 — Lane Configuration File (.lan)';
COMMENT ON COLUMN tmh18.lane_configuration.lane_code    IS 'P=Primary direction, S=Secondary direction. F=fast shoulder, S=slow shoulder. e.g. P1, S2, PS, SS';
COMMENT ON COLUMN tmh18.lane_configuration.cl_offset    IS 'Offset of nearest side of lane from centre line (metres)';
COMMENT ON COLUMN tmh18.lane_configuration.shoulder_type IS 'Populated only for shoulder lanes: GRAVEL, PAVED, TALL GRASS';


-- =============================================================================
-- SECTION 5: TRAFFIC LINK VOLUME TABLE
-- Source: TMH18 CD5.0 Table 11 — Traffic Link Volume
-- File extension: .adt
-- =============================================================================

CREATE TABLE tmh18.traffic_volume (

    pk              BIGSERIAL    PRIMARY KEY,

    -- TMH18 Table 11 fields
    auth_id         VARCHAR(5)   NOT NULL
                    REFERENCES reference.auth_ids(auth_id),
    road_id         VARCHAR(50)  NOT NULL,
    lane_code       VARCHAR(4),                    -- optional
    start_km        NUMERIC(6,3) NOT NULL,
    end_km          NUMERIC(6,3) NOT NULL,
    dt_lst_cnt      DATE         NOT NULL,         -- date of last count
    adt_tot_light   INTEGER,                       -- Total light vehicles incl. cars & minibus
    adt_m           INTEGER,                       -- Minibus (sub-class of light)
    adt_tot_heavy   INTEGER,                       -- Total heavy vehicles
    adt_b           INTEGER,                       -- Bus (sub-class of heavy)
    adt_ts          INTEGER,                       -- Truck short (sub-class of heavy)
    adt_tm          INTEGER,                       -- Truck medium (sub-class of heavy)
    adt_tl          INTEGER,                       -- Truck long (sub-class of heavy)
    adt             INTEGER,                       -- Total ADT = light + heavy
    start_longitude NUMERIC(12,9),
    start_latitude  NUMERIC(12,9),
    from_node       VARCHAR(100),
    to_node         VARCHAR(100),
    from_node_type  VARCHAR(20),
    to_node_type    VARCHAR(20),

    CONSTRAINT chk_adt_km     CHECK (end_km > start_km),
    CONSTRAINT chk_adt_total  CHECK (adt IS NULL OR
                                     adt = COALESCE(adt_tot_light,0) + COALESCE(adt_tot_heavy,0)
                                     OR adt > 0)
);

CREATE INDEX idx_adt_road_id ON tmh18.traffic_volume (road_id);
CREATE INDEX idx_adt_km      ON tmh18.traffic_volume (start_km, end_km);
CREATE INDEX idx_adt_date    ON tmh18.traffic_volume (dt_lst_cnt);

COMMENT ON TABLE  tmh18.traffic_volume              IS 'TMH18 CD5.0 Table 11 — Traffic Link Volume (.adt)';
COMMENT ON COLUMN tmh18.traffic_volume.adt_m        IS 'Minibus count — already included in adt_tot_light, do not double-count';
COMMENT ON COLUMN tmh18.traffic_volume.adt_b        IS 'Bus count — already included in adt_tot_heavy; if counted electronically, include in adt_tm';
COMMENT ON COLUMN tmh18.traffic_volume.adt          IS 'Grand total: adt_tot_light + adt_tot_heavy';


-- =============================================================================
-- SECTION 6: FLEXIBLE PAVEMENT VISUAL CONDITION
-- Source: TMH18 CD5.0 Table 13 (see TMH9 Part B for full specification)
-- File extension: .flx
-- Standard segment length: 2.0 km rural, block lengths (max 0.5 km) urban
-- =============================================================================

CREATE TABLE condition.flex_condition (

    pk                      BIGSERIAL    PRIMARY KEY,

    -- Base fields (TMH18 Section 1.7)
    auth_id                 VARCHAR(5)   NOT NULL
                            REFERENCES reference.auth_ids(auth_id),
    road_id                 VARCHAR(50)  NOT NULL,
    lane_code               VARCHAR(4),
    start_km                NUMERIC(6,3) NOT NULL,
    end_km                  NUMERIC(6,3) NOT NULL,
    measure_date            TIMESTAMP    NOT NULL,

    -- Physical parameters
    terr_class              VARCHAR(1)   CHECK (terr_class IN ('F','R','M')),
    gradient                VARCHAR(1)   CHECK (gradient IN ('F','M','S')),
    road_width              NUMERIC(4,1),

    -- Condition Indices
    vci                     NUMERIC(4,1),         -- Visual Condition Index
    rci                     NUMERIC(4,1),         -- Reseal Condition Index
    mni                     NUMERIC(4,1),         -- Maintenance Need Index
    sci                     NUMERIC(4,1),         -- Surface Condition Index
    stci                    NUMERIC(4,1),         -- Structural Condition Index
    fci                     NUMERIC(4,1),         -- Functional Condition Index
    cci                     NUMERIC(4,1),         -- Crack Condition Index

    -- Engineering Assessment: Surfacing (TRH14 codes)
    surface                 VARCHAR(2)
                            REFERENCES reference.surfacing_types(code),
    texture                 VARCHAR(2)   CHECK (texture IN ('F','FM','M','MC','C','V')),
    voids                   VARCHAR(1)   CHECK (voids IN ('N','F','M','V')),

    -- Surfacing defects
    surface_failure_deg     SMALLINT     CHECK (surface_failure_deg BETWEEN 0 AND 5),
    surface_failure_ext     SMALLINT     CHECK (surface_failure_ext BETWEEN 0 AND 5),
    surface_failpatch_deg   SMALLINT     CHECK (surface_failpatch_deg BETWEEN 0 AND 5),
    surface_failpatch_ext   SMALLINT     CHECK (surface_failpatch_ext BETWEEN 0 AND 5),
    surface_crack_deg       SMALLINT     CHECK (surface_crack_deg BETWEEN 0 AND 5),
    surface_crack_ext       SMALLINT     CHECK (surface_crack_ext BETWEEN 0 AND 5),
    aggr_loss_deg           SMALLINT     CHECK (aggr_loss_deg BETWEEN 0 AND 5),
    aggr_loss_ext           SMALLINT     CHECK (aggr_loss_ext BETWEEN 0 AND 5),
    aggr_loss_act           VARCHAR(1)   CHECK (aggr_loss_act IN ('A','N')),
    binder_condition_deg    SMALLINT     CHECK (binder_condition_deg BETWEEN 0 AND 5),
    binder_condition_ext    SMALLINT     CHECK (binder_condition_ext BETWEEN 0 AND 5),
    bleeding_deg            SMALLINT     CHECK (bleeding_deg BETWEEN 0 AND 5),
    bleeding_ext            SMALLINT     CHECK (bleeding_ext BETWEEN 0 AND 5),
    surf_deform_deg         SMALLINT     CHECK (surf_deform_deg BETWEEN 0 AND 5),
    surf_deform_ext         SMALLINT     CHECK (surf_deform_ext BETWEEN 0 AND 5),

    -- Engineering Assessment: Structural
    block_crack_deg         SMALLINT     CHECK (block_crack_deg BETWEEN 0 AND 5),
    block_crack_ext         SMALLINT     CHECK (block_crack_ext BETWEEN 0 AND 5),
    long_crack_deg          SMALLINT     CHECK (long_crack_deg BETWEEN 0 AND 5),
    long_crack_ext          SMALLINT     CHECK (long_crack_ext BETWEEN 0 AND 5),
    long_crack_type         VARCHAR(1)   CHECK (long_crack_type IN ('S','L')),
    transverse_crack_deg    SMALLINT     CHECK (transverse_crack_deg BETWEEN 0 AND 5),
    transverse_crack_ext    SMALLINT     CHECK (transverse_crack_ext BETWEEN 0 AND 5),
    crocodile_crack_deg     SMALLINT     CHECK (crocodile_crack_deg BETWEEN 0 AND 5),
    crocodile_crack_ext     SMALLINT     CHECK (crocodile_crack_ext BETWEEN 0 AND 5),
    pumping_deg             SMALLINT     CHECK (pumping_deg BETWEEN 0 AND 5),
    pumping_ext             SMALLINT     CHECK (pumping_ext BETWEEN 0 AND 5),
    rutting_deg             SMALLINT     CHECK (rutting_deg BETWEEN 0 AND 5),
    rutting_ext             SMALLINT     CHECK (rutting_ext BETWEEN 0 AND 5),
    undulation_deg          SMALLINT     CHECK (undulation_deg BETWEEN 0 AND 5),
    undulation_ext          SMALLINT     CHECK (undulation_ext BETWEEN 0 AND 5),
    patching_deg            SMALLINT     CHECK (patching_deg BETWEEN 0 AND 5),
    patching_ext            SMALLINT     CHECK (patching_ext BETWEEN 0 AND 5),
    potholes_deg            SMALLINT     CHECK (potholes_deg BETWEEN 0 AND 5),
    potholes_ext            SMALLINT     CHECK (potholes_ext BETWEEN 0 AND 5),
    failures_deg            SMALLINT     CHECK (failures_deg BETWEEN 0 AND 5),
    failures_ext            SMALLINT     CHECK (failures_ext BETWEEN 0 AND 5),

    -- Functional Assessment: Riding Quality
    riding_qual_deg         SMALLINT     CHECK (riding_qual_deg BETWEEN 0 AND 5),
    rqual_prob_hole         VARCHAR(1)   CHECK (rqual_prob_hole IN ('Y','N')),
    rqual_prob_patch        VARCHAR(1)   CHECK (rqual_prob_patch IN ('Y','N')),
    rqual_prob_undul        VARCHAR(1)   CHECK (rqual_prob_undul IN ('Y','N')),
    rqual_prob_uneven       VARCHAR(1)   CHECK (rqual_prob_uneven IN ('Y','N')),
    rqual_prob_corr         VARCHAR(1)   CHECK (rqual_prob_corr IN ('Y','N')),

    -- Functional Assessment: Skid Resistance
    skid_resistance_deg     SMALLINT     CHECK (skid_resistance_deg BETWEEN 0 AND 5),
    skid_prob_bleed         VARCHAR(1)   CHECK (skid_prob_bleed IN ('Y','N')),
    skid_prob_polish        VARCHAR(1)   CHECK (skid_prob_polish IN ('Y','N')),

    -- Functional Assessment: Drainage
    drainage_surf           VARCHAR(1)   CHECK (drainage_surf IN ('A','I','N')),
    drain_prob_rut          VARCHAR(1)   CHECK (drain_prob_rut IN ('Y','N')),
    drain_prob_should       VARCHAR(1)   CHECK (drain_prob_should IN ('Y','N')),
    drain_prob_align        VARCHAR(1)   CHECK (drain_prob_align IN ('Y','N')),
    drain_prob_side         VARCHAR(1)   CHECK (drain_prob_side IN ('Y','N')),

    -- Unpaved Shoulder Condition
    unpaved_shoulder        VARCHAR(1)   CHECK (unpaved_shoulder IN ('N','S','I','U')),
    unpaved_prob_eroded     VARCHAR(1)   CHECK (unpaved_prob_eroded IN ('Y','N')),
    unpaved_prob_ogrown     VARCHAR(1)   CHECK (unpaved_prob_ogrown IN ('Y','N')),
    unpaved_prob_inclined   VARCHAR(1)   CHECK (unpaved_prob_inclined IN ('Y','N')),
    unpaved_prob_2high      VARCHAR(1)   CHECK (unpaved_prob_2high IN ('Y','N')),
    unpaved_prob_2narrow    VARCHAR(1)   CHECK (unpaved_prob_2narrow IN ('Y','N')),

    -- Edge Defects
    edge_break_deg          SMALLINT     CHECK (edge_break_deg BETWEEN 0 AND 5),
    edge_break_ext          SMALLINT     CHECK (edge_break_ext BETWEEN 0 AND 5),
    edge_cracks_deg         SMALLINT     CHECK (edge_cracks_deg BETWEEN 0 AND 5),
    edge_cracks_ext         SMALLINT     CHECK (edge_cracks_ext BETWEEN 0 AND 5),
    edge_dropoff_deg        SMALLINT     CHECK (edge_dropoff_deg BETWEEN 0 AND 5),
    edge_dropoff_ext        SMALLINT     CHECK (edge_dropoff_ext BETWEEN 0 AND 5),

    -- Overall
    opc                     SMALLINT     CHECK (opc BETWEEN 1 AND 5),

    -- Other Problems
    other_prob_crossings    VARCHAR(1)   CHECK (other_prob_crossings IN ('Y','N')),
    other_prob_trees        VARCHAR(1)   CHECK (other_prob_trees IN ('Y','N')),
    other_prob_moles        VARCHAR(1)   CHECK (other_prob_moles IN ('Y','N')),
    other_prob_damage       VARCHAR(1)   CHECK (other_prob_damage IN ('Y','N')),

    -- Comments and GPS
    comments                VARCHAR(100),
    start_longitude         NUMERIC(23,20),
    start_latitude          NUMERIC(23,20),

    CONSTRAINT chk_flx_km   CHECK (end_km > start_km)
);

CREATE INDEX idx_flx_road_id ON condition.flex_condition (road_id);
CREATE INDEX idx_flx_km      ON condition.flex_condition (start_km, end_km);
CREATE INDEX idx_flx_date    ON condition.flex_condition (measure_date);
CREATE INDEX idx_flx_vci     ON condition.flex_condition (vci);

COMMENT ON TABLE condition.flex_condition IS 'TMH18 CD5.0 Table 13 — Flexible Pavement Visual Condition (.flx). See TMH9 Part B.';


-- =============================================================================
-- SECTION 7: CONCRETE VISUAL CONDITION
-- Source: TMH18 CD5.0 Table 15 (see TMH9 Part C)
-- File extension: .con
-- Standard segment length: 0.2 km rural and urban
-- =============================================================================

CREATE TABLE condition.concrete_condition (

    pk                      BIGSERIAL    PRIMARY KEY,

    -- Base fields
    auth_id                 VARCHAR(5)   NOT NULL
                            REFERENCES reference.auth_ids(auth_id),
    road_id                 VARCHAR(50)  NOT NULL,
    lane_code               VARCHAR(4),
    start_km                NUMERIC(6,3) NOT NULL,
    end_km                  NUMERIC(6,3) NOT NULL,
    terr_class              VARCHAR(1)   CHECK (terr_class IN ('F','R','M')),
    gradient                VARCHAR(1)   CHECK (gradient IN ('F','M','S')),
    road_width              NUMERIC(4,2),
    measure_date            TIMESTAMP    NOT NULL,
    surf_type               VARCHAR(5)   NOT NULL
                            CHECK (surf_type IN ('CJP','DJP','CRC','UTCP','JRCP'))
                            REFERENCES reference.surface_types(code),

    -- Condition Indices
    vci                     NUMERIC(4,1),
    rci                     NUMERIC(4,1),
    mni                     NUMERIC(4,1),
    sci                     NUMERIC(4,1),
    stci                    NUMERIC(4,1),
    fci                     NUMERIC(4,1),
    cci                     NUMERIC(4,1),

    -- Structural Defects
    random_crack_deg        SMALLINT     CHECK (random_crack_deg BETWEEN 0 AND 5),
    random_crack_ext        SMALLINT     CHECK (random_crack_ext BETWEEN 0 AND 5),
    transverse_crack_deg    SMALLINT     CHECK (transverse_crack_deg BETWEEN 0 AND 5),
    transverse_crack_ext    SMALLINT     CHECK (transverse_crack_ext BETWEEN 0 AND 5),
    long_crack_deg          SMALLINT     CHECK (long_crack_deg BETWEEN 0 AND 5),
    long_crack_ext          SMALLINT     CHECK (long_crack_ext BETWEEN 0 AND 5),
    corner_crack_deg        SMALLINT     CHECK (corner_crack_deg BETWEEN 0 AND 5),
    corner_crack_ext        SMALLINT     CHECK (corner_crack_ext BETWEEN 0 AND 5),
    cluster_crack_deg       SMALLINT     CHECK (cluster_crack_deg BETWEEN 0 AND 5),
    cluster_crack_ext       SMALLINT     CHECK (cluster_crack_ext BETWEEN 0 AND 5),
    pumping_deg             SMALLINT     CHECK (pumping_deg BETWEEN 0 AND 5),
    pumping_ext             SMALLINT     CHECK (pumping_ext BETWEEN 0 AND 5),
    joint_seal_deg          SMALLINT     CHECK (joint_seal_deg BETWEEN 0 AND 5),
    joint_seal_ext          SMALLINT     CHECK (joint_seal_ext BETWEEN 0 AND 5),
    fault_deg               SMALLINT     CHECK (fault_deg BETWEEN 0 AND 5),
    faul_ext                SMALLINT     CHECK (faul_ext BETWEEN 0 AND 5),
    undulation_deg          SMALLINT     CHECK (undulation_deg BETWEEN 0 AND 5),
    undulation_ext          SMALLINT     CHECK (undulation_ext BETWEEN 0 AND 5),
    punch_deg               SMALLINT     CHECK (punch_deg BETWEEN 0 AND 5),
    punch_ext               SMALLINT     CHECK (punch_ext BETWEEN 0 AND 5),
    shattered_deg           SMALLINT     CHECK (shattered_deg BETWEEN 0 AND 5),
    shattered_ext           SMALLINT     CHECK (shattered_ext BETWEEN 0 AND 5),
    patching_deg            SMALLINT     CHECK (patching_deg BETWEEN 0 AND 5),
    patching_ext            SMALLINT     CHECK (patching_ext BETWEEN 0 AND 5),
    texture                 VARCHAR(30),

    -- Functional Assessment
    riding_qual_deg         SMALLINT     CHECK (riding_qual_deg BETWEEN 1 AND 5),
    rqual_prob_punch        VARCHAR(1)   CHECK (rqual_prob_punch IN ('Y','N')),
    rqual_prob_shattered    VARCHAR(1)   CHECK (rqual_prob_shattered IN ('Y','N')),
    rqual_prob_patch        VARCHAR(1)   CHECK (rqual_prob_patch IN ('Y','N')),
    rqual_prob_undul        VARCHAR(1)   CHECK (rqual_prob_undul IN ('Y','N')),
    rqual_prob_fault        VARCHAR(1)   CHECK (rqual_prob_fault IN ('Y','N')),
    skid_resistance_deg     SMALLINT     CHECK (skid_resistance_deg BETWEEN 1 AND 5),
    drainage_surf           VARCHAR(13)  CHECK (drainage_surf IN ('A','I','X')),
    drain_prob_rut          VARCHAR(1)   CHECK (drain_prob_rut IN ('Y','N')),
    drain_prob_should       VARCHAR(1)   CHECK (drain_prob_should IN ('Y','N')),
    drain_prob_align        VARCHAR(1)   CHECK (drain_prob_align IN ('Y','N')),
    drain_prob_side         VARCHAR(1)   CHECK (drain_prob_side IN ('Y','N')),
    unpaved_shoulder        VARCHAR(1)   CHECK (unpaved_shoulder IN ('N','S','I','U')),
    unpaved__prob_eroded    VARCHAR(1)   CHECK (unpaved__prob_eroded IN ('Y','N')),
    unpaved__prob_wearing   VARCHAR(1)   CHECK (unpaved__prob_wearing IN ('Y','N')),
    unpaved__prob_inclined  VARCHAR(1)   CHECK (unpaved__prob_inclined IN ('Y','N')),
    unpaved__prob_ogrown    VARCHAR(1)   CHECK (unpaved__prob_ogrown IN ('Y','N')),
    unpaved__prob_2high     VARCHAR(1)   CHECK (unpaved__prob_2high IN ('Y','N')),
    unpaved__prob_2narrow   VARCHAR(1)   CHECK (unpaved__prob_2narrow IN ('Y','N')),
    opc                     SMALLINT     CHECK (opc BETWEEN 1 AND 5),
    other_prob_crushing     VARCHAR(1)   CHECK (other_prob_crushing IN ('Y','N')),
    other_prob_blowup       VARCHAR(1)   CHECK (other_prob_blowup IN ('Y','N')),
    other_prob_reaction     VARCHAR(1)   CHECK (other_prob_reaction IN ('Y','N')),
    comments                VARCHAR(100),
    start_longitude         NUMERIC(23,20),
    start_latitude          NUMERIC(23,20),

    CONSTRAINT chk_con_km   CHECK (end_km > start_km)
);

CREATE INDEX idx_con_road_id ON condition.concrete_condition (road_id);
CREATE INDEX idx_con_km      ON condition.concrete_condition (start_km, end_km);
CREATE INDEX idx_con_date    ON condition.concrete_condition (measure_date);

COMMENT ON TABLE condition.concrete_condition IS 'TMH18 CD5.0 Table 15 — Concrete Visual Condition Summary (.con). See TMH9 Part C. Segment length: 0.2 km.';


-- =============================================================================
-- SECTION 8: BLOCK PAVEMENT VISUAL CONDITION
-- Source: TMH18 CD5.0 Table 16 (see TMH9 Part D)
-- File extension: .blc
-- Standard segment length: 0.2 km rural and urban
-- =============================================================================

CREATE TABLE condition.block_condition (

    pk                      BIGSERIAL    PRIMARY KEY,

    -- Base fields
    auth_id                 VARCHAR(5)   NOT NULL
                            REFERENCES reference.auth_ids(auth_id),
    road_id                 VARCHAR(50)  NOT NULL,
    lane_code               VARCHAR(4),
    start_km                NUMERIC(6,3) NOT NULL,
    end_km                  NUMERIC(6,3) NOT NULL,
    terr_class              VARCHAR(1)   CHECK (terr_class IN ('F','R','M')),
    gradient                VARCHAR(1)   CHECK (gradient IN ('F','M','S')),
    road_width              NUMERIC(4,2),
    measure_date            TIMESTAMP    NOT NULL,

    -- Block properties
    block_type              VARCHAR(3)   CHECK (block_type IN ('S-A','S-B','S-C')),
    block_lay               VARCHAR(2)   CHECK (block_lay IN ('HB','SB','BW','OT')),
    block_thick             SMALLINT     CHECK (block_thick BETWEEN 50 AND 80),
    chamfers                VARCHAR(2)   CHECK (chamfers IN ('45','R','90')),

    -- Condition Indices
    vci                     NUMERIC(4,1),
    rci                     NUMERIC(4,1),
    mni                     NUMERIC(4,1),
    sci                     NUMERIC(4,1),
    stci                    NUMERIC(4,1),
    fci                     NUMERIC(4,1),
    cci                     NUMERIC(4,1),

    -- Structural Defects
    spalled_crack_deg       SMALLINT     CHECK (spalled_crack_deg BETWEEN 0 AND 5),
    spalled_crack_ext       SMALLINT     CHECK (spalled_crack_ext BETWEEN 0 AND 5),
    surf_integrity_deg      SMALLINT     CHECK (surf_integrity_deg BETWEEN 0 AND 5),
    surf_integrity_ext      SMALLINT     CHECK (surf_integrity_ext BETWEEN 0 AND 5),
    joint_loss_deg          SMALLINT     CHECK (joint_loss_deg BETWEEN 0 AND 5),
    joint_loss_ext          SMALLINT     CHECK (joint_loss_ext BETWEEN 0 AND 5),
    edge_damage_deg         SMALLINT     CHECK (edge_damage_deg BETWEEN 0 AND 5),
    edge_damage_ext         SMALLINT     CHECK (edge_damage_ext BETWEEN 0 AND 5),
    rutting_deg             SMALLINT     CHECK (rutting_deg BETWEEN 0 AND 5),
    rutting_ext             SMALLINT     CHECK (rutting_ext BETWEEN 0 AND 5),
    pot_patch_deg           SMALLINT     CHECK (pot_patch_deg BETWEEN 0 AND 5),
    pot_patc_ext            SMALLINT     CHECK (pot_patc_ext BETWEEN 0 AND 5),
    undulation_deg          SMALLINT     CHECK (undulation_deg BETWEEN 0 AND 5),
    undulation_ext          SMALLINT     CHECK (undulation_ext BETWEEN 0 AND 5),

    -- Functional Assessment
    riding_qual_deg         SMALLINT     CHECK (riding_qual_deg BETWEEN 1 AND 5),
    rqual_prob_patch        VARCHAR(1)   CHECK (rqual_prob_patch IN ('Y','N')),
    rqual_prob_loose        VARCHAR(1)   CHECK (rqual_prob_loose IN ('Y','N')),
    rqual_prob_undul        VARCHAR(1)   CHECK (rqual_prob_undul IN ('Y','N')),
    skid_resistance_deg     SMALLINT     CHECK (skid_resistance_deg BETWEEN 1 AND 5),
    drainage_surf           VARCHAR(13)  CHECK (drainage_surf IN ('A','I','X')),
    drain_prob_profile      VARCHAR(1)   CHECK (drain_prob_profile IN ('Y','N')),
    drain_prob_rut          VARCHAR(1)   CHECK (drain_prob_rut IN ('Y','N')),
    drain_prob_should       VARCHAR(1)   CHECK (drain_prob_should IN ('Y','N')),
    drain_prob_side         VARCHAR(1)   CHECK (drain_prob_side IN ('Y','N')),
    drain_prob_fail         VARCHAR(1)   CHECK (drain_prob_fail IN ('Y','N')),
    unpaved_shoulder        VARCHAR(1)   CHECK (unpaved_shoulder IN ('N','S','I','U')),
    unpaved__prob_eroded    VARCHAR(1)   CHECK (unpaved__prob_eroded IN ('Y','N')),
    unpaved__prob_wearing   VARCHAR(1)   CHECK (unpaved__prob_wearing IN ('Y','N')),
    unpaved__prob_inclined  VARCHAR(1)   CHECK (unpaved__prob_inclined IN ('Y','N')),
    unpaved__prob_ogrown    VARCHAR(1)   CHECK (unpaved__prob_ogrown IN ('Y','N')),
    unpaved__prob_2high     VARCHAR(1)   CHECK (unpaved__prob_2high IN ('Y','N')),
    unpaved__prob_2narrow   VARCHAR(1)   CHECK (unpaved__prob_2narrow IN ('Y','N')),
    opc                     SMALLINT     CHECK (opc BETWEEN 1 AND 5),
    other_prob_trees        VARCHAR(1)   CHECK (other_prob_trees IN ('Y','N')),
    other_prob_moles        VARCHAR(1)   CHECK (other_prob_moles IN ('Y','N')),
    other_prob_damage       VARCHAR(1)   CHECK (other_prob_damage IN ('Y','N')),
    comments                VARCHAR(100),
    start_longitude         NUMERIC(23,20),
    start_latitude          NUMERIC(23,20),

    CONSTRAINT chk_blc_km   CHECK (end_km > start_km)
);

CREATE INDEX idx_blc_road_id ON condition.block_condition (road_id);
CREATE INDEX idx_blc_km      ON condition.block_condition (start_km, end_km);
CREATE INDEX idx_blc_date    ON condition.block_condition (measure_date);

COMMENT ON TABLE condition.block_condition IS 'TMH18 CD5.0 Table 16 — Block Pavement Visual Condition Summary (.blc). See TMH9 Part D. Segment length: 0.2 km.';


-- =============================================================================
-- SECTION 9: UNSURFACED ROAD VISUAL CONDITION
-- Source: TMH18 CD5.0 Table 18 (see TMH9 Part E)
-- File extension: .vgi
-- Standard segment length: 5.0 km rural, block lengths (max 0.5 km) urban
-- =============================================================================

CREATE TABLE condition.unsurfaced_condition (

    pk                          BIGSERIAL    PRIMARY KEY,

    -- Base fields
    auth_id                     VARCHAR(5)   NOT NULL
                                REFERENCES reference.auth_ids(auth_id),
    road_id                     VARCHAR(50)  NOT NULL,
    lane_code                   VARCHAR(4),
    start_km                    NUMERIC(6,3) NOT NULL,
    end_km                      NUMERIC(6,3) NOT NULL,
    terr_class                  VARCHAR(1)   CHECK (terr_class IN ('F','R','M')),
    gradient                    VARCHAR(1)   CHECK (gradient IN ('F','M','S')),
    road_width                  NUMERIC(4,2),
    measure_date                TIMESTAMP    NOT NULL,

    -- Condition Indices
    vci                         NUMERIC(4,1),
    rci                         NUMERIC(4,1),
    mni                         NUMERIC(4,1),
    sci                         NUMERIC(4,1),
    stci                        NUMERIC(4,1),
    fci                         NUMERIC(4,1),
    cci                         NUMERIC(4,1),

    -- Road classification
    road_type                   VARCHAR(1)
                                CHECK (road_type IN ('E','G','T','S')),
    moisture                    VARCHAR(1)   CHECK (moisture IN ('W','M','D')),

    -- Gravel quality
    gravel_quality              SMALLINT     CHECK (gravel_quality BETWEEN 1 AND 5),
    gqual_oversize              VARCHAR(1)   CHECK (gqual_oversize IN ('Y','N')),
    gqual_clay                  VARCHAR(1)   CHECK (gqual_clay IN ('Y','N')),
    gqual_loose                 VARCHAR(1)   CHECK (gqual_loose IN ('Y','N')),
    max_size                    SMALLINT     CHECK (max_size BETWEEN 1 AND 4),
    grading                     VARCHAR(1)   CHECK (grading IN ('C','M','F')),
    plasticity                  VARCHAR(1)   CHECK (plasticity IN ('L','M','H')),
    gravel_quantity             SMALLINT     CHECK (gravel_quantity BETWEEN 1 AND 5),
    exposed_subgrade            VARCHAR(1)   CHECK (exposed_subgrade IN ('N','I','F','C')),
    subgrade_quality            VARCHAR(1)   CHECK (subgrade_quality IN ('G','M','P')),

    -- Defects
    potholes_deg                SMALLINT     CHECK (potholes_deg BETWEEN 0 AND 5),
    potholes_ext                SMALLINT     CHECK (potholes_ext BETWEEN 0 AND 5),
    corrugations_deg            SMALLINT     CHECK (corrugations_deg BETWEEN 0 AND 5),
    corrugations_ext            SMALLINT     CHECK (corrugations_ext BETWEEN 0 AND 5),
    rutting_deg                 SMALLINT     CHECK (rutting_deg BETWEEN 0 AND 5),
    rutting_ext                 SMALLINT     CHECK (rutting_ext BETWEEN 0 AND 5),
    loose_material_deg          SMALLINT     CHECK (loose_material_deg BETWEEN 0 AND 5),
    loose_material_ext          SMALLINT     CHECK (loose_material_ext BETWEEN 0 AND 5),
    stoniness_fix_deg           SMALLINT     CHECK (stoniness_fix_deg BETWEEN 0 AND 5),
    stoniness_fix_ext           SMALLINT     CHECK (stoniness_fix_ext BETWEEN 0 AND 5),
    stoniness_loose_deg         SMALLINT     CHECK (stoniness_loose_deg BETWEEN 0 AND 5),
    stoniness_loose_ext         SMALLINT     CHECK (stoniness_loose_ext BETWEEN 0 AND 5),
    erosion_long_deg            SMALLINT     CHECK (erosion_long_deg BETWEEN 0 AND 5),
    erosion_long_ext            SMALLINT     CHECK (erosion_long_ext BETWEEN 0 AND 5),
    erosion_trans_deg           SMALLINT     CHECK (erosion_trans_deg BETWEEN 0 AND 5),
    erosion_trans_ext           SMALLINT     CHECK (erosion_trans_ext BETWEEN 0 AND 5),

    -- Functional Assessment
    riding_qual_deg             SMALLINT     CHECK (riding_qual_deg BETWEEN 0 AND 5),
    rqual_prob_dform            VARCHAR(1)   CHECK (rqual_prob_dform IN ('Y','N')),
    rqual_prob_hole             VARCHAR(1)   CHECK (rqual_prob_hole IN ('Y','N')),
    rqual_prob_stoniness        VARCHAR(1)   CHECK (rqual_prob_stoniness IN ('Y','N')),
    rqual_prob_rocks            VARCHAR(1)   CHECK (rqual_prob_rocks IN ('Y','N')),
    rqual_prob_corr             VARCHAR(1)   CHECK (rqual_prob_corr IN ('Y','N')),
    rqual_prob_loose            VARCHAR(1)   CHECK (rqual_prob_loose IN ('Y','N')),
    rqual_prob_ruts             VARCHAR(1)   CHECK (rqual_prob_ruts IN ('Y','N')),
    rqual_prob_erosion          VARCHAR(1)   CHECK (rqual_prob_erosion IN ('Y','N')),
    trafficability_deg          SMALLINT     CHECK (trafficability_deg BETWEEN 0 AND 5),
    traffic_prob_steep          VARCHAR(1)   CHECK (traffic_prob_steep IN ('Y','N')),
    traffic_prob_rocky          VARCHAR(1)   CHECK (traffic_prob_rocky IN ('Y','N')),
    traffic_prob_vegetation     VARCHAR(1)   CHECK (traffic_prob_vegetation IN ('Y','N')),
    traffic_prob_drainage       VARCHAR(1)   CHECK (traffic_prob_drainage IN ('Y','N')),
    safety_deg                  SMALLINT     CHECK (safety_deg BETWEEN 0 AND 5),
    safety_prob_dust            VARCHAR(1)   CHECK (safety_prob_dust IN ('Y','N')),
    safety_prob_slip            VARCHAR(1)   CHECK (safety_prob_slip IN ('Y','N')),
    safety_prob_skid            VARCHAR(1)   CHECK (safety_prob_skid IN ('Y','N')),
    safety_prob_drainage        VARCHAR(1)   CHECK (safety_prob_drainage IN ('Y','N')),
    transvers_profile           SMALLINT     CHECK (transvers_profile BETWEEN 0 AND 5),
    profile_prob_windrows       VARCHAR(1)   CHECK (profile_prob_windrows IN ('Y','N')),
    profile_prob_rutting        VARCHAR(1)   CHECK (profile_prob_rutting IN ('Y','N')),
    profile_prob_shape          VARCHAR(1)   CHECK (profile_prob_shape IN ('Y','N')),
    profile_prob_level          VARCHAR(1)   CHECK (profile_prob_level IN ('Y','N')),
    drainage_side               SMALLINT     CHECK (drainage_side BETWEEN 0 AND 5),
    drain_prob_culverts         VARCHAR(1)   CHECK (drain_prob_culverts IN ('Y','N')),
    drain_prob_side             VARCHAR(1)   CHECK (drain_prob_side IN ('Y','N')),
    drain_prob_mitre            VARCHAR(1)   CHECK (drain_prob_mitre IN ('Y','N')),
    drain_prob_level            VARCHAR(1)   CHECK (drain_prob_level IN ('Y','N')),
    opc                         SMALLINT     CHECK (opc BETWEEN 0 AND 5),
    other_prob_trees            VARCHAR(1)   CHECK (other_prob_trees IN ('Y','N')),
    other_prob_moles            VARCHAR(1)   CHECK (other_prob_moles IN ('Y','N')),
    other_prob_damage           VARCHAR(1)   CHECK (other_prob_damage IN ('Y','N')),
    comments                    VARCHAR(100),
    start_longitude             NUMERIC(23,20),
    start_latitude              NUMERIC(23,20),

    CONSTRAINT chk_vgi_km   CHECK (end_km > start_km)
);

CREATE INDEX idx_vgi_road_id ON condition.unsurfaced_condition (road_id);
CREATE INDEX idx_vgi_km      ON condition.unsurfaced_condition (start_km, end_km);
CREATE INDEX idx_vgi_date    ON condition.unsurfaced_condition (measure_date);

COMMENT ON TABLE condition.unsurfaced_condition IS 'TMH18 CD5.0 Table 18 — Unsurfaced Road Visual Condition Summary (.vgi). See TMH9 Part E. Segment length: 5.0 km rural.';


-- =============================================================================
-- SECTION 10: COMBINED INSTRUMENT DATA
-- Source: TMH18 CD5.0 Table 19 — Roughness, Rutting, Texture
-- File extension: .cid
-- All three measurement types captured simultaneously at same location
-- =============================================================================

CREATE TABLE condition.combined_instrument (

    pk              BIGSERIAL    PRIMARY KEY,

    -- Base fields
    auth_id         VARCHAR(5)   NOT NULL
                    REFERENCES reference.auth_ids(auth_id),
    road_id         VARCHAR(50)  NOT NULL,
    lane_code       VARCHAR(4),
    start_km        NUMERIC(6,3) NOT NULL,
    end_km          NUMERIC(6,3) NOT NULL,
    test_date       TIMESTAMP    NOT NULL,

    -- Roughness: IRI (International Roughness Index) m/km
    iri_l_avg       NUMERIC(3,1),  -- Average IRI left wheel path
    iri_r_avg       NUMERIC(3,1),  -- Average IRI right wheel path
    iri_l_stdv      NUMERIC(3,1),  -- IRI left standard deviation
    iri_r_stdv      NUMERIC(3,1),  -- IRI right standard deviation
    hri_avg         NUMERIC(3,1),  -- Average HRI
    hri_stdv        NUMERIC(3,1),  -- HRI standard deviation

    -- Rutting (mm)
    rut_l_avg       NUMERIC(4,1),  -- Average rut left wheel path
    rut_r_avg       NUMERIC(4,1),  -- Average rut right wheel path
    rut_l_stdv      NUMERIC(4,1),  -- Rut std dev left
    rut_r_stdv      NUMERIC(4,1),  -- Rut std dev right

    -- Texture: MPD (Mean Profile Depth)
    mpd_l_avg       NUMERIC(3,2),  -- Average MPD left wheel path
    mpd_c_avg       NUMERIC(3,2),  -- Average MPD centre
    mpd_r_avg       NUMERIC(3,2),  -- Average MPD right wheel path
    mpd_stdv_l      NUMERIC(3,2),  -- MPD std dev left
    mpd_stdv_c      NUMERIC(3,2),  -- MPD std dev centre
    mpd_stdv_r      NUMERIC(3,2),  -- MPD std dev right

    start_longitude NUMERIC(23,20),
    start_latitude  NUMERIC(23,20),

    CONSTRAINT chk_cid_km   CHECK (end_km > start_km)
);

CREATE INDEX idx_cid_road_id ON condition.combined_instrument (road_id);
CREATE INDEX idx_cid_km      ON condition.combined_instrument (start_km, end_km);
CREATE INDEX idx_cid_date    ON condition.combined_instrument (test_date);

COMMENT ON TABLE condition.combined_instrument IS 'TMH18 CD5.0 Table 19 — Combined Instrument Data (.cid). Roughness (IRI), Rutting and Texture (MPD) captured simultaneously.';


-- =============================================================================
-- SECTION 11: FWD DEFLECTION BOWL DATA
-- Source: TMH18 CD5.0 Table 20 — Normalised Deflection Bowl Data
-- File extension: .fwd
-- BLI = D0-D300 (basecourse), MLI = D300-D600 (subbase), LLI = D600-D900 (subgrade)
-- =============================================================================

CREATE TABLE condition.fwd_deflection (

    pk              BIGSERIAL    PRIMARY KEY,

    -- Base fields
    auth_id         VARCHAR(5)   NOT NULL
                    REFERENCES reference.auth_ids(auth_id),
    road_id         VARCHAR(50)  NOT NULL,
    lane_code       VARCHAR(4),
    survey_km       NUMERIC(6,3) NOT NULL,         -- point measurement, not range
    date            TIMESTAMP    NOT NULL,

    -- Environmental conditions
    temp_air        NUMERIC(3,1),                  -- Air temperature (°C), format 99.9
    temp_surface    NUMERIC(3,1),                  -- Surface temperature (°C)
    peak_load       NUMERIC(4,2),                  -- Load applied (kN), format 99.99
    drop_num        SMALLINT,                       -- Drop number

    -- Deflection measurements (nanometres) at sensor offsets from load centre
    def_0           INTEGER,                       -- D0: load plate centre
    def_200         INTEGER,                       -- D200: 200mm from centre
    def_300         INTEGER,                       -- D300: 300mm from centre
    def_400         INTEGER,                       -- D400
    def_450         INTEGER,                       -- D450
    def_500         INTEGER,                       -- D500
    def_600         INTEGER,                       -- D600
    def_750         INTEGER,                       -- D750
    def_900         INTEGER,                       -- D900
    def_1200        INTEGER,                       -- D1200
    def_1500        INTEGER,                       -- D1500
    def_1800        INTEGER,                       -- D1800
    def_2100        INTEGER,                       -- D2100
    pulse_duration  NUMERIC(4,2),                  -- Pulse time (ms), format 99.99

    -- Structural layer indices (nanometres)
    bli             INTEGER,    -- Base Layer Index (D0-D300): basecourse performance
    mli             INTEGER,    -- Middle Layer Index (D300-D600): subbase performance
    lli             INTEGER,    -- Lower Layer Index (D600-D900): subgrade performance

    start_longitude NUMERIC(23,20),
    start_latitude  NUMERIC(23,20)
);

CREATE INDEX idx_fwd_road_id ON condition.fwd_deflection (road_id);
CREATE INDEX idx_fwd_km      ON condition.fwd_deflection (survey_km);
CREATE INDEX idx_fwd_date    ON condition.fwd_deflection (date);

COMMENT ON TABLE condition.fwd_deflection IS 'TMH18 CD5.0 Table 20 — FWD Normalised Deflection Bowl Data (.fwd). BLI=D0-D300 (basecourse), MLI=D300-D600 (subbase), LLI=D600-D900 (subgrade).';


-- =============================================================================
-- SECTION 12: REPORTING VIEWS
-- Joins all key TMH18 tables for QGIS, dashboards and national submissions
-- =============================================================================

-- Master network summary view
CREATE VIEW reporting.network_summary AS
SELECT
    n.auth_id,
    a.authority,
    n.road_id,
    n.route,
    n.rdda_id,
    n.auth_rd_id,
    n.auth_rddir                            AS direction,
    n.risfsa_cls,
    r.description                           AS risfsa_description,
    r.road_env,
    n.surf_type,
    s.description                           AS surface_description,
    s.category                              AS surface_category,
    n.start_km,
    n.end_km,
    (n.end_km - n.start_km)                 AS length_km,
    n.start_date,
    n.end_date,
    CASE WHEN n.end_date IS NULL
         THEN 'ACTIVE' ELSE 'SUPERSEDED' END AS network_status,
    n.start_desc,
    n.end_desc,
    n.geom
FROM tmh18.network n
JOIN reference.auth_ids       a ON a.auth_id   = n.auth_id
LEFT JOIN reference.risfsa_classes r ON r.code = n.risfsa_cls
LEFT JOIN reference.surface_types  s ON s.code = n.surf_type
WHERE n.end_date IS NULL;

COMMENT ON VIEW reporting.network_summary IS 'Active network with authority, RISFSA and surface descriptions. Connect directly in QGIS as PostGIS layer.';

-- Road condition by district/municipality
CREATE VIEW reporting.condition_by_munic AS
SELECT
    rc.district,
    rc.munic,
    rc.auth_id,
    n.auth_rd_id,
    n.risfsa_cls,
    n.surf_type,
    SUM(rc.end_km - rc.start_km)                       AS total_km,
    COUNT(fc.pk)                                        AS assessed_sections,
    ROUND(AVG(fc.vci)::NUMERIC, 1)                     AS avg_vci,
    ROUND(AVG(fc.opc)::NUMERIC, 1)                     AS avg_opc,
    COUNT(CASE WHEN fc.vci < 2 THEN 1 END)             AS very_poor_sections,
    COUNT(CASE WHEN fc.vci BETWEEN 2 AND 4 THEN 1 END) AS poor_sections,
    COUNT(CASE WHEN fc.vci >= 6 THEN 1 END)            AS good_sections
FROM tmh18.road_classification rc
JOIN tmh18.network n
    ON n.road_id = rc.road_id AND n.end_date IS NULL
LEFT JOIN condition.flex_condition fc
    ON fc.road_id = rc.road_id
    AND fc.start_km >= rc.start_km
    AND fc.end_km   <= rc.end_km
GROUP BY rc.district, rc.munic, rc.auth_id,
         n.auth_rd_id, n.risfsa_cls, n.surf_type
ORDER BY avg_vci NULLS LAST;

COMMENT ON VIEW reporting.condition_by_munic IS 'Aggregated pavement condition by district and local municipality for RRAMS reporting.';

-- Latest condition per road segment (for QGIS map display)
CREATE VIEW reporting.latest_flex_condition AS
SELECT DISTINCT ON (rc.seg_id)
    rc.seg_id,
    rc.road_id,
    rc.auth_id,
    rc.district,
    rc.munic,
    rc.start_km,
    rc.end_km,
    rc.road_type,
    rc.road_width,
    rc.nr_lanes,
    rc.terr_class,
    fc.measure_date,
    fc.vci,
    fc.opc,
    fc.surface,
    fc.potholes_deg,
    fc.rutting_deg,
    fc.crocodile_crack_deg,
    CASE
        WHEN fc.vci >= 8   THEN 'VERY GOOD'
        WHEN fc.vci >= 6   THEN 'GOOD'
        WHEN fc.vci >= 4   THEN 'FAIR'
        WHEN fc.vci >= 2   THEN 'POOR'
        WHEN fc.vci IS NOT NULL THEN 'VERY POOR'
        ELSE 'NOT ASSESSED'
    END                          AS vci_category,
    CASE
        WHEN fc.vci >= 8   THEN '#00AA00'
        WHEN fc.vci >= 6   THEN '#88CC00'
        WHEN fc.vci >= 4   THEN '#FFAA00'
        WHEN fc.vci >= 2   THEN '#FF5500'
        WHEN fc.vci IS NOT NULL THEN '#CC0000'
        ELSE '#AAAAAA'
    END                          AS map_colour,
    rc.geom
FROM tmh18.road_classification rc
LEFT JOIN condition.flex_condition fc
    ON fc.road_id   = rc.road_id
    AND fc.start_km >= rc.start_km
    AND fc.end_km   <= rc.end_km
ORDER BY rc.seg_id, fc.measure_date DESC;

COMMENT ON VIEW reporting.latest_flex_condition IS 'Most recent flexible pavement condition per segment with VCI colour coding. Use as styled QGIS layer for condition maps.';


-- =============================================================================
-- SECTION 13: USER ROLES
-- Principle of least privilege — never connect as postgres superuser
-- =============================================================================

-- Read-only role (reporting tools, QGIS viewers, managers)
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'rrams_readonly') THEN
        CREATE ROLE rrams_readonly;
    END IF;
END $$;
GRANT USAGE ON SCHEMA tmh18, condition, reference, reporting TO rrams_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA tmh18     TO rrams_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA condition TO rrams_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA reference TO rrams_readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA reporting TO rrams_readonly;

-- Editor role (data collectors, QField app, surveyors)
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'rrams_editor') THEN
        CREATE ROLE rrams_editor;
    END IF;
END $$;
GRANT USAGE ON SCHEMA tmh18, condition, reference, reporting TO rrams_editor;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA tmh18     TO rrams_editor;
GRANT SELECT, INSERT, UPDATE ON ALL TABLES IN SCHEMA condition TO rrams_editor;
GRANT SELECT ON ALL TABLES IN SCHEMA reference TO rrams_editor;
GRANT SELECT ON ALL TABLES IN SCHEMA reporting TO rrams_editor;
GRANT USAGE  ON ALL SEQUENCES IN SCHEMA tmh18     TO rrams_editor;
GRANT USAGE  ON ALL SEQUENCES IN SCHEMA condition TO rrams_editor;

-- Admin role (schema management, reference data updates)
DO $$
BEGIN
    IF NOT EXISTS (SELECT FROM pg_roles WHERE rolname = 'rrams_admin') THEN
        CREATE ROLE rrams_admin;
    END IF;
END $$;
GRANT ALL ON ALL TABLES  IN SCHEMA tmh18, condition, reference, reporting TO rrams_admin;
GRANT ALL ON ALL SEQUENCES IN SCHEMA tmh18, condition TO rrams_admin;


-- =============================================================================
-- END OF TMH18 CD5.0 COMPLIANT SCHEMA
-- Tables: 11 | Views: 3 | Reference tables: 7 | Roles: 3
-- Geometry CRS: EPSG:4326 (WGS84) — mandated by TMH18 Section 2.3.2
-- All field names match TMH18 CD5.0 exactly for data exchange compliance
-- =============================================================================

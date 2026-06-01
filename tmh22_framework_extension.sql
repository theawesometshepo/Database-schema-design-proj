-- =============================================================================
-- TMH22 ASSET MANAGEMENT FRAMEWORK TABLES
-- Road Asset Management Manual - Complement to TMH18
-- Adds: Asset Hierarchy, Component Types, Levels of Service, Functional Classes
-- =============================================================================

-- Asset Functional Classes (TMH22 Part B Section B.3.1)
CREATE TABLE reference.asset_functional_classes (
    code        VARCHAR(20)  PRIMARY KEY,
    description VARCHAR(200) NOT NULL,
    asset_type  VARCHAR(50)  NOT NULL
);
INSERT INTO reference.asset_functional_classes VALUES
    ('CARRIAGEWAY',    'Main traffic-bearing surface',              'ROAD'),
    ('SHOULDER',       'Non-traffic bearing edge strip',            'ROAD'),
    ('MEDIAN',         'Central traffic separator',                 'ROAD'),
    ('VERGE',          'Land beyond shoulders',                     'ROAD'),
    ('DRAINAGE',       'Water management systems',                  'DRAINAGE'),
    ('STRUCTURES',     'Bridges, culverts, overpasses',             'STRUCTURES'),
    ('SAFETY_FENCING', 'Guard rails, barriers',                     'SAFETY'),
    ('SIGNAGE',        'Road signs, markings',                      'SIGNAGE'),
    ('LIGHTING',       'Street lights, illumination',               'LIGHTING'),
    ('VEGETATION',     'Trees, grass, landscape',                   'ENVIRONMENT');

-- Asset Component Types (TMH22 Part B Section B.4.2)
CREATE TABLE reference.asset_component_types (
    code        VARCHAR(20)  PRIMARY KEY,
    description VARCHAR(200) NOT NULL,
    functional_class VARCHAR(20)
                     REFERENCES reference.asset_functional_classes(code),
    unit_of_measure VARCHAR(50)
);
INSERT INTO reference.asset_component_types VALUES
    ('SURFACE_COURSE',    'Top layer of pavement',                  'CARRIAGEWAY',    'km'),
    ('BASE_COURSE',       'Base layer under surface',               'CARRIAGEWAY',    'km'),
    ('SUBBASE_COURSE',    'Stabilising layer',                      'CARRIAGEWAY',    'km'),
    ('BRIDGE_DECK',       'Bridge traffic surface',                 'STRUCTURES',     'number'),
    ('CULVERT_PIPE',      'Culvert pipe section',                   'DRAINAGE',       'number'),
    ('GUARD_RAIL',        'Safety barrier section',                 'SAFETY_FENCING', 'metres'),
    ('ROAD_SIGN',         'Individual sign unit',                   'SIGNAGE',        'number'),
    ('EDGE_LINE',         'Lane edge markings',                     'SIGNAGE',        'km'),
    ('STREET_LIGHT',      'Light pole unit',                        'LIGHTING',       'number'),
    ('TREE',              'Individual roadside tree',               'VEGETATION',     'number');

-- Level of Service (TMH22 Part A Section A.3.2 - Stakeholder Requirements)
-- LoS parameters define the minimum acceptable condition
CREATE TABLE reference.level_of_service (
    code              VARCHAR(10)  PRIMARY KEY,
    description       VARCHAR(100) NOT NULL,
    min_vci           NUMERIC(3,1),  -- Minimum Visual Condition Index
    max_defect_pct    NUMERIC(5,1),  -- Maximum defect extent percentage
    max_iri           NUMERIC(4,1),  -- Maximum roughness (m/km)
    functional_class  VARCHAR(50),
    road_class        VARCHAR(15),   -- R1-R5, U1-U6
    applied_to        VARCHAR(100)
);
INSERT INTO reference.level_of_service VALUES
    ('LOS_NATIONAL',   'National Highway Standard',              8.0,  5.0,   3.0,  NULL,           'R1',   'SANRAL National Roads'),
    ('LOS_PROV_MAIN',  'Provincial Main Road',                  7.0,  8.0,   4.0,  NULL,           'R2',   'Provincial Primary Routes'),
    ('LOS_DISTRICT',   'District Road Standard',                6.0,  15.0,  5.0,  NULL,           'R3',   'District Municipality Roads'),
    ('LOS_LOCAL',      'Local Municipality Standard',           5.0,  20.0,  6.0,  NULL,           'R4,R5', 'Local and Access Roads'),
    ('LOS_URBAN_MAIN', 'Urban Main Street',                     7.5,  8.0,   3.5,  'CARRIAGEWAY',  'U1',   'Urban Principal Arterials'),
    ('LOS_URBAN_LOCAL','Urban Local Street',                    6.5,  12.0,  5.0,  'CARRIAGEWAY',  'U5',   'Urban Residential Streets'),
    ('LOS_SAFETY',     'Safety Critical Infrastructure',        8.5,  2.0,   2.0,  'STRUCTURES',   NULL,   'Bridges, Culverts, Critical Assets');

-- Assessment Frequency Matrix (TMH22 Part D Section D.5.3)
-- Defines how often different asset types must be assessed
CREATE TABLE reference.assessment_frequency (
    asset_type        VARCHAR(50)  NOT NULL,
    road_class        VARCHAR(15),            -- NULL = applies to all
    urban_rural       VARCHAR(10),            -- NULL = applies to both
    assessment_type   VARCHAR(50)  NOT NULL,  -- 'VISUAL', 'INSTRUMENT', 'STRUCTURAL'
    frequency_years   SMALLINT     NOT NULL,  -- years between assessments
    frequency_desc    VARCHAR(100),           -- e.g. 'annually', 'every 3 years'
    PRIMARY KEY (asset_type, COALESCE(road_class, 'ALL'), COALESCE(urban_rural, 'ALL'), assessment_type)
);
INSERT INTO reference.assessment_frequency VALUES
    ('CARRIAGEWAY', 'R1',   NULL,  'VISUAL',      1, 'Annually'),
    ('CARRIAGEWAY', 'R2',   NULL,  'VISUAL',      1, 'Annually'),
    ('CARRIAGEWAY', 'R3',   NULL,  'VISUAL',      2, 'Biennial'),
    ('CARRIAGEWAY', 'R4',   NULL,  'VISUAL',      2, 'Biennial'),
    ('CARRIAGEWAY', 'R5',   NULL,  'VISUAL',      3, 'Triennial'),
    ('STRUCTURES',  'R1',   NULL,  'STRUCTURAL',  2, 'Every 2 years'),
    ('STRUCTURES',  NULL,   'URBAN', 'VISUAL',    1, 'Annually'),
    ('DRAINAGE',    NULL,   NULL,  'VISUAL',      3, 'Every 3 years'),
    ('SAFETY_FENCING', NULL, NULL, 'VISUAL',      2, 'Every 2 years'),
    ('SIGNAGE',     NULL,   NULL,  'VISUAL',      1, 'Annually');

-- Defect Severity Scale (TMH22 / TMH9 reference)
-- Standard 0-5 scale with interpretation
CREATE TABLE reference.defect_severity (
    severity_code  SMALLINT     PRIMARY KEY CHECK (severity_code BETWEEN 0 AND 5),
    description    VARCHAR(100) NOT NULL,
    colour_hex     CHAR(7),
    interpretation VARCHAR(200)
);
INSERT INTO reference.defect_severity VALUES
    (0, 'None',          '#00AA00', 'No defects observed'),
    (1, 'Very Slight',   '#88CC00', 'Minimal defects, early stage deterioration'),
    (2, 'Slight',        '#FFAA00', 'Light defects, isolated occurrences'),
    (3, 'Moderate',      '#FF9900', 'Clear defects, scattered distribution'),
    (4, 'Severe',        '#FF5500', 'Significant defects, widespread'),
    (5, 'Very Severe',   '#CC0000', 'Critical condition, major deterioration');

-- Defect Extent Scale (0-5 coverage percentage)
CREATE TABLE reference.defect_extent (
    extent_code    SMALLINT     PRIMARY KEY CHECK (extent_code BETWEEN 0 AND 5),
    extent_pct_min NUMERIC(4,1) NOT NULL,
    extent_pct_max NUMERIC(4,1) NOT NULL,
    description    VARCHAR(100) NOT NULL
);
INSERT INTO reference.defect_extent VALUES
    (0, 0.0,   0.0, 'None'),
    (1, 0.1,  10.0, 'Isolated / Few'),
    (2, 10.1, 25.0, 'Scattered / Occasional'),
    (3, 25.1, 50.0, 'Moderate / Frequent'),
    (4, 50.1, 75.0, 'Extensive / Widespread'),
    (5, 75.1, 100.0, 'Continuous / Everywhere');

-- Condition Index Categories (TMH22 Part E Section E.2)
-- VCI rating scale interpretation
CREATE TABLE reference.condition_index_categories (
    vci_min          NUMERIC(4,1) NOT NULL,
    vci_max          NUMERIC(4,1) NOT NULL,
    category_code    VARCHAR(20)  PRIMARY KEY,
    category_name    VARCHAR(100) NOT NULL,
    colour_hex       CHAR(7),
    maintenance_need VARCHAR(100),
    urgency          VARCHAR(20)  CHECK (urgency IN ('LOW','MEDIUM','HIGH','CRITICAL'))
);
INSERT INTO reference.condition_index_categories VALUES
    (8.0, 10.0, 'VERY_GOOD',    'Very Good',   '#00AA00', 'Routine maintenance only',           'LOW'),
    (6.0,  7.9, 'GOOD',          'Good',        '#88CC00', 'Preventive maintenance recommended', 'LOW'),
    (4.0,  5.9, 'FAIR',          'Fair',        '#FFAA00', 'Maintenance required',              'MEDIUM'),
    (2.0,  3.9, 'POOR',          'Poor',        '#FF5500', 'Rehabilitation recommended',         'HIGH'),
    (0.0,  1.9, 'VERY_POOR',     'Very Poor',   '#CC0000', 'Urgent rehabilitation required',     'CRITICAL');

-- =============================================================================
-- ENHANCED NETWORK TABLE COMMENT
-- Adds fields to capture TMH22 asset management context
-- =============================================================================

COMMENT ON TABLE tmh18.network IS
'TMH18 CD5.0 Table 7 — Network Definition File (.net)
Extended with TMH22 asset management framework context.

Each road_id represents a unique asset component that:
- Has a single LINESTRING geometry (per TMH18 Section 2.1d)
- Is measured from start_km to end_km (linear referencing)
- Has valid history tracked by start_date/end_date (TMH22 Section B.1.3)
- Is subject to assessment frequency per reference.assessment_frequency
- Must achieve minimum Level of Service per reference.level_of_service
- Is classified by RISFSA and surface type for grouping
- Belongs to an authority and administrative region for management accountability';

-- =============================================================================
-- RECOMMENDED VIEWS FOR TMH22 ASSET MANAGEMENT REPORTING
-- =============================================================================

-- Asset condition against Level of Service
CREATE OR REPLACE VIEW reporting.asset_los_compliance AS
SELECT
    rc.seg_id,
    n.auth_rd_id,
    rc.road_type,
    n.risfsa_cls,
    los.description              AS los_standard,
    los.min_vci                  AS los_min_vci,
    COALESCE(lfc.vci, 0)        AS current_vci,
    CASE
        WHEN lfc.vci IS NULL THEN 'NOT_ASSESSED'
        WHEN lfc.vci >= los.min_vci THEN 'COMPLIANT'
        ELSE 'NON_COMPLIANT'
    END                          AS compliance_status,
    lfc.measure_date             AS last_assessment_date,
    rc.geom
FROM tmh18.road_classification rc
JOIN tmh18.network n
    ON n.road_id = rc.road_id AND n.end_date IS NULL
LEFT JOIN reference.risfsa_classes r
    ON r.code = n.risfsa_cls
JOIN reference.level_of_service los
    ON (los.road_class = n.risfsa_cls OR los.road_class IS NULL)
LEFT JOIN reporting.latest_flex_condition lfc
    ON lfc.seg_id = rc.seg_id
WHERE los.road_class = n.risfsa_cls
   OR (los.code = 'LOS_URBAN_MAIN' AND n.risfsa_cls LIKE 'U1%')
   OR (los.code = 'LOS_URBAN_LOCAL' AND n.risfsa_cls LIKE 'U5%')
ORDER BY compliance_status DESC, current_vci ASC;

COMMENT ON VIEW reporting.asset_los_compliance IS
'TMH22 Asset Management framework view.
Compares each road segment against its applicable Level of Service standard.
Used for: asset management reporting, maintenance prioritization, budget allocation.';

-- Assessment frequency compliance
CREATE OR REPLACE VIEW reporting.assessment_due_schedule AS
SELECT
    n.auth_id,
    n.road_id,
    rc.seg_id,
    n.risfsa_cls,
    af.assessment_type,
    af.frequency_years,
    COALESCE(lfc.measure_date, n.start_date)  AS last_assessed,
    COALESCE(lfc.measure_date, n.start_date)
        + (af.frequency_years || ' years')::INTERVAL AS next_due,
    CASE
        WHEN NOW()::DATE > (COALESCE(lfc.measure_date, n.start_date)
                            + (af.frequency_years || ' years')::INTERVAL)::DATE
        THEN 'OVERDUE'
        WHEN NOW()::DATE > (COALESCE(lfc.measure_date, n.start_date)
                            + ((af.frequency_years - 1) || ' years')::INTERVAL)::DATE
        THEN 'DUE_SOON'
        ELSE 'SCHEDULED'
    END                          AS status,
    rc.geom
FROM tmh18.network n
JOIN tmh18.road_classification rc
    ON rc.road_id = n.road_id AND n.end_date IS NULL
JOIN reference.assessment_frequency af
    ON (af.road_class = n.risfsa_cls OR af.road_class = 'ALL')
    AND (af.asset_type = 'CARRIAGEWAY')
LEFT JOIN reporting.latest_flex_condition lfc
    ON lfc.seg_id = rc.seg_id
WHERE n.end_date IS NULL
ORDER BY status DESC, next_due ASC;

COMMENT ON VIEW reporting.assessment_due_schedule IS
'TMH22 Assessment Frequency Compliance (Part D Section D.5.3).
Tracks when road segments are due for reassessment per TMH22 methodology.
Used for: assessment scheduling, data collection planning, audit compliance.';

-- Asset hierarchy with condition summary
CREATE OR REPLACE VIEW reporting.asset_hierarchy_condition AS
SELECT
    a.auth_id,
    a.authority,
    a.auth_type,
    dm.district_id,
    dm.district_name,
    lm.lm_id,
    lm.lm_name,
    COUNT(DISTINCT r.pk)                                   AS total_routes,
    COUNT(DISTINCT rc.pk)                                  AS total_segments,
    ROUND(SUM(rc.end_km - rc.start_km)::NUMERIC, 1)       AS total_km,
    ROUND(AVG(lfc.vci)::NUMERIC, 2)                        AS avg_vci,
    COUNT(CASE WHEN lfc.vci >= 8 THEN 1 END)              AS very_good_segments,
    COUNT(CASE WHEN lfc.vci BETWEEN 6 AND 7.9 THEN 1 END) AS good_segments,
    COUNT(CASE WHEN lfc.vci BETWEEN 4 AND 5.9 THEN 1 END) AS fair_segments,
    COUNT(CASE WHEN lfc.vci BETWEEN 2 AND 3.9 THEN 1 END) AS poor_segments,
    COUNT(CASE WHEN lfc.vci < 2 THEN 1 END)               AS very_poor_segments,
    COUNT(CASE WHEN lfc.vci IS NULL THEN 1 END)           AS not_assessed_segments
FROM reference.auth_ids a
LEFT JOIN admin_boundaries.district_municipalities dm
    ON a.auth_id = ANY(STRING_TO_ARRAY(a.auth_id, ','))
LEFT JOIN admin_boundaries.local_municipalities lm
    ON dm.id = lm.district_id
LEFT JOIN tmh18.network r
    ON r.auth_id = a.auth_id AND r.end_date IS NULL
LEFT JOIN tmh18.road_classification rc
    ON rc.road_id = r.road_id
LEFT JOIN reporting.latest_flex_condition lfc
    ON lfc.seg_id = rc.seg_id
GROUP BY a.auth_id, a.authority, a.auth_type, dm.district_id, dm.district_name,
         lm.lm_id, lm.lm_name
ORDER BY a.auth_type DESC, a.authority;

COMMENT ON VIEW reporting.asset_hierarchy_condition IS
'TMH22 Asset Hierarchy view (Part B Section B.2).
Aggregates road condition from Authority → District → Local Municipality level.
Used for: portfolio-level reporting, strategic planning, funding allocation.';

-- =============================================================================
-- END OF TMH22 ASSET MANAGEMENT FRAMEWORK TABLES
-- =============================================================================

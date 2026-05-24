-- ============================================
-- 1. TABELA DE ORIGEM (Kafka append-only)
-- ============================================
CREATE TABLE IF NOT EXISTS onboarding_events (
    cliente_id  STRING,
    etapa       STRING,
    status      STRING,
    event_time  TIMESTAMP(3),
    WATERMARK FOR event_time AS event_time - INTERVAL '5' SECOND
) WITH (
    'connector'                    = 'kafka',
    'topic'                        = 'onboarding-events',
    'properties.bootstrap.servers' = 'kafka:9092',
    'properties.group.id'          = 'flink-onboarding-group',
    'scan.startup.mode'            = 'earliest-offset',
    'format'                       = 'json',
    'json.fail-on-missing-field'   = 'false',
    'json.ignore-parse-errors'     = 'true'
);

-- ============================================
-- 2. TABELA DE DESTINO (upsert-kafka)
-- ============================================
CREATE TABLE IF NOT EXISTS onboarding_summary (
    etapa  STRING,
    status STRING,
    total  BIGINT,
    PRIMARY KEY (etapa, status) NOT ENFORCED
) WITH (
    'connector'                    = 'upsert-kafka',
    'topic'                        = 'onboarding-summary',
    'properties.bootstrap.servers' = 'kafka:9092',
    'key.format'                   = 'json',
    'value.format'                 = 'json'
);

-- ============================================
-- 3. JOB DE AGREGAÇÃO (streaming contínuo)
-- ============================================
INSERT INTO onboarding_summary
SELECT
    etapa,
    status,
    COUNT(*) AS total
FROM onboarding_events
GROUP BY etapa, status;

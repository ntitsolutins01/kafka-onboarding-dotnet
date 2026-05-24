-- flink/thermostat_queries.sql

-- 1. Criar tabela sobre o tópico Kafka
CREATE TABLE thermostat_readings (
                                     sensor_id   INT,
                                     location    STRING,
                                     temperature DOUBLE,
                                     event_time  TIMESTAMP(3),
                                     WATERMARK FOR event_time AS event_time - INTERVAL '5' SECOND
) WITH (
      'connector'                    = 'kafka',
      'topic'                        = 'thermostat-readings',
      'properties.bootstrap.servers' = 'localhost:9092',
      'format'                       = 'json'
      );

-- 2. Média de temperatura por cômodo — janela de 5 minutos
SELECT
    location,
    ROUND(AVG(temperature), 2)          AS avg_temp,
    MAX(temperature)                    AS max_temp,
    TUMBLE_START(event_time, INTERVAL '5' MINUTE) AS window_start
FROM thermostat_readings
GROUP BY
    location,
    TUMBLE(event_time, INTERVAL '5' MINUTE);

-- 3. Filtrar apenas leituras críticas (acima de 25°C)
CREATE TABLE high_temp_alerts
    WITH (
             'connector' = 'kafka',
             'topic'     = 'high-temp-alerts',
             'properties.bootstrap.servers' = 'localhost:9092',
             'format'    = 'json'
) AS
SELECT * FROM thermostat_readings
WHERE temperature > 25.0;

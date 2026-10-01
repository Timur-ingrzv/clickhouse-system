CREATE DATABASE IF NOT EXISTS transactions_store;

-- Целевая таблица
CREATE TABLE transactions_store.transactions (
    transaction_time DateTime CODEC(DoubleDelta, ZSTD(3)),
    merch String,
    cat_id LowCardinality(String),
    amount Float32 CODEC(Gorilla, ZSTD(3)),
    name_1 String,
    name_2 String,
    gender LowCardinality(String),
    street String,
    one_city LowCardinality(String) CODEC(ZSTD(3)),
    us_state LowCardinality(String) CODEC(ZSTD(3)),
    post_code String,
    lat Float64 CODEC(Gorilla, ZSTD(3)),
    lon Float64 CODEC(Gorilla, ZSTD(3)), 
    population_city UInt32,
    jobs LowCardinality(String) CODEC(ZSTD(3)),
    merchant_lat Float64 CODEC(Gorilla, ZSTD(3)),
    merchant_lon Float64 CODEC(Gorilla, ZSTD(3)),
    target UInt8
)
ENGINE MergeTree()
PARTITION BY toYYYYMM(transaction_time)
ORDER BY (us_state, cat_id, transaction_time);

-- Консьюмер кафки
CREATE TABLE transactions_store.kafka_stream (
    transaction_time String,
    merch String,
    cat_id String,
    amount Float32,
    name_1 String,
    name_2 String,
    gender String,
    street String,
    one_city String,
    us_state String,
    post_code String,
    lat Float64,
    lon Float64,
    population_city UInt32,
    jobs String,
    merchant_lat Float64,
    merchant_lon Float64,
    target UInt8
)
ENGINE = Kafka
SETTINGS
    kafka_broker_list = 'kafka:9092',
    kafka_topic_list = 'transactions',
    kafka_group_name = 'transactions_analytics',
    kafka_num_consumers = 1,
    kafka_format = 'JSONEachRow';

-- мост от кафки до целевой таблицы
CREATE MATERIALIZED VIEW transactions_store.mv_kafka_to_storage
TO transactions_store.transactions
AS SELECT
parseDateTimeBestEffort(transaction_time) AS transaction_time,
merch,
cat_id,
amount,
name_1,
name_2,
gender,
street,
one_city,
us_state,
post_code,
lat,
lon, 
population_city,
jobs,
merchant_lat,
merchant_lon,
target
FROM transactions_store.kafka_stream;
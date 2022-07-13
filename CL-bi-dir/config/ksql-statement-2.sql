CREATE STREAM stockapp_users_stream_west (userid string, registertime BIGINT,
    regionid STRING,
    gender STRING) WITH (
    KAFKA_TOPIC = 'stockapp-users-west',
    VALUE_FORMAT = 'AVRO'
);

CREATE STREAM stockapp_users_stream_east (userid string, registertime BIGINT,
    regionid STRING,
    gender STRING) WITH (
    KAFKA_TOPIC = 'stockapp-users-east',
    VALUE_FORMAT = 'AVRO'
);

CREATE STREAM stockapp_users_stream (userid string, registertime BIGINT,
    regionid STRING,
    gender STRING) WITH (
    KAFKA_TOPIC = 'stockapp-users',
    VALUE_FORMAT = 'AVRO',
    partitions = 4,
    replicas = 1
);

SET 'auto.offset.reset' = 'earliest';

INSERT INTO stockapp_users_stream
  SELECT userid, registertime, regionid, gender from stockapp_users_stream_west
  EMIT CHANGES;

INSERT INTO stockapp_users_stream
  SELECT userid, registertime, regionid, gender from stockapp_users_stream_east
  EMIT CHANGES;

CREATE TABLE stockapp_users_count WITH (
    KAFKA_TOPIC = 'stockapp-users-count',
    partitions = 4,
    replicas = 1) as
    select userid, count(*) as count
    from stockapp_users_stream
    group by (userid)
    emit changes;


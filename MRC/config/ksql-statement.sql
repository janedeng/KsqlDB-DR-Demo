CREATE STREAM stockapp_users_stream WITH (
    KAFKA_TOPIC = 'stockapp-users',
    VALUE_FORMAT = 'AVRO'
);

CREATE TABLE stockapp_users_count WITH (
    KAFKA_TOPIC = 'stockapp-users-count') as 
    select userid, count(*) as count 
    from stockapp_users_stream 
    group by (userid) 
    emit changes;


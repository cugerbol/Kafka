from kafka import KafkaConsumer

bootstrap_servers = [
        '172.25.42.11:9092',
        '172.25.42.12:9092',
        '172.25.42.13:9092'
        ]

TopicName = 'test'
GroupName = 'test-producer-group'

consumer = KafkaConsumer(
        TopicName,
        group_id = GroupName,
        bootstrap_servers = bootstrap_servers,
        auto_offset_reset='earliest',
        enable_auto_commit=True,
        auto_commit_interval_ms=1000
        )

try:
    for msg in consumer:
        print(msg)
except KeyboardInterrupt:
    pass
finally:
    # Close down consumer to commit final offsets.
    consumer.close()
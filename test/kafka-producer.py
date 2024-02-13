from kafka import KafkaProducer
import random
import time

broker_list = [
        '172.25.42.11:9092',
        '172.25.42.12:9092',
        '172.25.42.13:9092'
        ]

TopicName = 'test'


producer = KafkaProducer(bootstrap_servers=broker_list)

i = 0
while(True):
    for _ in range(10):
        producer.send(TopicName, bytes(str(i),'utf-8'))
        i = i + 1
   
    time.sleep(random.randint(2, 5))  
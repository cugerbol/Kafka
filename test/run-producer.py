from libs import *

def send_messages(count=100, last_i=0):
    """Функция генерирует случайные сообщения и отправляет их в Kafka"""
    with open('./configs.yaml', 'r') as file:
        configs = yaml.safe_load(file)

    HostName = configs["broker"]["HostName"]
    Port = configs["broker"]["Port"]
    TopicName = configs["broker"]["TopicName"]
    if last_i == 0:
        print(f"HostName: {HostName}\nTopicName: {TopicName}")

    producer = KafkaProducer(bootstrap_servers=f"{HostName}:{Port}")
    for i in range(count):
        msg = create_message(i + last_i)
        producer.send(TopicName, f"{msg}".encode())

def create_message(i):
    """Функция генерирует одно сообщение в формате:
       ID сообщения;Время;ID пользователя;Имя пользователя;Возраст;Город;Событие"""
    sities = ["MSK", "SPB", "NSK", "NYS"]
    names = ["Sasha", "Max", "Masha", "Nikita", "Oleg", "Dasha"]
    events = ["Open main menu", "View products", "Add to shopping cart", "Delivery arrangements", "Payment for the order", "Registration for the service", "Open application"]

    MsgID = f"msd_id: {i};"
    time = f'time: {datetime.now().strftime("%H:%M:%S")};'
    UserID = f"user_id {random.randint(1, 10000)};"
    UserName = f"user_name: {random.choice(names)};"
    age = f"age: {random.randint(18,65)};"
    city = f"city: {random.choice(sities)};"
    event = f"event: {random.choice(events)}"

    return MsgID + time + UserID + UserName + age + city + event

if __name__ == "__main__":
    """Генерирует поток псевдо-случайных данных о событиях некоторого сервиса и отправляет эти данные в Kafka"""
    count = random.randint(50, 200)
    last_i = 0
    while True:
        send_messages(count=count, last_i=last_i)
        last_i += count
        time.sleep(random.randint(2, 5))


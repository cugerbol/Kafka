
## Project description

* example use apache kafka with clickhouse for ETL processes


## Step

### Create user

- sudo useradd -m kafka
- sudo passwd kafka 
- sudo vim /etc/passwd

Поменять **sh** на  **bash**

![](images/passwd.1.png)
![](images/passwd.2.png)

- sudo usermod -aG sudo kafka
- su kafka
- cd

### Install kafka

- sudo sh kafka-install.sh

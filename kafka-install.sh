#!/bin/bash

#######################################################################
########################## Set user params ############################
#######################################################################

USER='kafka'
HOST1='172.25.42.21'
HOST2='172.25.42.22'
HOST3='172.25.42.23'

ID=$(hostname | awk -F'-' '{print $NF}')
DIR="kafka_server_$ID"



#######################################################################
###################### Download and prepocessing ######################
#######################################################################

# Delete zookeeper.service if exist 
systemctl disable zookeeper
rm -rf /etc/systemd/system/zookeeper.service
rm -rf /var/zookeeper
rm -rf /tmp/zookeeper
rm -rf /tmp/kafka*

# Download Kafka
wget https://downloads.apache.org/kafka/3.6.1/kafka_2.12-3.6.1.tgz

# Unzip the downloaded file
tar -xvzf kafka_2.12-3.6.1.tgz 

# Remove the tarball after extraction
rm -rf kafka_2.12-3.6.1.tgz

# Create directory for kafka_server
rm -f kafka.log
rm -rf $DIR
mkdir $DIR

# Move Kafka files into the new directory
mv kafka_2.12-3.6.1/* $DIR/
rm -rf kafka_2.12-3.6.1

#######################################################################
############# Set configs in zookeeper..properties ####################
#######################################################################

FILE="$PWD/$DIR/config/zookeeper.properties"
echo "tickTime=2000" >> $FILE
echo "initLimit=10" >> $FILE
echo "syncLimit=5" >> $FILE
echo "server.1=${HOST1}:2888:3888" >> $FILE
echo "server.2=${HOST2}:2888:3888" >> $FILE
echo "server.3=${HOST3}:2888:3888" >> $FILE
echo "41w.commands.whitelist=*" >> $FILE

WORK_DIR=/tmp/zookeeper
mkdir -p ${WORK_DIR}
echo "${ID}" > ${WORK_DIR}/myid

echo "\nINFO: Set configs for Zookeeper"

######################################################################
############# Set configs in server.properties ########################
#######################################################################

FILE=$DIR/config/server.properties
sed -i "s/broker\.id=0/broker.id=${ID}/" $FILE
sed -i "s/offsets\.topic\.replication\.factor=1/offsets.topic.replication.factor=3/" $FILE
sed -i "s/transaction\.state\.log\.replication\.factor=1/transaction.state.log.replication.factor=3/" $FILE
sed -i "s/zookeeper\.connect=localhost:2181/zookeeper.connect=${HOST1}:2181,${HOST2}:2181,${HOST3}:2181/" $FILE
sed -i "s/log\.dirs=\/tmp\/kafka-logs/log.dirs=\/tmp\/kafka-logs-${ID}/" $FILE

echo "INFO: Set configs for Kafka"

#######################################################################
###################### create zookeeper.service file ##################
#######################################################################

cat << EOF > /etc/systemd/system/zookeeper.service
[Unit]
Requires=network.target remote-fs.target
After=network.target remote-fs.target

[Service]
Type=simple
User=$USER
ExecStart=/bin/sh -c "$PWD/$DIR/bin/zookeeper-server-start.sh $PWD/$DIR/config/zookeeper.properties"
ExecStop=$PWD/$DIR/bin/zookeeper-server-stop.sh

[Install]
WantedBy=multi-user.target
EOF

echo "INFO: Create zookeeper.service file"

#######################################################################
################### create kafka.service file #########################
#######################################################################

cat << EOF >  /etc/systemd/system/kafka.service
[Unit]
Requires=zookeeper.service
After=zookeeper.service

[Service]
Type=simple
User=$USER
ExecStart=/bin/sh -c "$PWD/$DIR/bin/kafka-server-start.sh $PWD/$DIR/config/server.properties > $PWD/$DIR/kafka.log 2>&1"
ExecStop=$PWD/$DIR/bin/kafka-server-stop.sh
Restart=on-abnormal

[Install]
WantedBy=multi-user.target
EOF

echo "INFO: Create kafka.service file"

#######################################################################
###################### distribution of rights #########################
#######################################################################

chmod -R  755 /tmp/zookeeper
chown -R $USER:$USER /tmp/zookeeper
chown -R $USER:$USER $DIR

systemctl daemon-reload
systemctl enable zookeeper
systemctl enable kafka


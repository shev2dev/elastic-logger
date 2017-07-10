#!/bin/sh

while [[ $(curl -s elasticsearch:9200/_cat/health | grep -qE "(green|yellow)"; echo $?) != 0 ]];
do
 sleep 1
done

for DATACENTER in $(ls); do
    cd $DATACENTER/timestamped

    for timestamp in $(ls); do
        for NODE in $(ls); do
            cd $timestamp/$NODE

            if [[ -d "kafka" ]]
            then
                source /scripts/kafka.sh $DATACENTER $NODE
            fi

            if [[ -d "storm" ]]
            then
                source /scripts/storm-errors.sh $DATACENTER $NODE
                source /scripts/storm-worker.sh $DATACENTER $NODE
            fi

        done
    done

    cd /opt/
done
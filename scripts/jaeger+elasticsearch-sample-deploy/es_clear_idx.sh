#!/bin/sh

set -x

ES_URL_AND_PORT=192.168.1.189:9200
LAST_DATE=`date "+%Y.%m.%d"`

if [ "$(uname)" == "Darwin" ] ;then
  LAST_DATE=`date -v-0d "+%Y-%m-%d"`
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ];then
  LAST_DATE=`date -d "-0 days" "+%Y-%m-%d"`
fi

main() {
  curl -XDELETE 'http://'$ES_URL_AND_PORT'/*-'${LAST_DATE}*'?pretty'
#  curl -H'Content-Type:application/json' -d'{
#"query": { "range": { "startTimeMillis": {"lt":"now-20m", "format":"epoch_millis"} } }
#}' -XPOST "$ES_URL_AND_PORT/*-*/_delete_by_query?pretty"
  curl "http://192.168.1.189:9200/_cat/indices?v"
}

main "$@"

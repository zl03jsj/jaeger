# Jaeger后台部署(Docker)

本文档描述使用docker部署jaeger-allinone采用elasticsearch的存储方案,

**在启动顺序上必须先启动elasticsearch,再启动Jaeger-all-in-one**

## Elasticsearch启动

elasticesearch启动采用单节点模式:

```
docker run -d --name es -p 9200:9200 \
	-p 9300:9300 \
	-e "discovery.type=single-node" \
	elasticsearch:7.12.0

6e10efa45fcab0c6e98fb0f55f37029d20b752175bd64e463dfc136f00ba24ba
```

删除过期tracing数据的shell脚本:
```
#!/bin/sh

ES_URL_AND_PORT=192.168.1.189:9200
LAST_DATE=`date "+%Y-%m-%d"`

if [ "$(uname)" == "Darwin" ] ;then
  LAST_DATE=`date -v-0d "+%Y-%m-%d"`
elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ];then
  LAST_DATE=`date -d "-0 days" "+%Y-%m-%d"`
fi

main() {
  curl -XDELETE 'http://'$ES_URL_AND_PORT'/*-'${LAST_DATE}*'?pretty'

  curl 'http://'$ES_URL_AND_PORT'/_cat/indices?v'

  curl -H'Content-Type:application/json' -d'{ "query": { "range": { "startTimeMillis": {"lt":"now-20m", "format":"epoch_millis"} } } }' -XPOST "$ES_URL_AND_PORT/*-*/_delete_by_query?pretty"
}

main "$@"
```

设置定时任务`crontab -e`添加定时任务:

```
*/10 * * * * sh /home/venus-message-tracer/es_crontab.sh
```

**elasticsearch的配置非常繁杂**
**本篇文章只是最简单的启动elasticsearch与Jaeger搭配使用**
**杂如果要让jaeger达到非常好的性能,还需要更多的研究,比如索引等**

## Jaeger-All-in-one启动

启动jaeger-allinone:
```
docker run \
  -e SPAN_STORAGE_TYPE=elasticsearch \
  -e ES_SERVER_URLS=http://192.168.1.189:9200 \
  -p 5775:5775/udp \
  -p 6831:6831/udp \
  -p 6832:6832/udp \
  -p 5778:5778 \
  -p 16686:16686 \
  -p 14268:14268 \
  -p 14250:14250 \
  -p 9411:9411 \
  jaegertracing/all-in-one:latest
```

启动jaeger-allinone采用badger数据库:
```
docker run -d --name jaeger \
  -e SPAN_STORAGE_TYPE=badger \
  -e BADGER_EPHEMERAL=false \
  -e BADGER_DIRECTORY_VALUE=/badger/data \
  -e BADGER_DIRECTORY_KEY=/badger/key \
  -v /Users/zl/workspace/go/src/jaeger/examples/hotrod:/badger \
  -p 5775:5775/udp \
  -p 6831:6831/udp \
  -p 6832:6832/udp \
  -p 5778:5778 \
  -p 16686:16686 \
  jaegertracing/all-in-one
```

* ES_SERVER_URLS 为elasticsearch的节点url
* 6831/6832端口为用于接收应用report的tracing信息
* 166686为jaeger-ui的服务端口

访问jaeger-ui: http://localhost:16686





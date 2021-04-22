docker run -d --name es -p 9200:9200 \
	-p 9300:9300 \
	-e "discovery.type=single-node" \
	-v "/home/venus-message-tracer/es_data:/es_data" \
	elasticsearch:7.12.0

docker run -d --name jaeger_badger \
  -e SPAN_STORAGE_TYPE=badger \
  -e BADGER_EPHEMERAL=false \
  -e BADGER_DIRECTORY_VALUE=/badger/data \
  -e BADGER_DIRECTORY_KEY=/badger/key \
  -v /home/venus-message-tracer/badger:/badger/data \
  -p 5775:5775/udp \
  -p 6831:6831/udp \
  -p 6832:6832/udp \
  -p 5778:5778 \
  -p 16686:16686 \
jaegertracing/all-in-one:latest

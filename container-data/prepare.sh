#!/bin/sh
set -e

echo "Writing proxy global config..."

echo "Proxy User Name: $GLOB_USER_NAME"
sed -i -e "s,S3dProxyUser,user ${GLOB_USER_NAME};,g" /etc/nginx/nginx.conf

echo "Proxy Worker Process Count: ${GLOB_WORKER_COUNT}"
sed -i -e "s,S3dProxyWorker,worker_processes ${GLOB_WORKER_COUNT};,g" /etc/nginx/nginx.conf

echo "Proxy Error Log Level: ${GLOB_ERROR_LOG_LEVEL}"
sed -i -e "s,S3dErrorLogLevel,${GLOB_ERROR_LOG_LEVEL},g" /etc/nginx/nginx.conf

echo "Proxy Worker Connections Count: ${GLOB_WORKER_CONNECTIONS}"
sed -i -e "s,S3dWorkerConnections,${GLOB_WORKER_CONNECTIONS},g" /etc/nginx/nginx.conf

echo "Proxy Accepting Multiple Connections at once: ${GLOB_WORKER_MULTI_ACCEPT}"
sed -i -e "s,S3dMultiAccept,${GLOB_WORKER_MULTI_ACCEPT},g" /etc/nginx/nginx.conf

echo "Proxy KeepAlive Timeout: ${GLOB_KEEPALIVE_TIMEOUT}"
sed -i -e "s,S3dKeepAliveTimeout,${GLOB_KEEPALIVE_TIMEOUT},g" /etc/nginx/nginx.conf

echo "Proxy Maximum Amount of File Handles: ${GLOB_WORKER_RLIMIT_NOFILE}"
sed -i -e "s,S3dMaxFileHandles,${GLOB_WORKER_RLIMIT_NOFILE},g" /etc/nginx/nginx.conf

if [ "$GLOB_PROXY_CACHE_ENABLE" == "1" ]; then
  echo "Proxy Cache Enabled: Yes"
  sed -i -e "s,S3dProxyCache,proxy_cache_path /tmp/cache levels=1:2 keys_zone=share:10m inactive=2h max_size=1g;\nproxy_cache_revalidate on;\nproxy_cache_valid 200 302 10m;\nproxy_cache_valid 301      1h;\nproxy_cache_valid any      1m;\nproxy_cache share;,g" /etc/nginx/nginx.conf
else
  echo "Proxy Cache Enabled: No"
  sed -i -e "s,S3dProxyCache,#noProxyCache,g" /etc/nginx/nginx.conf
fi
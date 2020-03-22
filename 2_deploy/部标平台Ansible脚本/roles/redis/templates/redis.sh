#!/bin/bash
config_redis () {
  echo "Begin config redis..."
{ expect << EOF
spawn sh ${ROOT_PATH}/utils/install_server.sh
expect "redis port"  {send "${REDISPORT}\n"}
expect "/etc/redis/6379.conf"  {send "${ROOT_PATH}/redis.conf\n"}
expect "redis log"  {send "${ROOT_PATH}/redis.log\n"} 
expect "data directory" {send "${dir}\n"}
expect "executable path" {send "/usr/local/bin/redis-server\n"}
expect "Is this ok" {send "\n \r"}
expect "executable path" {send "exit\r"}
EOF
} && \
echo "Redis has config finish"
}

config_redis

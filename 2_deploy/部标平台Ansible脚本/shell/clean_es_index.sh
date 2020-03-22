#!/bin/bash
#脚本的日志文件路径
CLEAN_LOG="/data/jtb/logs/clean_es_index.log"
#索引前缀
INDEX_PRFIX="jtb-applog"
#elasticsearch 的主机ip及端口
SERVER_PORT=192.168.0.2:9200
#删除和关闭多少天以前的日志
DELTIME=30
CLOTIME=15
# seconds since 1970-01-01 00:00:00 seconds
DELETE_SECONDS=$(date -d  "$(date  +%Y%m%d) -${DELTIME} days" +%s)
CLOSE_SECONDS=$(date -d  "$(date  +%Y%m%d) -${CLOTIME} days" +%s)

#判断日志文件是否存在，不存在需要创建。
if [ ! -f  "${CLEAN_LOG}" ];then
   touch ${CLEAN_LOG}
fi
#删除指定日期索引
clo_index () {
echo "----------------------------Close time is start at $(date +%Y-%m-%d_%H:%M:%S) ------------------------------" >>${CLEAN_LOG}
Indexs=$(curl -s "${SERVER_PORT}/_cat/indices?v" |grep green |awk '{print $3}'|grep "${INDEX_PRFIX}")
for clo_index in ${Indexs};do
   indexDate=$(echo ${clo_index} |awk -F [-.] '{print $3$4$5}')
   indexSecond=$( date -d ${indexDate} +%s )
   second_result=`expr $CLOSE_SECONDS - $indexSecond`
   if [ ${second_result} -gt 0 ];then
     echo "Index ${clo_index} is begin to close"  >>${CLEAN_LOG}
     cloResult=`curl -XPOST "${SERVER_PORT}/${clo_index}/_close?pretty" |sed -n '2p'`
     echo "CloResult is ${delResult}" >>${CLEAN_LOG}
   fi
done
  echo "Close time is end at $(date)" >>${CLEAN_LOG}
}


del_index () {
echo "----------------------------Clean time is start at $(date +%Y-%m-%d_%H:%M:%S) ------------------------------" >${CLEAN_LOG}
INDEXS=$(curl -s "${SERVER_PORT}/_cat/indices?v" |grep close |awk '{print $2}'|grep "${INDEX_PRFIX}")
for del_index in ${INDEXS};do
   indexDate=$(echo ${del_index} |awk -F [-.] '{print $3$4$5}')
   indexSecond=$( date -d ${indexDate} +%s )
   second_result=`expr $DELETE_SECONDS - $indexSecond`
   if [ ${second_result} -gt 0 ];then
      echo "Index ${del_index} is begin to delete"  >>${CLEAN_LOG}
      delResult=`curl -XDELETE "${SERVER_PORT}/"${del_index}"?pretty" |sed -n '2p'`
      echo "DelResult is ${delResult}" >>${CLEAN_LOG}
   fi
done
  echo "Clean time is end at $(date)" >>${CLEAN_LOG}
}

clo_index && 
del_index

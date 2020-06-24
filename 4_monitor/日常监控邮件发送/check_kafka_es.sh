#!/bin/bash

mail_to=wushaoyu95@163.com
ip=192.168.0.2
port=2022

log_file="es.log \
          forward.log \
          terminal.log \
          trip.log"

tmp_dir=/tmp
#content="total        used        free      shared  buff/cache   available"

fetch_log_file () {
   ssh -p${port} ${ip} sh /data/bin/check_kafka_es.sh
   for item in ${log_file};do
     scp -P${port} $ip:${tmp_dir}/$item   ${tmp_dir}/
   done
   sed -i "s;*;-;" ${tmp_dir}/es.log
#   ansible all -m shell -a 'free -m' > ${tmp_dir}/memory.log 
#   for number in 17 13 9 5 1;do
#     se_ip=`awk "NR==$number{print $1}" ${tmp_dir}/memory.log|awk '{print $1}'`
#     se_line=`expr $number + 1`
#     sed -i "${se_line}c ${se_ip} ${content}" ${tmp_dir}/memory.log
#     sed -i "${number}d" ${tmp_dir}/memory.log
#   done
}


set_html () {
cat > .podhtml  <<EOF
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta name="generator" content="SQL*Plus 11.2.0">
<style type='text/css'> body {font:10pt Arial,Helvetica,sans-serif; color:black; background:White;} p {font:10pt Arial,Helvetica,sans-serif; color:black; background:White;} table,tr,td {font:10pt Arial,Helvetica,sans-serif; color:Black; background:#f7f7e7; padding:0px 0px 0px 0px; margin:0px 0px 0px 0px;} th {font:bold 10pt Arial,Helvetica,sans-serif; color:#336699; background:#cccc99; padding:0px 0px 0px 0px;} h1 {font:16pt Arial,Helvetica,Geneva,sans-serif; color:#336699; background-color:White; border-bottom:1px solid #cccc99; margin-top:0pt; margin-bottom:0pt; padding:0px 0px 0px 0px;-
} h2 {font:bold 10pt Arial,Helvetica,Geneva,sans-serif; color:#336699; background-color:White; margin-top:4pt; margin-bottom:0pt;} a {font:9pt Arial,Helvetica,sans-serif; color:#663300; background:#ffffff; margin-top:0pt; margin-bottom:0pt; vertical-align:top;}</style><title>SQL*Plus Report</title>
</head>
<body>
<p>
EOF
}

getstatus_html () {
 file=$1
if [  -f $file   ];then
  tmp=0
  echo "<table border='1' width='90%' align='center' summary='Script output'>" >> .podhtml
  while read line
  do
  echo "<tr>" >>.podhtml
   tmp=$(($tmp+1))
  if [  $tmp -eq 1 ];then
     echo $line|awk '{for(i=1;i<=NF;i++)
       {
             print "<th scope=\"col\">"$i"</th>";
       }     
                     }' >>.podhtml
  else
     echo $line|awk '{for(i=1;i<=NF;i++)
          {
               print "<td align=\"left\">"$i"</td>";
         }  }' >>.podhtml
  fi
     echo "</tr>" >>.podhtml
  done<$file
  echo '</table>'>> .podhtml
  echo '<p></p>'>> .podhtml
else
  echo "$file is not exits" >> .podhtml
  return 1
fi
}

main () {
  fetch_log_file && \
  set_html  && \
  for item in ${log_file};do
    getstatus_html ${tmp_dir}/${item}
  done
#  getstatus_html ${tmp_dir}/memory.log
  echo -e "This mail from 112.35.44.185(省内平台)Kafka/Elasticsearch/定时巡检报告\n`cat .podhtml`"  |mail -s "$(echo -e "(省内平台)Schedule check Kafka/Elassticsearch \nContent-Type: text/html")" ${mail_to}
}

main

#!/bin/bash
#MAILTO=15071244227@163.com
MAILTO="wushaoyu95@163.com"
IPA=192.168.0.3 
IPB=192.168.0.2
IPC=192.168.0.5
IPD=192.168.0.4
IPE=192.168.0.7
LOGA=/data/jtb/logs/check_space/check_space_${IPA}.log
LOGB=/data/jtb/logs/check_space/check_space_${IPB}.log
LOGC=/data/jtb/logs/check_space/check_space_${IPC}.log
LOGD=/data/jtb/logs/check_space/check_space_${IPD}.log
LOGE=/data/jtb/logs/check_space/check_space_${IPE}.log

tmp_dir=/tmp
content="total        used        free      shared  buff/cache   available"

ansible kube-master -m shell -a 'df -h |sed -n "1,7p"' > ${LOGA}
ansible web002 -m shell -a 'df -h |sed -n "1,7p"' > ${LOGB}
ansible harbor -m shell -a 'df -h |sed -n "1,7p"' > ${LOGC}
ansible slave -m shell -a 'df -h |sed -n "1,7p"' > ${LOGD}
ansible extra -m shell -a 'df -h |sed -n "1,7p"' > ${LOGE}
sed -i "1d" ${LOGA} &&  echo "${IPA} WEB-001"  >> ${LOGA} 
sed -i "1d" ${LOGB} &&  echo "${IPB} WEB-002"  >> ${LOGB}
sed -i "1d" ${LOGC} &&  echo "${IPC} DATA-001"  >> ${LOGC}
sed -i "1d" ${LOGD} &&  echo "${IPD} DATA-002"  >> ${LOGD}
sed -i "1d" ${LOGE} &&  echo "${IPE} DATA-003"  >> ${LOGE}

ansible all -m shell -a 'free -m' > ${tmp_dir}/memory.log

for number in 17 13 9 5 1;do
     se_ip=`awk "NR==$number{print $1}" ${tmp_dir}/memory.log|awk '{print $1}'`
     se_line=`expr $number + 1`
     sed -i "${se_line}c ${se_ip} ${content}" ${tmp_dir}/memory.log
     sed -i "${number}d" ${tmp_dir}/memory.log
done

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

checkpod_html () {
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
       {  if(i==6)
          { print "<th scope=\"col\">"$i $(i+1)"</th>";
          i++;}
          else
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

set_html && \
checkpod_html ${LOGA}
checkpod_html ${LOGB}
checkpod_html ${LOGC}
checkpod_html ${LOGD}
checkpod_html ${LOGE}
checkpod_html  ${tmp_dir}/memory.log


echo -e "This mail from 112.35.44.185(省内平台)磁盘空间及内存使用检查\n`cat .podhtml`" |mail -s "$(echo -e "112.35.44.185 Check Diskspace Usage\nContent-Type: text/html")"  ${MAILTO}
